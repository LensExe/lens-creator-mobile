import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/lens_logo.dart';
import '../../providers/data_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _photographyStyles = <String, String>{
    'portrait': 'Chân dung',
    'vintage': 'Vintage',
    'korean': 'Hàn Quốc',
    'wedding': 'Cưới',
    'concept': 'Concept',
    'pre-wedding': 'Ảnh cưới',
    'beach': 'Biển',
    'lifestyle': 'Đời thường',
    'event': 'Sự kiện',
    'corporate': 'Doanh nghiệp',
    'family': 'Gia đình',
    'outdoor': 'Ngoại cảnh',
    'kids': 'Trẻ em',
    'streetwear': 'Thời trang đường phố',
    'fashion': 'Thời trang',
    'film': 'Phim',
    'maternity': 'Bầu',
    'commercial': 'Thương mại',
  };

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final location = TextEditingController();
  final selectedStyles = <String>{};
  bool signup = false;
  bool obscure = true;
  bool busy = false;
  String? success;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    if (signup && selectedStyles.isEmpty) {
      _showErrorMessage('Hãy chọn ít nhất một phong cách chụp.');
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final requestedLocation = GoRouterState.of(context)
        .uri
        .queryParameters['from'];
    setState(() {
      busy = true;
      success = null;
    });
    try {
      if (signup) {
        final fullName = name.text.trim();
        final normalizedName = fullName.contains(' ')
            ? fullName
            : '$fullName $fullName';
        await ref
            .read(authRepositoryProvider)
            .register(
              normalizedName,
              email.text.trim(),
              password.text,
              location: location.text,
              styles: selectedStyles.toList()..sort(),
            );
        if (!mounted) return;
        setState(() {
          signup = false;
          name.clear();
          password.clear();
          location.clear();
          selectedStyles.clear();
          success = 'Hồ sơ đã gửi và đang chờ LENS xét duyệt. Bạn có thể đăng nhập sau khi được duyệt.';
        });
        return;
      }
      final user = await ref
          .read(authRepositoryProvider)
          .login(email.text, password.text);
      if (!mounted) return;
      ref.read(authUserProvider.notifier).setUser(user);
      final safeLocation =
          requestedLocation != null &&
              (requestedLocation == '/photographer_home' ||
                  requestedLocation.startsWith('/photographer_home/'))
          ? requestedLocation
          : '/photographer_home';
      context.go(safeLocation);
    } catch (exception) {
      if (mounted) {
        _showErrorMessage(_extractErrorMessage(exception));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _extractErrorMessage(Object exception) {
    if (exception is ApiException) {
      final msg = exception.message;
      if (msg.contains('Keycloak request failed with status 400') ||
          msg.contains('Keycloak rejected the registration details')) {
        return 'Thông tin đăng ký không hợp lệ hoặc tài khoản đã tồn tại. Vui lòng kiểm tra lại Họ tên và Email.';
      }
      if (msg.contains('Keycloak user already exists') ||
          msg.contains('User exists with same email')) {
        return 'Email này đã được đăng ký trong hệ thống. Vui lòng đăng nhập hoặc dùng email khác.';
      }
      return msg;
    }
    if (exception is ApiConfigurationException) {
      return 'Lỗi cấu hình hệ thống: Địa chỉ máy chủ không hợp lệ.';
    }
    final message = exception
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Exception: ', '');
    if (message.contains('Keycloak request failed with status 400') ||
        message.contains('Keycloak rejected the registration details')) {
      return 'Thông tin đăng ký không hợp lệ hoặc tài khoản đã tồn tại. Vui lòng kiểm tra lại Họ tên và Email.';
    }
    if (message.contains('Keycloak user already exists') ||
        message.contains('User exists with same email')) {
      return 'Email này đã được đăng ký trong hệ thống. Vui lòng đăng nhập hoặc dùng email khác.';
    }
    if (message.contains('API_BASE_URL')) {
      return 'Chưa cấu hình địa chỉ máy chủ (API_BASE_URL).';
    }
    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Network is unreachable')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
    }
    if (message.contains('ProviderException') ||
        message.contains('stack trace')) {
      return 'Không thể kết nối đến hệ thống máy chủ. Vui lòng thử lại sau.';
    }
    return message;
  }

  Future<void> _startGoogleLogin() async {
    if (busy) return;
    try {
      await ref.read(authFlowRepositoryProvider).getGoogleAuthorizationUrl();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Google trên ứng dụng Creator'),
          content: const Text(
            'Backend đã cấp URL đăng nhập, nhưng chỉ có một callback frontend dùng chung. Cần callback/deep link để trả handoff code về đúng ứng dụng trước khi Mobile có thể nhận phiên đăng nhập.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) _showErrorMessage(_extractErrorMessage(error));
    }
  }

  void _openForgotPassword() {
    context.push(
      Uri(
        path: '/forgot-password',
        queryParameters: email.text.trim().isEmpty
            ? null
            : {'email': email.text.trim()},
      ).toString(),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.mist,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: LensLogo(
                  width: 160,
                  height: 94,
                  semanticLabel: 'Logo Lens Studio',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                signup ? 'Tạo tài khoản nhiếp ảnh gia' : 'Chào mừng trở lại',
                style: const TextStyle(color: AppColors.steel, fontSize: 14),
              ),
              if (GoRouterState.of(context).uri.queryParameters['reason'] ==
                  'photographer-only') ...[
                const SizedBox(height: 14),
                const Text(
                  'Ứng dụng này dành cho tài khoản nhiếp ảnh gia. Tài khoản khách hàng tiếp tục sử dụng ứng dụng LENS dành cho khách.',
                  style: TextStyle(
                    color: AppColors.graphite,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (signup) ...[
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Ví dụ: Bé Đẹp hoặc Nguyễn Văn An',
                        ),
                        validator: (value) {
                          final trimmed = (value ?? '').trim();
                          if (trimmed.length < 2) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          final words = trimmed
                              .split(RegExp(r'\s+'))
                              .where((w) => w.isNotEmpty)
                              .toList();
                          if (words.length < 2) {
                            return 'Vui lòng nhập cả họ và tên (ví dụ: Bé Đẹp)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: location,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Khu vực hoạt động',
                          hintText: 'Ví dụ: Thành phố Hồ Chí Minh',
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Vui lòng nhập khu vực hoạt động'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Phong cách chụp',
                        style: TextStyle(
                          color: AppColors.graphite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: [
                          for (final entry in _photographyStyles.entries)
                            FilterChip(
                              label: Text(entry.value),
                              selected: selectedStyles.contains(entry.key),
                              onSelected: busy
                                  ? null
                                  : (selected) => setState(() {
                                      if (selected) {
                                        selectedStyles.add(entry.key);
                                      } else {
                                        selectedStyles.remove(entry.key);
                                      }
                                    }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch((value ?? '').trim())
                          ? null
                          : 'Email không hợp lệ',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      obscureText: obscure,
                      autofillHints: [
                        signup
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        suffixIcon: IconButton(
                          tooltip: obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (signup && value!.length < 8) {
                          return 'Mật khẩu cần ít nhất 8 ký tự';
                        }
                        return null;
                      },
                    ),
                    if (!signup)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: busy ? null : _openForgotPassword,
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                    if (success != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  success!,
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    height: 1.4,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: Text(
                        busy
                            ? 'Đang xử lý...'
                            : signup
                            ? 'Tạo tài khoản'
                            : 'Đăng nhập',
                      ),
                    ),
                    if (!signup) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: busy ? null : _startGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Tiếp tục với Google'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        setState(() {
                          signup = !signup;
                          success = null;
                        });
                      },
                child: Text(
                  signup
                      ? 'Đã có tài khoản? Đăng nhập'
                      : 'Chưa có tài khoản? Đăng ký',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

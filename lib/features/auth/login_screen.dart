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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              const SizedBox(width: 12),
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
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              // Editorial Header / Brand Section
              const Align(
                alignment: Alignment.centerLeft,
                child: LensLogo(
                  width: 130,
                  height: 76,
                  semanticLabel: 'Logo Lens Studio',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                signup
                    ? 'Trở thành Photographer\ncủa LENS'
                    : 'Chào mừng trở lại',
                style: const TextStyle(
                  color: AppColors.graphite,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                signup
                    ? 'Đăng ký hồ sơ để bắt đầu nhận lịch chụp và kết nối với khách hàng.'
                    : 'Đăng nhập vào không gian làm việc dành cho nhiếp ảnh gia.',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (GoRouterState.of(context).uri.queryParameters['reason'] ==
                  'photographer-only') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.steel.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Text(
                    'Ứng dụng này dành cho tài khoản nhiếp ảnh gia. Tài khoản khách hàng tiếp tục sử dụng ứng dụng LENS dành cho khách.',
                    style: TextStyle(
                      color: AppColors.graphite,
                      fontSize: 13,
                      height: 1.4,
                    ),
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
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Ví dụ: Nguyễn Văn An',
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
                            return 'Vui lòng nhập cả họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      const Text(
                        'Phong cách chụp sở trường',
                        style: TextStyle(
                          color: AppColors.graphite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final entry in _photographyStyles.entries)
                            FilterChip(
                              label: Text(entry.value),
                              selected: selectedStyles.contains(entry.key),
                              selectedColor: AppColors.graphite,
                              labelStyle: TextStyle(
                                color: selectedStyles.contains(entry.key)
                                    ? Colors.white
                                    : AppColors.graphite,
                                fontSize: 13,
                                fontWeight: selectedStyles.contains(entry.key)
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              backgroundColor: AppColors.mist,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: selectedStyles.contains(entry.key)
                                      ? AppColors.graphite
                                      : AppColors.steel.withValues(alpha: 0.2),
                                ),
                              ),
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
                      const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                            size: 20,
                            color: AppColors.steel,
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
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.graphite,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    if (success != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: busy ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.graphite,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          busy
                              ? 'Đang xử lý...'
                              : signup
                              ? 'Tạo tài khoản'
                              : 'Đăng nhập',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (!signup) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: busy ? null : _startGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.graphite,
                            side: BorderSide(
                              color: AppColors.steel.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text(
                            'Tiếp tục với Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          setState(() {
                            signup = !signup;
                            success = null;
                          });
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.graphite,
                  ),
                  child: Text(
                    signup
                        ? 'Đã có tài khoản? Đăng nhập'
                        : 'Chưa có tài khoản? Đăng ký',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

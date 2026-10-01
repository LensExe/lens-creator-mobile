import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool signup = false;
  bool obscure = true;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final requestedLocation = GoRouterState.of(context)
        .uri
        .queryParameters['from'];
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final user = signup
          ? await ref
                .read(authRepositoryProvider)
                .register(name.text, email.text, password.text)
          : await ref
                .read(authRepositoryProvider)
                .login(email.text, password.text);
      if (!mounted) return;
      if (signup) {
        await ref
            .read(photographersProvider.notifier)
            .add(
              Photographer(
                id: user.id,
                name: user.name,
                avatar: '',
                cover: '',
                city: 'Hà Nội',
                styles: const ['Chân dung'],
                pricePerSession: 200000,
                rating: 0,
                reviewCount: 0,
                bio: 'Giới thiệu về bạn và phong cách chụp ảnh.',
                experienceYears: 0,
                portfolio: const [],
              ),
            );
        if (!mounted) return;
      }
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
        setState(
          () => error = exception.toString().replaceFirst('Bad state: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.snow,
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
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: AppColors.ember,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lens Studio',
                style: Theme.of(context).textTheme.headlineLarge,
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
                        ),
                        validator: (value) => (value ?? '').trim().length < 2
                            ? 'Vui lòng nhập họ và tên'
                            : null,
                      ),
                      const SizedBox(height: 12),
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
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          error!,
                          style: const TextStyle(color: AppColors.destructive),
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
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        signup = !signup;
                        error = null;
                      }),
                child: Text(
                  signup
                      ? 'Đã có tài khoản? Đăng nhập'
                      : 'Chưa có tài khoản? Đăng ký',
                ),
              ),
              if (!signup)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tài khoản mẫu · Nhiếp ảnh gia',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'nhiepanhgia@lens.vn · demo1234',
                        style: TextStyle(color: AppColors.steel),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          email.text = 'nhiepanhgia@lens.vn';
                          password.text = 'demo1234';
                          error = null;
                        }),
                        child: const Text('Điền tài khoản mẫu'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

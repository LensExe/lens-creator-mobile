import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, required this.onSubmit});

  final Future<void> Function(String currentPassword, String newPassword)
  onSubmit;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final formKey = GlobalKey<FormState>();
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  bool saving = false;
  String? error;

  @override
  void dispose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate() || saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.onSubmit(currentPassword.text, newPassword.text);
      if (mounted) Navigator.pop(context);
    } catch (exception) {
      if (mounted) {
        setState(
          () => error = exception.toString().replaceFirst('Bad state: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1D),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF636466),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Mật khẩu hiện tại',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF636466),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: currentPassword,
                obscureText: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1D)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F5),
                  hintText: '••••••••',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.ember,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) => (value ?? '').isEmpty
                    ? 'Vui lòng nhập mật khẩu hiện tại'
                    : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Mật khẩu mới',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF636466),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: newPassword,
                obscureText: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1D)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F5),
                  hintText: 'Tối thiểu 8 ký tự',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.ember,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) => (value ?? '').length < 8
                    ? 'Mật khẩu mới cần ít nhất 8 ký tự'
                    : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Xác nhận mật khẩu mới',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF636466),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: confirmPassword,
                obscureText: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1D)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F4F5),
                  hintText: 'Nhập lại mật khẩu mới',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.ember,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) => value != newPassword.text
                    ? 'Mật khẩu xác nhận không khớp'
                    : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(
                  error!,
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: saving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          foregroundColor: const Color(0xFF1A1C1D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(saving ? 'Đang cập nhật...' : 'Cập nhật'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

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
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Đổi mật khẩu'),
    content: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
              validator: (value) => (value ?? '').isEmpty
                  ? 'Vui lòng nhập mật khẩu hiện tại'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              validator: (value) => (value ?? '').length < 8
                  ? 'Mật khẩu mới cần ít nhất 8 ký tự'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
              ),
              validator: (value) => value != newPassword.text
                  ? 'Mật khẩu xác nhận không khớp'
                  : null,
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.destructive),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: saving ? null : () => Navigator.pop(context),
        child: const Text('Huỷ'),
      ),
      FilledButton(
        onPressed: saving ? null : _submit,
        child: Text(saving ? 'Đang cập nhật...' : 'Đổi mật khẩu'),
      ),
    ],
  );
}

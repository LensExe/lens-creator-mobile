import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class PackageEditorField extends StatelessWidget {
  const PackageEditorField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.suffixText,
    this.hintText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final String? suffixText;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppTokens.space4),
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        alignLabelWithHint: maxLines > 1,
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      minLines: maxLines > 1 ? maxLines : null,
      maxLines: maxLines,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      validator: validator,
    ),
  );
}

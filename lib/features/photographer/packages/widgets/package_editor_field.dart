import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class PackageEditorField extends StatelessWidget {
  const PackageEditorField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.suffixText,
    this.hintText,
    this.helperText,
    this.textStyle,
    this.requiredField = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final String? suffixText;
  final String? hintText;
  final String? helperText;
  final TextStyle? textStyle;
  final bool requiredField;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (requiredField)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: AppColors.destructive,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (maxLength != null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => Text(
                  '${value.text.length} / $maxLength',
                  style: const TextStyle(
                    color: AppColors.steel,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style:
              textStyle ??
              const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              color: AppColors.steel,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF3F3F4),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 15,
            ),
            hintStyle: const TextStyle(color: AppColors.ash, fontSize: 14),
            counterText: '',
            border: _border,
            enabledBorder: _border,
            disabledBorder: _border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 28),
              borderSide: const BorderSide(color: AppColors.ember, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 28),
              borderSide: const BorderSide(color: AppColors.destructive),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 28),
              borderSide: const BorderSide(
                color: AppColors.destructive,
                width: 1,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 11, height: 1.15),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          minLines: maxLines > 1 ? maxLines : null,
          maxLines: maxLines,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
          validator: validator,
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              helperText!,
              style: const TextStyle(
                color: AppColors.steel,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(maxLines > 1 ? 16 : 28),
    borderSide: BorderSide.none,
  );
}

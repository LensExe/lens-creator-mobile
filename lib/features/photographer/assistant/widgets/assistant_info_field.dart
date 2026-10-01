import 'package:flutter/material.dart';

class AssistantInfoField extends StatelessWidget {
  const AssistantInfoField({
    super.key,
    required this.label,
    required this.controller,
    required this.maxLines,
    required this.enabled,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: maxLines == 1 ? null : maxLines,
    maxLines: maxLines,
    enabled: enabled,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(labelText: label),
  );
}

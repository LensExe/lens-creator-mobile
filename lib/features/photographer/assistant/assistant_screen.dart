import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_section_header.dart';
import 'assistant_provider.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final services = TextEditingController();
  final style = TextEditingController();
  final area = TextEditingController();
  final tone = TextEditingController();
  final faqs = <(TextEditingController, TextEditingController)>[];
  bool enabled = true;
  bool initialized = false;

  @override
  void dispose() {
    services.dispose();
    style.dispose();
    area.dispose();
    tone.dispose();
    for (final (question, answer) in faqs) {
      question.dispose();
      answer.dispose();
    }
    super.dispose();
  }

  void _save() {
    ref
        .read(assistantProvider.notifier)
        .save(
          AssistantConfig(
            enabled: enabled,
            services: services.text.trim(),
            style: style.text.trim(),
            area: area.text.trim(),
            tone: tone.text.trim(),
            faqs: [
              for (final (question, answer) in faqs)
                if (question.text.trim().isNotEmpty ||
                    answer.text.trim().isNotEmpty)
                  AssistantFaq(question.text.trim(), answer.text.trim()),
            ],
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu dữ liệu trợ lý AI')));
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(assistantProvider);
    if (!initialized) {
      enabled = saved.enabled;
      services.text = saved.services;
      style.text = saved.style;
      area.text = saved.area;
      tone.text = saved.tone;
      for (final faq in saved.faqs) {
        faqs.add((
          TextEditingController(text: faq.question),
          TextEditingController(text: faq.answer),
        ));
      }
      initialized = true;
    }
    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(title: const Text('Trợ lý AI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 32),
            children: [
              const Text(
                'Cung cấp thông tin để trợ lý trả lời khách trong phạm vi dữ liệu này. Khiếu nại, huỷ và tranh chấp tiền phải chuyển cho bạn.',
                style: TextStyle(
                  color: AppColors.steel,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                title: const Text('Kích hoạt trợ lý'),
                onChanged: (value) => setState(() => enabled = value),
              ),
              const Divider(),
              const SizedBox(height: 23),
              const CreatorSectionHeader(title: 'Thông tin trả lời'),
              const SizedBox(height: 14),
              _Field('Giá & dịch vụ', services),
              _Field('Phong cách', style),
              _Field('Khu vực hoạt động', area),
              _Field('Giọng điệu', tone),
              const SizedBox(height: 17),
              const CreatorSectionHeader(title: 'Câu hỏi thường gặp'),
              const SizedBox(height: 14),
              for (final (index, pair) in faqs.indexed) ...[
                Text(
                  'Câu hỏi ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                TextField(
                  controller: pair.$1,
                  decoration: const InputDecoration(labelText: 'Câu hỏi'),
                ),
                const SizedBox(height: 9),
                TextField(
                  controller: pair.$2,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Câu trả lời'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      final removed = faqs.removeAt(index);
                      removed.$1.dispose();
                      removed.$2.dispose();
                    }),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xoá'),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => setState(
                  () => faqs.add((
                    TextEditingController(),
                    TextEditingController(),
                  )),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Thêm câu hỏi'),
              ),
              const SizedBox(height: 25),
              FilledButton(
                onPressed: _save,
                child: const Text('Lưu dữ liệu trợ lý'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.controller);
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

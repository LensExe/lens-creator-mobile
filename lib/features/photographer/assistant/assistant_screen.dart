import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
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
      appBar: AppBar(title: const Text('Trợ lý AI')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          const Text(
            'Cung cấp thông tin để trợ lý trả lời khách trong phạm vi dữ liệu này. Khiếu nại, huỷ và tranh chấp tiền phải chuyển cho bạn.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    title: const Text('Kích hoạt trợ lý'),
                    onChanged: (value) => setState(() => enabled = value),
                  ),
                  _Field('Giá & dịch vụ', services),
                  _Field('Phong cách', style),
                  _Field('Khu vực hoạt động', area),
                  _Field('Giọng điệu', tone),
                  Text(
                    'Câu hỏi thường gặp',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final (index, pair) in faqs.indexed)
                    Card(
                      color: AppColors.mist,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextField(
                              controller: pair.$1,
                              decoration: const InputDecoration(
                                labelText: 'Câu hỏi',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: pair.$2,
                              minLines: 2,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Câu trả lời',
                              ),
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
                          ],
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            child: const Text('Lưu dữ liệu trợ lý'),
          ),
        ],
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

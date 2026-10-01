import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
import 'assistant_models.dart';
import 'assistant_provider.dart';
import 'widgets/assistant_activation_tile.dart';
import 'widgets/assistant_editor_actions.dart';
import 'widgets/assistant_faq_editor.dart';
import 'widgets/assistant_info_field.dart';

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
  bool saving = false;

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

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await ref
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu dữ liệu trợ lý AI')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu dữ liệu trợ lý: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _addFaq() {
    setState(() {
      faqs.add((TextEditingController(), TextEditingController()));
    });
  }

  void _removeFaq(int index) {
    setState(() {
      final removed = faqs.removeAt(index);
      removed.$1.dispose();
      removed.$2.dispose();
    });
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
      bottomNavigationBar: AssistantEditorActions(
        onCancel: () => context.pop(),
        onSave: _save,
        busy: saving,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppTokens.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const CreatorPageHeader(
                title: 'Thiết lập cách trợ lý phản hồi',
                subtitle: 'Cung cấp thông tin để trợ lý trả lời khách trong phạm vi dữ liệu này.',
              ),
              const SizedBox(height: 22),
              AssistantActivationTile(
                value: enabled,
                onChanged: saving
                    ? null
                    : (value) => setState(() => enabled = value),
              ),
              const SizedBox(height: 14),
              const _HandoffNote(),
              const SizedBox(height: 28),
              const CreatorSectionHeader(
                title: 'Thông tin trả lời',
                subtitle:
                    'Thông tin trợ lý có thể dùng khi trao đổi với khách.',
              ),
              const SizedBox(height: 14),
              AssistantInfoField(
                label: 'Giá & dịch vụ',
                controller: services,
                maxLines: 3,
                enabled: !saving,
              ),
              const SizedBox(height: 11),
              AssistantInfoField(
                label: 'Phong cách',
                controller: style,
                maxLines: 2,
                enabled: !saving,
              ),
              const SizedBox(height: 11),
              AssistantInfoField(
                label: 'Khu vực hoạt động',
                controller: area,
                maxLines: 2,
                enabled: !saving,
              ),
              const SizedBox(height: 11),
              AssistantInfoField(
                label: 'Giọng điệu',
                controller: tone,
                maxLines: 2,
                enabled: !saving,
              ),
              const SizedBox(height: 28),
              CreatorSectionHeader(
                title: 'Câu hỏi thường gặp',
                count: faqs.length,
                subtitle: 'Soạn sẵn câu trả lời cho những thắc mắc phổ biến.',
              ),
              const SizedBox(height: 14),
              for (final (index, pair) in faqs.indexed) ...[
                AssistantFaqEditor(
                  index: index + 1,
                  question: pair.$1,
                  answer: pair.$2,
                  enabled: !saving,
                  onRemove: () => _removeFaq(index),
                ),
                if (index < faqs.length - 1) const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: saving ? null : _addFaq,
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Thêm câu hỏi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.graphite,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandoffNote extends StatelessWidget {
  const _HandoffNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusInput),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: AppColors.steel),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Khiếu nại, huỷ và tranh chấp tiền phải chuyển cho bạn.',
            style: TextStyle(
              color: AppColors.graphite,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

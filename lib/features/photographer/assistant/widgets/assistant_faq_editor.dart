import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AssistantFaqTile extends StatelessWidget {
  const AssistantFaqTile({
    super.key,
    required this.index,
    required this.question,
    required this.answer,
    required this.onTap,
  });

  final int index;
  final String question;
  final String answer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  question.isNotEmpty ? question : 'Câu hỏi $index',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1C1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  answer.isNotEmpty ? answer : 'Chưa có nội dung trả lời...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F5E60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF5F5E60),
            ),
          ),
        ],
      ),
    ),
  );
}

class AssistantFaqEditorSheet extends StatefulWidget {
  const AssistantFaqEditorSheet({
    super.key,
    required this.questionController,
    required this.answerController,
    required this.index,
    required this.onSave,
    this.onDelete,
  });

  final TextEditingController questionController;
  final TextEditingController answerController;
  final int index;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  State<AssistantFaqEditorSheet> createState() =>
      _AssistantFaqEditorSheetState();
}

class _AssistantFaqEditorSheetState extends State<AssistantFaqEditorSheet> {
  late final TextEditingController _q;
  late final TextEditingController _a;

  @override
  void initState() {
    super.initState();
    _q = TextEditingController(text: widget.questionController.text);
    _a = TextEditingController(text: widget.answerController.text);
  }

  @override
  void dispose() {
    _q.dispose();
    _a.dispose();
    super.dispose();
  }

  void _submit() {
    widget.questionController.text = _q.text.trim();
    widget.answerController.text = _a.text.trim();
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi ${widget.index}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1D),
                ),
              ),
              Row(
                children: [
                  if (widget.onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFD32F2F),
                        size: 20,
                      ),
                      tooltip: 'Xoá câu hỏi',
                      onPressed: () {
                        widget.onDelete!();
                        Navigator.pop(context);
                      },
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF5F5E60),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Câu hỏi của khách',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5F5E60),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _q,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1D)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF4F4F5),
              hintText: 'Ví dụ: Bao lâu thì nhận được ảnh?',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFA1A1AA),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Câu trả lời soạn sẵn',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5F5E60),
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _a,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1C1D)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF4F4F5),
              hintText: 'Nhập câu trả lời chi tiết cho khách hàng...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFA1A1AA),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _submit,
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
              child: const Text('Xong'),
            ),
          ),
        ],
      ),
    ),
  );
}

// Retaining compatibility for any previous imports
class AssistantFaqEditor extends StatelessWidget {
  const AssistantFaqEditor({
    super.key,
    required this.index,
    required this.question,
    required this.answer,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final TextEditingController question;
  final TextEditingController answer;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AssistantFaqTile(
    index: index,
    question: question.text,
    answer: answer.text,
    onTap: () {
      if (!enabled) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => AssistantFaqEditorSheet(
          questionController: question,
          answerController: answer,
          index: index,
          onSave: () {},
          onDelete: onRemove,
        ),
      );
    },
  );
}

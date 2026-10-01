import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import '../assistant/assistant_provider.dart';
import 'conversation_provider.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/conversation_ai_control.dart';
import 'widgets/conversation_avatar.dart';
import 'widgets/conversation_info_sheet.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  bool sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(conversationsProvider.notifier)
            .markRead(widget.id)
            .catchError((_) {});
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;
    if (ref.read(authUserProvider) == null) return;
    setState(() => sending = true);
    try {
      await ref.read(conversationsProvider.notifier).send(widget.id, text);
      if (!mounted) return;
      controller.clear();
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi tin nhắn: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _toggleAssistant(bool enabled) async {
    try {
      await ref
          .read(conversationsProvider.notifier)
          .toggleAi(widget.id, enabled);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật trợ lý: $error')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(conversationsProvider, (previous, next) {
      final previousCount = previous
          ?.where((item) => item.id == widget.id)
          .firstOrNull
          ?.messages
          .length;
      final nextCount = next
          .where((item) => item.id == widget.id)
          .firstOrNull
          ?.messages
          .length;
      if (previousCount != nextCount) {
        _scrollToBottom();
      }
    });
    StudioConversation? conversation;
    for (final item in ref.watch(conversationsProvider)) {
      if (item.id == widget.id) {
        conversation = item;
        break;
      }
    }

    if (conversation == null) {
      return const Scaffold(
        backgroundColor: AppColors.snow,
        body: Center(child: Text('Không tìm thấy hội thoại')),
      );
    }

    final current = conversation;
    final assistantEnabled = ref.watch(assistantProvider).enabled;
    final assistantActive = current.aiEnabled && assistantEnabled;
    final user = ref.watch(authUserProvider);
    final bookings = ref
        .watch(myBookingsProvider)
        .where((booking) => booking.clientId == current.participantId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ConversationAvatar(name: current.participantName, size: 37),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.participantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.participantIsPhotographer
                        ? 'Nhiếp ảnh gia'
                        : 'Khách hàng',
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thông tin hội thoại',
            onPressed: () => showConversationInfoSheet(
              context: context,
              conversation: current,
              bookings: bookings,
            ),
            icon: const Icon(Icons.info_outline_rounded),
            color: AppColors.graphite,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (!current.participantIsPhotographer)
            ConversationAiControl(
              isEnabled: assistantActive,
              canToggle: assistantEnabled,
              onChanged: _toggleAssistant,
            ),
          Expanded(
            child: current.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có tin nhắn trong cuộc trò chuyện này.',
                      style: TextStyle(color: AppColors.steel, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
                    itemCount: current.messages.length,
                    itemBuilder: (context, index) {
                      final message = current.messages[index];
                      return ChatMessageBubble(
                        message: message,
                        isMine: message.senderId == user?.id,
                      );
                    },
                  ),
          ),
          ChatComposer(controller: controller, onSend: _send, busy: sending),
        ],
      ),
    );
  }
}

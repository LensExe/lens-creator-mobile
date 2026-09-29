import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/data_providers.dart';
import 'conversation_provider.dart';
import '../assistant/assistant_provider.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(conversationsProvider.notifier).markRead(widget.id);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(authUserProvider);
    if (user == null) return;
    ref.read(conversationsProvider.notifier).send(widget.id, text, user.id);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    StudioConversation? conversation;
    for (final item in ref.watch(conversationsProvider)) {
      if (item.id == widget.id) {
        conversation = item;
        break;
      }
    }
    if (conversation == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy hội thoại')),
      );
    }
    final current = conversation;
    final assistantEnabled = ref.watch(assistantProvider).enabled;
    final user = ref.watch(authUserProvider);
    final bookings = ref
        .watch(myBookingsProvider)
        .where((booking) => booking.clientId == current.participantId)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(current.participantName),
        actions: [
          IconButton(
            tooltip: 'Thông tin hội thoại',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.participantName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.participantIsPhotographer
                            ? 'Nhiếp ảnh gia'
                            : 'Khách hàng',
                      ),
                      const SizedBox(height: 16),
                      Text('Lịch chụp liên quan: ${bookings.length}'),
                      for (final booking in bookings)
                        ListTile(
                          title: Text('${booking.style} · ${booking.date}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            context.push(
                              '/photographer_home/booking/${booking.id}',
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!current.participantIsPhotographer)
            SwitchListTile(
              dense: true,
              value: current.aiEnabled && assistantEnabled,
              title: const Text('Trợ lý AI'),
              subtitle: Text(
                current.aiEnabled
                    ? 'Trợ lý đang trả lời trong hội thoại này.'
                    : 'Bạn đang trực tiếp trả lời khách.',
              ),
              onChanged: assistantEnabled
                  ? (value) => ref
                        .read(conversationsProvider.notifier)
                        .toggleAi(widget.id, value)
                  : null,
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final message in current.messages)
                  Align(
                    alignment: message.senderId == user?.id
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isAi
                            ? const Color(0xFFFFEDD5)
                            : message.senderId == user?.id
                            ? AppColors.obsidian
                            : AppColors.fog,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.isAi)
                            const Text(
                              'Trợ lý AI',
                              style: TextStyle(
                                color: AppColors.ember,
                                fontSize: 11,
                              ),
                            ),
                          Text(
                            message.text,
                            style: TextStyle(
                              color: message.senderId == user?.id
                                  ? Colors.white
                                  : AppColors.obsidian,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(message.sentAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: message.senderId == user?.id
                                  ? Colors.white70
                                  : AppColors.steel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/booking_rules.dart';
import '../../../domain/models/models.dart';
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

  List<Object> _timelineItems(List<StudioMessage> messages) {
    final items = <Object>[];
    DateTime? previousDate;
    for (final message in messages) {
      final date = message.sentAt;
      if (previousDate == null || !DateUtils.isSameDay(previousDate, date)) {
        items.add(date);
        previousDate = date;
      }
      items.add(message);
    }
    return items;
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
        backgroundColor: AppColors.mist,
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
    final roleLabel = current.participantIsPhotographer
        ? 'Nhiếp ảnh gia'
        : 'Khách hàng';
    final headerSubtitle = bookings.isEmpty
        ? roleLabel
        : '$roleLabel · ${bookings.first.packageName ?? bookings.first.style}';
    final timeline = _timelineItems(current.messages);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 0,
        backgroundColor: const Color(0xFFF9F9FA),
        title: Row(
          children: [
            ConversationAvatar(name: current.participantName, size: 36),
            const SizedBox(width: 9),
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
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    headerSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
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
          if (bookings.isNotEmpty)
            _BookingContext(
              booking: bookings.first,
              onDetails: () => context.push(
                '/photographer_home/booking/${bookings.first.id}',
              ),
            ),
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
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
                    itemCount: timeline.length,
                    itemBuilder: (context, index) {
                      final item = timeline[index];
                      if (item is DateTime) return _ChatDateStamp(date: item);
                      final message = item as StudioMessage;
                      return ChatMessageBubble(
                        message: message,
                        isMine: message.senderId == user?.id,
                        senderName: current.participantName,
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

class _BookingContext extends StatelessWidget {
  const _BookingContext({required this.booking, required this.onDetails});

  final Booking booking;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final timeSlot = booking.timeSlot?.trim();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 3),
      padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 9,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F4),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.ember,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.style}${booking.packageName == null ? '' : ' · ${booking.packageName}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${BookingRules.statusLabel(booking.status)} · $dateLabel${timeSlot?.isNotEmpty == true ? ' · $timeSlot' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.steel, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 3),
          TextButton.icon(
            onPressed: onDetails,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ember,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              minimumSize: const Size(0, 36),
              visualDensity: VisualDensity.compact,
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 17),
            label: const Text(
              'Chi tiết',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatDateStamp extends StatelessWidget {
  const _ChatDateStamp({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = DateUtils.isSameDay(date, now)
        ? 'Hôm nay, ${DateFormat('dd/MM/yyyy').format(date)}'
        : DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))
        ? 'Hôm qua, ${DateFormat('dd/MM/yyyy').format(date)}'
        : DateFormat('dd/MM/yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 15),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.steel,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/data_providers.dart';
import '../assistant/assistant_provider.dart';
import '../assistant/assistant_rules.dart';

class StudioMessage {
  StudioMessage({
    required this.text,
    required this.senderId,
    DateTime? sentAt,
    this.isAi = false,
  }) : sentAt = sentAt ?? DateTime.now();
  final String text;
  final String senderId;
  final DateTime sentAt;
  final bool isAi;
}

class StudioConversation {
  StudioConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.messages,
    this.unreadCount = 0,
    this.aiEnabled = true,
    this.participantIsPhotographer = false,
  });
  final String id;
  final String participantId;
  final String participantName;
  final List<StudioMessage> messages;
  final int unreadCount;
  final bool aiEnabled;
  final bool participantIsPhotographer;

  StudioConversation copyWith({
    List<StudioMessage>? messages,
    int? unreadCount,
    bool? aiEnabled,
  }) => StudioConversation(
    id: id,
    participantId: participantId,
    participantName: participantName,
    messages: messages ?? this.messages,
    unreadCount: unreadCount ?? this.unreadCount,
    aiEnabled: aiEnabled ?? this.aiEnabled,
    participantIsPhotographer: participantIsPhotographer,
  );
}

class ConversationsNotifier extends Notifier<List<StudioConversation>> {
  @override
  List<StudioConversation> build() {
    if (ref.watch(authUserProvider)?.id != 'me') return [];
    return [
      StudioConversation(
        id: 'c1',
        participantId: 'c-anh',
        participantName: 'Nguyễn Thuý An',
        unreadCount: 2,
        messages: [
          StudioMessage(
            text: 'Chào chị, em vừa gửi yêu cầu đặt lịch chụp chân dung ạ.',
            senderId: 'c-anh',
          ),
          StudioMessage(
            text: 'Chào em, chị đã nhận được yêu cầu rồi nhé.',
            senderId: 'me',
          ),
          StudioMessage(
            text: 'Dạ chị ơi, buổi chụp mình bắt đầu lúc mấy giờ ạ?',
            senderId: 'c-anh',
          ),
        ],
      ),
      StudioConversation(
        id: 'c2',
        participantId: 'c-chi',
        participantName: 'Phạm Mai Chi',
        messages: [
          StudioMessage(
            text: 'Chị ơi, địa điểm chụp ở Phố cổ mình hẹn nhau ở đâu ạ?',
            senderId: 'c-chi',
          ),
        ],
      ),
      StudioConversation(
        id: 'c3',
        participantId: 'p2',
        participantName: 'Trần Quốc Bảo',
        aiEnabled: false,
        participantIsPhotographer: true,
        messages: [
          StudioMessage(
            text: 'Mình gửi bạn bảng giá gói chụp cưới nhé.',
            senderId: 'p2',
          ),
        ],
      ),
      StudioConversation(
        id: 'c5',
        participantId: 'u-khachhang',
        participantName: 'Trần Khách Hàng',
        unreadCount: 1,
        messages: [
          StudioMessage(
            text:
                'Chào chị, em muốn hỏi cuối tháng chị còn lịch trống không ạ?',
            senderId: 'u-khachhang',
          ),
          StudioMessage(
            text: 'Chào em, cuối tháng chị còn ngày 28 và 30 nhé.',
            senderId: 'me',
          ),
          StudioMessage(
            text: 'Dạ em cảm ơn, để em sắp xếp rồi báo lại chị ạ.',
            senderId: 'u-khachhang',
          ),
        ],
      ),
    ];
  }

  void _update(
    String id,
    StudioConversation Function(StudioConversation) change,
  ) {
    state = [
      for (final conversation in state)
        if (conversation.id == id) change(conversation) else conversation,
    ];
  }

  void markRead(String id) =>
      _update(id, (conversation) => conversation.copyWith(unreadCount: 0));
  void toggleAi(String id, bool enabled) =>
      _update(id, (conversation) => conversation.copyWith(aiEnabled: enabled));
  void send(String id, String text, String senderId) => _update(
    id,
    (conversation) => conversation.copyWith(
      messages: [
        ...conversation.messages,
        StudioMessage(text: text.trim(), senderId: senderId),
      ],
    ),
  );

  /// The shared-message mock seam: an incoming client message triggers the
  /// portal's canned assistant reply or a human handoff when AI is enabled.
  void receiveFromClient(String id, String text) {
    final senderId = ref.read(authUserProvider)?.id;
    if (senderId == null || text.trim().isEmpty) return;
    final config = ref.read(assistantProvider);
    _update(id, (conversation) {
      if (conversation.participantIsPhotographer) return conversation;
      final handoff = AssistantRules.needsHandoff(text);
      final reply = conversation.aiEnabled
          ? StudioMessage(
              text: handoff
                  ? AssistantRules.handoffMessage
                  : AssistantRules.generateReply(config, text),
              senderId: senderId,
              isAi: true,
            )
          : null;
      return conversation.copyWith(
        messages: [
          ...conversation.messages,
          StudioMessage(
            text: text.trim(),
            senderId: conversation.participantId,
          ),
          ?reply,
        ],
        unreadCount: conversation.unreadCount + 1,
        aiEnabled: handoff ? false : conversation.aiEnabled,
      );
    });
  }
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<StudioConversation>>(
      ConversationsNotifier.new,
    );

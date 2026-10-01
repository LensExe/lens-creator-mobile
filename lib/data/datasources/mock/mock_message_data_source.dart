import '../../../features/photographer/messages/conversation_models.dart';

class MockMessageDataSource {
  static const _delay = Duration(milliseconds: 250);
  static final Map<String, List<StudioConversation>> _conversations = {
    'me': _seedDemoInbox(),
  };

  static List<StudioConversation> _seedDemoInbox() => [
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
          text: 'Chào em, chị đã nhận được yêu cầu rồi nhé. Chị xác nhận lịch luôn đây.',
          senderId: 'me',
        ),
        StudioMessage(text: 'Em cảm ơn chị nhiều ạ!', senderId: 'c-anh'),
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
        StudioMessage(
          text: 'Mình gặp ở đầu phố Hàng Mã lúc 8h sáng em nhé.',
          senderId: 'me',
        ),
        StudioMessage(
          text: 'Em cảm ơn chị, hẹn gặp chị cuối tuần nhé!',
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
          text: 'Chào anh, mình muốn hỏi về gói chụp cưới phóng sự ạ.',
          senderId: 'me',
        ),
        StudioMessage(
          text: 'Chào bạn, gói cưới của mình có 3 mức, tuỳ số giờ chụp.',
          senderId: 'p2',
        ),
        StudioMessage(
          text: 'Mình gửi bạn bảng giá gói chụp cưới nhé.',
          senderId: 'p2',
        ),
      ],
    ),
    StudioConversation(
      id: 'c4',
      participantId: 'c-em',
      participantName: 'Hoàng Thị Em',
      messages: [
        StudioMessage(
          text: 'Em ơi, chị đã giao toàn bộ ảnh đã chỉnh qua link rồi nhé.',
          senderId: 'me',
        ),
        StudioMessage(
          text: 'Ảnh đẹp lắm ạ, em rất thích luôn ❤️',
          senderId: 'c-em',
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
          text: 'Chào chị, em muốn hỏi cuối tháng chị còn lịch trống không ạ?',
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

  List<StudioConversation> cachedConversations(String userId) =>
      List.unmodifiable(_conversations[userId] ?? const []);

  Future<List<StudioConversation>> getConversations(String userId) async {
    await Future.delayed(_delay);
    return cachedConversations(userId);
  }

  Future<StudioConversation> getOrCreateConversation({
    required String userId,
    required String participantId,
    required String participantName,
  }) async {
    await Future.delayed(_delay);
    final conversations = _conversations.putIfAbsent(userId, () => []);
    for (final conversation in conversations) {
      if (conversation.participantId == participantId &&
          !conversation.participantIsPhotographer) {
        return conversation;
      }
    }
    final conversation = StudioConversation(
      id: 'thread-$participantId',
      participantId: participantId,
      participantName: participantName,
      messages: [],
    );
    conversations.add(conversation);
    return conversation;
  }

  Future<StudioConversation> markRead(
    String userId,
    String conversationId,
  ) async {
    await Future.delayed(_delay);
    return _update(
      userId,
      conversationId,
      (conversation) => conversation.copyWith(unreadCount: 0),
    );
  }

  Future<StudioConversation> setAssistantEnabled(
    String userId,
    String conversationId,
    bool enabled,
  ) async {
    await Future.delayed(_delay);
    return _update(
      userId,
      conversationId,
      (conversation) => conversation.copyWith(aiEnabled: enabled),
    );
  }

  Future<StudioConversation> sendMessage({
    required String userId,
    required String conversationId,
    required String text,
  }) async {
    await Future.delayed(_delay);
    final content = text.trim();
    if (content.isEmpty) throw StateError('Nhập nội dung tin nhắn');
    return _update(
      userId,
      conversationId,
      (conversation) => conversation.copyWith(
        messages: [
          ...conversation.messages,
          StudioMessage(text: content, senderId: userId),
        ],
      ),
    );
  }

  StudioConversation _update(
    String userId,
    String conversationId,
    StudioConversation Function(StudioConversation) change,
  ) {
    final conversations = _conversations[userId];
    if (conversations == null) throw StateError('Không tìm thấy hội thoại');
    final index = conversations.indexWhere((item) => item.id == conversationId);
    if (index < 0) throw StateError('Không tìm thấy hội thoại');
    final updated = change(conversations[index]);
    conversations[index] = updated;
    return updated;
  }
}

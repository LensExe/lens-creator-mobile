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

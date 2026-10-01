import 'conversation_models.dart';

abstract interface class MessageRepository {
  List<StudioConversation> cachedConversations(String userId);

  Future<List<StudioConversation>> getConversations(String userId);

  Future<StudioConversation> getOrCreateConversation({
    required String userId,
    required String participantId,
    required String participantName,
  });

  Future<StudioConversation> markRead(String userId, String conversationId);

  Future<StudioConversation> setAssistantEnabled(
    String userId,
    String conversationId,
    bool enabled,
  );

  Future<StudioConversation> sendMessage({
    required String userId,
    required String conversationId,
    required String text,
  });
}

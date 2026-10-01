import '../../features/photographer/messages/conversation_models.dart';
import '../../features/photographer/messages/message_repository.dart';
import '../datasources/mock/mock_message_data_source.dart';

class MessageRepositoryImpl implements MessageRepository {
  const MessageRepositoryImpl(this.dataSource);

  final MockMessageDataSource dataSource;

  @override
  List<StudioConversation> cachedConversations(String userId) =>
      dataSource.cachedConversations(userId);

  @override
  Future<List<StudioConversation>> getConversations(String userId) =>
      dataSource.getConversations(userId);

  @override
  Future<StudioConversation> getOrCreateConversation({
    required String userId,
    required String participantId,
    required String participantName,
  }) => dataSource.getOrCreateConversation(
    userId: userId,
    participantId: participantId,
    participantName: participantName,
  );

  @override
  Future<StudioConversation> markRead(String userId, String conversationId) =>
      dataSource.markRead(userId, conversationId);

  @override
  Future<StudioConversation> setAssistantEnabled(
    String userId,
    String conversationId,
    bool enabled,
  ) => dataSource.setAssistantEnabled(userId, conversationId, enabled);

  @override
  Future<StudioConversation> sendMessage({
    required String userId,
    required String conversationId,
    required String text,
  }) => dataSource.sendMessage(
    userId: userId,
    conversationId: conversationId,
    text: text,
  );
}

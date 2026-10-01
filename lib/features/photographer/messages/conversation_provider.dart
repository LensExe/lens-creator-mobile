import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/mock/mock_message_data_source.dart';
import '../../../data/repositories/message_repository_impl.dart';
import '../../../providers/data_providers.dart';
import '../assistant/assistant_provider.dart';
import '../assistant/assistant_rules.dart';
import 'conversation_models.dart';
import 'message_repository.dart';

export 'conversation_models.dart';

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepositoryImpl(MockMessageDataSource()),
);

class ConversationsNotifier extends Notifier<List<StudioConversation>> {
  @override
  List<StudioConversation> build() {
    final user = ref.watch(authUserProvider);
    if (user == null || user.role != 'photographer') return [];
    return ref.read(messageRepositoryProvider).cachedConversations(user.id);
  }

  Future<void> refresh() async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) return;
    state = await ref.read(messageRepositoryProvider).getConversations(userId);
  }

  void _replace(StudioConversation updated) {
    state = [
      for (final conversation in state)
        if (conversation.id == updated.id) updated else conversation,
    ];
  }

  Future<void> markRead(String id) async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) return;
    _replace(await ref.read(messageRepositoryProvider).markRead(userId, id));
  }

  Future<String> openOrCreateForClient({
    required String participantId,
    required String participantName,
  }) async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập lại');
    final conversation = await ref
        .read(messageRepositoryProvider)
        .getOrCreateConversation(
          userId: userId,
          participantId: participantId,
          participantName: participantName,
        );
    if (!state.any((item) => item.id == conversation.id)) {
      state = [...state, conversation];
    }
    return conversation.id;
  }

  Future<void> toggleAi(String id, bool enabled) async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập lại');
    _replace(
      await ref
          .read(messageRepositoryProvider)
          .setAssistantEnabled(userId, id, enabled),
    );
  }

  Future<void> send(String id, String text) async {
    final userId = ref.read(authUserProvider)?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập lại');
    _replace(
      await ref
          .read(messageRepositoryProvider)
          .sendMessage(userId: userId, conversationId: id, text: text),
    );
  }

  /// Mock inbound event seam used by the demo assistant flow and tests.
  void receiveFromClient(String id, String text) {
    final senderId = ref.read(authUserProvider)?.id;
    if (senderId == null || text.trim().isEmpty) return;
    final config = ref.read(assistantProvider);
    _update(id, (conversation) {
      if (conversation.participantIsPhotographer) return conversation;
      final handoff = AssistantRules.needsHandoff(text);
      final reply = conversation.aiEnabled && config.enabled
          ? StudioMessage(
              text: handoff
                  ? AssistantRules.handoffMessage
                  : AssistantRules.generateReply(config, text),
              senderId: 'ai',
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

  void _update(
    String id,
    StudioConversation Function(StudioConversation) change,
  ) {
    state = [
      for (final conversation in state)
        if (conversation.id == id) change(conversation) else conversation,
    ];
  }
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<StudioConversation>>(
      ConversationsNotifier.new,
    );

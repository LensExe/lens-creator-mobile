import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conversation_models.dart';

export 'conversation_models.dart';

const _messagingUnavailable =
    'Backend hiện chưa cung cấp API cho tính năng tin nhắn.';

class ConversationsNotifier extends Notifier<List<StudioConversation>> {
  @override
  List<StudioConversation> build() => [];

  Future<void> refresh() async => throw StateError(_messagingUnavailable);

  Future<void> markRead(String id) async =>
      throw StateError(_messagingUnavailable);

  Future<String> openOrCreateForClient({
    required String participantId,
    required String participantName,
  }) async => throw StateError(_messagingUnavailable);

  Future<void> toggleAi(String id, bool enabled) async =>
      throw StateError(_messagingUnavailable);

  Future<void> send(String id, String text) async =>
      throw StateError(_messagingUnavailable);

  void receiveFromClient(String id, String text) =>
      throw StateError(_messagingUnavailable);
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<StudioConversation>>(
      ConversationsNotifier.new,
    );

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/models.dart';
import 'conversation_provider.dart';

Future<void> openClientConversation(
  BuildContext context,
  WidgetRef ref,
  Booking booking,
) async {
  final conversationId = await ref
      .read(conversationsProvider.notifier)
      .openOrCreateForClient(
        participantId: booking.clientId,
        participantName: booking.clientName,
      );
  if (context.mounted) {
    context.push('/photographer_home/messages/$conversationId');
  }
}

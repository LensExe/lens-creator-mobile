import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import '../../../../providers/data_providers.dart';
import 'studio_booking_card.dart';

class CollaborationInvites extends ConsumerStatefulWidget {
  const CollaborationInvites({super.key});

  @override
  ConsumerState<CollaborationInvites> createState() => _CollaborationInvitesState();
}

class _CollaborationInvitesState extends ConsumerState<CollaborationInvites> {
  String? responding;

  Future<void> _respond(Booking booking, CollaborationStatus status) async {
    setState(() => responding = booking.id);
    try {
      await ref.read(asyncBookingsProvider.notifier)
          .respondToCollaboration(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == CollaborationStatus.accepted
              ? 'Đã đồng ý tham gia buổi chụp' : 'Đã từ chối lời mời')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể phản hồi: $error')));
      }
    } finally {
      if (mounted) setState(() => responding = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider);
    final invites = ref.watch(myCollaborationsProvider).where((booking) =>
        booking.collaborators.any((item) => item.photographerId == user?.id &&
            item.status == CollaborationStatus.invited)).toList();
    if (invites.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Lời mời liên kết', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      for (final booking in invites) Builder(builder: (context) {
        final entry = booking.collaborators.firstWhere((item) => item.photographerId == user!.id);
        final amount = (BookingRules.payout(booking.price) * entry.sharePct / 100).round();
        return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${booking.photographerName} mời bạn cùng chụp',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('${booking.style} · ${booking.date} · ${booking.location}'),
            const SizedBox(height: 6),
            Text('Tỷ lệ ${entry.sharePct}% · nhận ${formatDong(amount)}'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton(onPressed: responding == booking.id ? null : () =>
                  _respond(booking, CollaborationStatus.declined), child: const Text('Từ chối')),
              FilledButton(onPressed: responding == booking.id ? null : () =>
                  _respond(booking, CollaborationStatus.accepted), child: const Text('Đồng ý')),
            ]),
          ],
        )));
      }),
      const SizedBox(height: 16),
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';
import '../../../../providers/data_providers.dart';
import 'studio_booking_card.dart';

class CollaboratorsPanel extends ConsumerWidget {
  const CollaboratorsPanel({super.key, required this.booking});
  final Booking booking;

  Future<void> _invite(
    BuildContext context,
    WidgetRef ref,
    int remaining,
  ) async {
    final taken = {
      booking.photographerId,
      ...booking.collaborators.map((item) => item.photographerId),
    };
    final options = ref
        .read(photographersProvider)
        .where((photographer) => !taken.contains(photographer.id))
        .toList();
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không còn nhiếp ảnh gia để mời')),
      );
      return;
    }
    String? selected;
    final controller = TextEditingController();
    final result = await showDialog<(String, int)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Mời thợ cùng chụp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Còn $remaining% có thể chia trên số thực nhận.'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Nhiếp ảnh gia'),
                items: [
                  for (final option in options)
                    DropdownMenuItem(
                      value: option.id,
                      child: Text('${option.name} · ${option.city}'),
                    ),
                ],
                onChanged: (value) => setDialog(() => selected = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                onChanged: (_) => setDialog(() {}),
                decoration: const InputDecoration(labelText: 'Tỷ lệ chia (%)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed:
                  selected == null ||
                      (int.tryParse(controller.text) ?? 0) <= 0 ||
                      (int.tryParse(controller.text) ?? 0) > remaining
                  ? null
                  : () => Navigator.pop(context, (
                      selected!,
                      int.parse(controller.text),
                    )),
              child: const Text('Gửi lời mời'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null || !context.mounted) return;
    final chosen = options.firstWhere((item) => item.id == result.$1);
    try {
      await ref
          .read(asyncBookingsProvider.notifier)
          .inviteCollaborator(booking.id, chosen, result.$2);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đã mời ${chosen.name}')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi lời mời: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = booking.collaborators.fold<int>(
      0,
      (sum, item) => sum + item.sharePct,
    );
    final remaining = 100 - used;
    final payout = BookingRules.payout(booking.price);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liên kết thợ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Tất cả thợ được mời phải đồng ý trước buổi chụp.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text('${booking.photographerName} (bạn)'),
            Text(
              '$remaining% · ${formatDong((payout * remaining / 100).round())}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            for (final collaborator in booking.collaborators)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collaborator.photographerName),
                    Text(switch (collaborator.status) {
                      CollaborationStatus.invited => 'Đã mời · chờ phản hồi',
                      CollaborationStatus.accepted => 'Đã đồng ý',
                      CollaborationStatus.declined => 'Đã từ chối',
                    }, style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '${collaborator.sharePct}% · ${formatDong((payout * collaborator.sharePct / 100).round())}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            if (remaining > 0 && booking.deliveredPhotos == 0)
              OutlinedButton.icon(
                onPressed: () => _invite(context, ref, remaining),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Mời thêm thợ'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';

enum StorageTier { free, pro, studio }

class StoragePlan {
  const StoragePlan(
    this.tier,
    this.name,
    this.quotaGb,
    this.retentionDays,
    this.price,
  );
  final StorageTier tier;
  final String name;
  final int quotaGb;
  final int? retentionDays;
  final String price;
}

const storagePlans = [
  StoragePlan(StorageTier.free, 'Free', 2, 30, 'Miễn phí'),
  StoragePlan(StorageTier.pro, 'Pro', 10, 365, '99.000 ₫/tháng'),
  StoragePlan(StorageTier.studio, 'Studio', 30, null, '249.000 ₫/tháng'),
];

class StorageTierNotifier extends Notifier<StorageTier> {
  @override
  StorageTier build() {
    ref.watch(authUserProvider.select((user) => user?.id));
    return StorageTier.free;
  }

  void choose(StorageTier tier) => state = tier;
}

final storageTierProvider = NotifierProvider<StorageTierNotifier, StorageTier>(
  StorageTierNotifier.new,
);

const storageMb = 1024 * 1024;
final _fixtureCreatedAt = DateTime.now();

class StorageGallery {
  const StorageGallery({
    required this.booking,
    required this.sizeBytes,
    required this.deliveredAt,
    required this.expiresAt,
    required this.locked,
  });
  final Booking booking;
  final int sizeBytes;
  final DateTime deliveredAt;
  final DateTime? expiresAt;
  final bool locked;

  int? get daysLeft => expiresAt == null
      ? null
      : (expiresAt!.difference(DateTime.now()).inHours / 24).ceil();
  bool get needsAttention => locked || (daysLeft != null && daysLeft! <= 7);
}

/// The two portal demo galleries retain their seeded byte sizes and delivery
/// dates. New mock uploads use the portal's 90 MB/photo placeholder size.
final storageGalleriesProvider = Provider<List<StorageGallery>>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) return [];
  final tier = ref.watch(storageTierProvider);
  final plan = storagePlans.firstWhere((item) => item.tier == tier);
  final bookings = ref.watch(myBookingsProvider);
  final now = DateTime.now();
  final galleries = <StorageGallery>[];
  for (final booking in bookings) {
    if (booking.deliveredPhotos == 0) continue;
    final sizeBytes = switch (booking.id) {
      'in-5' => 12 * 118 * storageMb,
      'in-6' =>
        14 * 205 * storageMb + (booking.deliveredPhotos - 14) * 90 * storageMb,
      _ => booking.deliveredPhotos * 90 * storageMb,
    };
    final deliveredAt = switch (booking.id) {
      'in-5' => _fixtureCreatedAt.subtract(const Duration(days: 9)),
      'in-6' => _fixtureCreatedAt.subtract(const Duration(days: 2)),
      _ => now,
    };
    galleries.add(
      StorageGallery(
        booking: booking,
        sizeBytes: sizeBytes,
        deliveredAt: deliveredAt,
        expiresAt: plan.retentionDays == null
            ? null
            : deliveredAt.add(Duration(days: plan.retentionDays!)),
        locked: sizeBytes > plan.quotaGb * 1024 * storageMb,
      ),
    );
  }
  return galleries;
});

String formatStorageBytes(int bytes) => bytes >= 1024 * storageMb
    ? '${(bytes / (1024 * storageMb)).toStringAsFixed(1).replaceAll('.', ',')} GB'
    : '${(bytes / storageMb).round()} MB';

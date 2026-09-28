import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:lens_creator_mobile/core/widgets/primary_button.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';

class StorageSummary {
  final String plan;
  final int usedBytes;
  final int quotaBytesPerShoot;
  final int galleryCount;
  final int? retentionDays;

  StorageSummary({
    required this.plan,
    required this.usedBytes,
    required this.quotaBytesPerShoot,
    required this.galleryCount,
    this.retentionDays,
  });
}

class StoragePlan {
  final String id;
  final String name;
  final String priceLabel;
  final String highlight;

  StoragePlan({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.highlight,
  });
}

class ShootGallery {
  final String bookingId;
  final String clientName;
  final String style;
  final int photoCount;
  final int sizeBytes;
  final DateTime? expiresAt;
  final bool locked;

  ShootGallery({
    required this.bookingId,
    required this.clientName,
    required this.style,
    required this.photoCount,
    required this.sizeBytes,
    this.expiresAt,
    required this.locked,
  });
}

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final summary = StorageSummary(
      plan: 'Basic',
      usedBytes: 2576980377, // ~2.4 GB
      quotaBytesPerShoot: 5368709120, // 5 GB
      galleryCount: 12,
      retentionDays: 30,
    );

    final plans = [
      StoragePlan(
        id: 'basic',
        name: 'Gói Basic',
        priceLabel: 'Miễn phí',
        highlight: '5GB/buổi, lưu 30 ngày',
      ),
      StoragePlan(
        id: 'pro',
        name: 'Gói Pro',
        priceLabel: '199.000đ/tháng',
        highlight: '100GB/buổi, lưu 1 năm',
      ),
      StoragePlan(
        id: 'unlimited',
        name: 'Không Giới Hạn',
        priceLabel: '499.000đ/tháng',
        highlight: 'Vô hạn, lưu dài hạn',
      ),
    ];

    final galleries = [
      ShootGallery(
        bookingId: 'bk-1',
        clientName: 'Nguyễn Văn A',
        style: 'Chân dung',
        photoCount: 45,
        sizeBytes: 450000000,
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        locked: false,
      ),
      ShootGallery(
        bookingId: 'bk-2',
        clientName: 'Trần Thị B',
        style: 'Tiệc cưới',
        photoCount: 300,
        sizeBytes: 2100000000,
        expiresAt: DateTime.now().add(const Duration(days: 28)),
        locked: false,
      ),
      ShootGallery(
        bookingId: 'bk-3',
        clientName: 'Lê Hoàng C',
        style: 'Sự kiện',
        photoCount: 150,
        sizeBytes: 1200000000,
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
        locked: true, // Mocking an expired and locked gallery
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.mist,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lưu trữ ảnh',
              style: TextStyle(
                color: AppColors.obsidian,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quản lý dung lượng và gói lưu trữ ảnh cho các buổi chụp.',
              style: TextStyle(color: AppColors.steel, fontSize: 15),
            ),
            const SizedBox(height: 32),

            // Usage Overview
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.storage,
                            color: AppColors.obsidian,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Đã dùng',
                            style: TextStyle(
                              color: AppColors.obsidian,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      LensBadge(
                        text: 'Gói ${summary.plan}',
                        type: BadgeType.darkOverlay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      formatBytes(summary.usedBytes),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.obsidian,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: summary.usedBytes / summary.quotaBytesPerShoot,
                    backgroundColor: AppColors.pebble,
                    color: AppColors.obsidian,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.fog),
                  const SizedBox(height: 16),
                  Text(
                    '${summary.galleryCount} buổi · ${formatBytes(summary.quotaBytesPerShoot)} mỗi buổi · Lưu ${summary.retentionDays ?? "dài hạn"} ngày',
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Plans
            const Text(
              'Gói lưu trữ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.obsidian,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isActive = plan.name.contains(summary.plan);

                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.obsidian : AppColors.pebble,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Color(0x1A000000),
                                offset: Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.obsidian,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan.priceLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: AppColors.obsidian,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            plan.highlight,
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isActive)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.fog,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Đang dùng',
                                style: TextStyle(
                                  color: AppColors.steel,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Chọn gói',
                              onPressed: () {},
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Delivered Galleries
            const Text(
              'Bộ sưu tập đã giao',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.obsidian,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: galleries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final gallery = galleries[index];

                // Calculate days
                String expireLabel = 'Dài hạn';
                Color expireColor = AppColors.steel;
                IconData expireIcon = Icons.all_inclusive;

                if (gallery.locked) {
                  expireLabel = 'Đã khóa';
                  expireIcon = Icons.lock_outline;
                } else if (gallery.expiresAt != null) {
                  final diff = gallery.expiresAt!
                      .difference(DateTime.now())
                      .inDays;
                  if (diff < 0) {
                    expireLabel = 'Hết hạn';
                    expireColor = AppColors.ember;
                    expireIcon = Icons.error_outline;
                  } else {
                    expireLabel = 'Còn $diff ngày';
                    if (diff <= 7) {
                      expireColor = AppColors.ember;
                    }
                    expireIcon = Icons.schedule;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    // Navigate to detail view (mock logic)
                    context.push(
                      '/photographer_home/booking/${gallery.bookingId}',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.pebble),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.fog,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: AppColors.obsidian,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${gallery.style} · ${gallery.clientName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.obsidian,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${gallery.photoCount} ảnh · ${formatBytes(gallery.sizeBytes)}',
                                style: const TextStyle(
                                  color: AppColors.steel,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(expireIcon, size: 16, color: expireColor),
                            const SizedBox(height: 4),
                            Text(
                              expireLabel,
                              style: TextStyle(
                                color: expireColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

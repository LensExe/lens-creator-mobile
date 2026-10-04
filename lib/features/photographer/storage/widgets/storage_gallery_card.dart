import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../storage_provider.dart';

class StorageGalleryCard extends StatelessWidget {
  const StorageGalleryCard({super.key, required this.gallery});

  final StorageGallery gallery;

  ({Color foreground, Color background, String label}) get _status {
    if (gallery.locked) {
      return (
        foreground: AppColors.destructive,
        background: const Color(0xFFFFECEA),
        label: 'Đã khóa',
      );
    }
    if (gallery.daysLeft != null && gallery.daysLeft! <= 0) {
      return (
        foreground: AppColors.steel,
        background: AppColors.mist,
        label: 'Hết hạn',
      );
    }
    if (gallery.daysLeft != null && gallery.daysLeft! <= 7) {
      return (
        foreground: const Color(0xFFB45C16),
        background: const Color(0xFFFFF4E5),
        label: 'Sắp hết hạn',
      );
    }
    return (
      foreground: const Color(0xFF16865A),
      background: const Color(0xFFE8F6EF),
      label: 'Đang lưu',
    );
  }

  String get _retentionLabel {
    final daysLeft = gallery.daysLeft;
    if (daysLeft == null) return 'Lưu dài hạn theo gói';
    if (daysLeft <= 0) return 'Đã hết hạn';
    return 'Còn $daysLeft ngày';
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final booking = gallery.booking;
    final deliveredDate = DateFormat('dd/MM/yyyy').format(gallery.deliveredAt);
    final thumbnailUrl = booking.deliveredPhotoUrls.isEmpty
        ? null
        : booking.deliveredPhotoUrls.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          onTap: () =>
              context.push('/photographer_home/booking/${booking.id}/gallery'),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                _GalleryThumbnail(url: thumbnailUrl, locked: gallery.locked),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${booking.style} · ${booking.clientName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status.background,
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusPill,
                              ),
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(
                                color: status.foreground,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${booking.deliveredPhotos} ảnh · ${formatStorageBytes(gallery.sizeBytes)}',
                        style: const TextStyle(
                          color: AppColors.graphite,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giao $deliveredDate · $_retentionLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.steel,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.ash,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({required this.url, required this.locked});

  final String? url;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final image = url == null
        ? const ColoredBox(
            color: Color(0xFFFFF0E8),
            child: Center(
              child: Icon(
                Icons.photo_library_outlined,
                color: AppColors.ember,
                size: 23,
              ),
            ),
          )
        : Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFFFFF0E8),
              child: Center(
                child: Icon(
                  Icons.photo_outlined,
                  color: AppColors.ember,
                  size: 23,
                ),
              ),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (locked) ...[
              const ColoredBox(color: Color(0x880F1012)),
              const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

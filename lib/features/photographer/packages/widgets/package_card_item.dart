import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';
import '../../bookings/widgets/studio_booking_card.dart' show formatDong;

class PackageCardItem extends StatelessWidget {
  const PackageCardItem({super.key, required this.package});

  final PhotographerPackage package;

  @override
  Widget build(BuildContext context) {
    final hours =
        package.durationHours == package.durationHours.truncateToDouble()
        ? package.durationHours.toStringAsFixed(0)
        : package.durationHours.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.fog),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: InkWell(
          onTap: () =>
              context.push('/photographer_home/packages/edit/${package.id}'),
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.emberSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.ember,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.obsidian,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: -0.25,
                            ),
                          ),
                          if (package.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              package.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.steel,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      size: 17,
                      color: AppColors.ash,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1),
                ),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _PackageFact(
                      icon: Icons.timelapse_outlined,
                      label: '$hours giờ',
                    ),
                    _PackageFact(
                      icon: Icons.photo_library_outlined,
                      label: '${package.photoCount} ảnh',
                    ),
                    _PackageFact(
                      icon: Icons.local_shipping_outlined,
                      label: '${package.deliveryDays} ngày',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'GIÁ GÓI',
                        style: TextStyle(
                          color: AppColors.steel,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    Text(
                      formatDong(package.price),
                      style: const TextStyle(
                        color: AppColors.obsidian,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageFact extends StatelessWidget {
  const _PackageFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.graphite),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

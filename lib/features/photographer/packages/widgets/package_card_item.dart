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
    final hours = package.durationHours.toStringAsFixed(1);
    final editRoute = '/photographer_home/packages/edit/${package.id}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push(editRoute),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatDong(package.price),
                            style: const TextStyle(
                              color: AppColors.ember,
                              fontSize: 20,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: IconButton(
                        tooltip: 'Chỉnh sửa ${package.name}',
                        onPressed: () => context.push(editRoute),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.graphite,
                          backgroundColor: const Color(0xFFEEEEEF),
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                    ),
                  ],
                ),
                if (package.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    package.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PackageFact(
                      icon: Icons.photo_library_outlined,
                      label: '${package.photoCount} ảnh',
                    ),
                    _PackageFact(
                      icon: Icons.schedule_outlined,
                      label: '$hours giờ',
                    ),
                    _PackageFact(
                      icon: Icons.local_shipping_outlined,
                      label: 'Giao trong ${package.deliveryDays} ngày',
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
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFFEEEEEF),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.steel),
        const SizedBox(width: 6),
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

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
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: AppColors.snow,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      side: const BorderSide(color: AppColors.fog),
    ),
    child: InkWell(
      onTap: () =>
          context.push('/photographer_home/packages/edit/${package.id}'),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_camera_back_outlined,
                    color: AppColors.ember,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.obsidian,
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (package.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            package.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.graphite,
                    size: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _PackageSpec(
                  icon: Icons.photo_library_outlined,
                  label: '${package.photoCount} ảnh',
                  highlighted: true,
                ),
                _PackageSpec(
                  icon: Icons.schedule_rounded,
                  label: '${_formatHours(package.durationHours)} giờ',
                ),
                _PackageSpec(
                  icon: Icons.local_shipping_outlined,
                  label: 'Giao trong ${package.deliveryDays} ngày',
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.fog),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GIÁ GÓI CHỤP',
                        style: TextStyle(
                          color: AppColors.ash,
                          fontSize: 9,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatDong(package.price),
                        style: const TextStyle(
                          color: AppColors.ember,
                          fontSize: 19,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.ash,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  String _formatHours(double hours) => hours == hours.truncateToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toString();
}

class _PackageSpec extends StatelessWidget {
  const _PackageSpec({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: highlighted ? const Color(0xFFFFF0E8) : AppColors.mist,
      borderRadius: BorderRadius.circular(9),
      border: highlighted ? Border.all(color: const Color(0xFFFFD8C3)) : null,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: highlighted ? AppColors.ember : AppColors.steel,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: highlighted ? AppColors.graphite : AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

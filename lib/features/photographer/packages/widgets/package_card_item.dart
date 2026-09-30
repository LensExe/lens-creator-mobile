import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/creator_list_row.dart';
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
    return Column(
      children: [
        CreatorListRow(
          icon: Icons.photo_camera_outlined,
          title: package.name,
          subtitle: package.description.trim().isEmpty
              ? null
              : package.description,
          onTap: () =>
              context.push('/photographer_home/packages/edit/${package.id}'),
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  '${package.photoCount} ảnh · $hours giờ · Giao ${package.deliveryDays} ngày',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.steel, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDong(package.price),
                style: const TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

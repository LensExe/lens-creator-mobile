import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/creator_empty_state.dart';
import '../../../../core/widgets/creator_media_surface.dart';

class PortfolioPhotoGrid extends StatelessWidget {
  const PortfolioPhotoGrid({super.key, required this.photos, this.onRemove});

  final List<String> photos;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const CreatorEmptyState(
        icon: Icons.photo_library_outlined,
        title: 'Chưa có tác phẩm',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: photos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CreatorMediaSurface(
                  imageUrl: photos[index],
                  radius: 16,
                  placeholderIcon: Icons.broken_image_outlined,
                ),
                if (onRemove != null)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Material(
                      color: AppColors.obsidian.withValues(alpha: 0.72),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Xoá ảnh',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onRemove!(index),
                        color: AppColors.snow,
                        iconSize: 17,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

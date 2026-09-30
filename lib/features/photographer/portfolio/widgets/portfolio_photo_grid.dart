import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class PortfolioPhotoGrid extends StatelessWidget {
  const PortfolioPhotoGrid({super.key, required this.photos, this.onRemove});

  final List<String> photos;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 27),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(color: AppColors.fog),
        ),
        child: const Column(
          children: [
            Icon(Icons.photo_library_outlined, size: 28, color: AppColors.ash),
            SizedBox(height: 8),
            Text(
              'Chưa có tác phẩm',
              style: TextStyle(
                color: AppColors.graphite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fog),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x07000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppColors.fog,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.ash,
                        ),
                      ),
                    ),
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded || frame != null) {
                            return child;
                          }
                          return const ColoredBox(
                            color: AppColors.mist,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.ember,
                                ),
                              ),
                            ),
                          );
                        },
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
          ),
        );
      },
    );
  }
}

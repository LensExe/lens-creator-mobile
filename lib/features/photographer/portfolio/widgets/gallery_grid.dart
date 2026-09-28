import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';

class GalleryGrid extends StatelessWidget {
  final String category;

  const GalleryGrid({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Generate dummy image URLs for UI purposes
    final List<String> imageUrls = List.generate(
      15,
      (index) => 'https://picsum.photos/seed/${category}_$index/400/400',
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.pebble,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.steel,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.pebble,
                  child: const Icon(Icons.error, color: AppColors.steel),
                ),
              ),
            )
            .animate()
            .fade(duration: 400.ms, delay: (index * 50).ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              duration: 400.ms,
              delay: (index * 50).ms,
            );
      },
    );
  }
}

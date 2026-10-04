import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_empty_state.dart';
import '../../../../core/widgets/creator_media_surface.dart';

class PortfolioPhotoGrid extends StatelessWidget {
  const PortfolioPhotoGrid({
    super.key,
    required this.photos,
    this.onRemove,
    this.styles = const [],
  });

  final List<String> photos;
  final ValueChanged<int>? onRemove;
  final List<String> styles;

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
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final category = styles.isNotEmpty
                ? styles[index % styles.length]
                : 'Tác phẩm';
            final title = 'Tác phẩm #${index + 1}';

            return ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CreatorMediaSurface(
                      imageUrl: photos[index],
                      radius: 14,
                      placeholderIcon: Icons.broken_image_outlined,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x20000000),
                            Color(0xB3000000),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Top Right Button
                    Positioned(
                      top: 7,
                      right: 7,
                      child: onRemove != null
                          ? Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                tooltip: 'Xoá ảnh',
                                padding: EdgeInsets.zero,
                                onPressed: () => onRemove!(index),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.more_vert,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    // Bottom Info
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

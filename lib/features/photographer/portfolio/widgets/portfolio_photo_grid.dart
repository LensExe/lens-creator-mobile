import 'package:flutter/material.dart';

import '../../../../core/widgets/creator_empty_state.dart';
import '../../../../core/widgets/creator_media_surface.dart';

class PortfolioPhotoGrid extends StatelessWidget {
  const PortfolioPhotoGrid({
    super.key,
    required this.photos,
    this.onRemove,
    this.onMove,
  });

  final List<String> photos;
  final ValueChanged<int>? onRemove;
  final void Function(int index, int delta)? onMove;

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
                    // Actions
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onMove != null)
                            _PhotoAction(
                              tooltip: 'Đưa ảnh lên trước',
                              icon: Icons.arrow_back_ios_new_rounded,
                              onPressed: () => onMove!(index, -1),
                            ),
                          if (onMove != null)
                            _PhotoAction(
                              tooltip: 'Đưa ảnh ra sau',
                              icon: Icons.arrow_forward_ios_rounded,
                              onPressed: () => onMove!(index, 1),
                            ),
                          if (onRemove != null)
                            _PhotoAction(
                              tooltip: 'Xoá ảnh khỏi portfolio',
                              icon: Icons.delete_outline_rounded,
                              onPressed: () => onRemove!(index),
                            ),
                        ],
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
                          const Text(
                            'Tác phẩm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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

class _PhotoAction extends StatelessWidget {
  const _PhotoAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    margin: const EdgeInsets.only(left: 3),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.52),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: Colors.white),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/creator_avatar.dart';
import '../../../../domain/models/models.dart';

class PortfolioProfileHeader extends StatelessWidget {
  const PortfolioProfileHeader({
    super.key,
    required this.profile,
    this.onEdit,
    this.onPreview,
  });

  final Photographer profile;
  final VoidCallback? onEdit;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Cover Banner
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 208,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (profile.cover.isNotEmpty)
                  Image.network(
                    profile.cover,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _CoverPlaceholder(),
                  )
                else
                  const _CoverPlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x40000000),
                        Colors.transparent,
                        Color(0x99000000),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                // Top Left: Eyebrow Tag
                const Positioned(top: 12, left: 12, child: _HeroLabel()),
                // Top Right: Floating Booking Status Chip
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5A00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Đang nhận lịch',
                          style: TextStyle(
                            color: Color(0xFF1A1C1D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Avatar & Mode Selector Row (Overlapping Cover)
        Transform.translate(
          offset: const Offset(0, -36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar with verified badge
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CreatorAvatar(
                              name: profile.name,
                              imageUrl: profile.avatar,
                              size: 80,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5A00),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x20000000),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Mode Toggle Chip: Chỉnh sửa / Xem công khai
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E9),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(9999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x12000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Color(0xFFFF5A00),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Chỉnh sửa',
                                        style: TextStyle(
                                          color: Color(0xFF1A1C1D),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              InkWell(
                                onTap: onPreview,
                                borderRadius: BorderRadius.circular(9999),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 14,
                                        color: Color(0xFF5F5E60),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Xem công khai',
                                        style: TextStyle(
                                          color: Color(0xFF5F5E60),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Name & Camera Icon
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1A1C1D),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Color(0xFFFF5A00),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location & Experience
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 15,
                      color: Color(0xFF5F5E60),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${profile.city} • ${profile.experienceYears} năm kinh nghiệm',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5F5E60),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating & Stat Micro Bar
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFFF5A00),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          profile.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF1A1C1D),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${profile.reviewCount} đánh giá)',
                          style: const TextStyle(
                            color: Color(0xFF5F5E60),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Text('•', style: TextStyle(color: Color(0xFFC8C6C8))),
                    Text(
                      'Hoàn thành ${profile.portfolio.length} bộ ảnh',
                      style: const TextStyle(
                        color: Color(0xFF5F5E60),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.camera_alt_outlined, color: Colors.white, size: 12),
        SizedBox(width: 5),
        Text(
          'HỒ SƠ NĂNG LỰC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF5D5E66),
    child: Center(
      child: Icon(
        Icons.photo_camera_back_outlined,
        color: Color(0xFFA1A1AA),
        size: 40,
      ),
    ),
  );
}

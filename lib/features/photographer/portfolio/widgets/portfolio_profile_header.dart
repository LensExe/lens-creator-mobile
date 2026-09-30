import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';

class PortfolioProfileHeader extends StatelessWidget {
  const PortfolioProfileHeader({super.key, required this.profile});

  final Photographer profile;

  String get _initial {
    final name = profile.name.trim();
    return name.isEmpty ? 'L' : name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 238,
    decoration: BoxDecoration(
      color: AppColors.graphite,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
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
                  Color(0x10000000),
                  Color(0x16000000),
                  Color(0xC9000000),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          const Positioned(top: 13, left: 14, child: _HeroLabel()),
          Positioned(
            left: 15,
            right: 14,
            bottom: 15,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.snow,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.fog,
                    foregroundImage: profile.avatar.isEmpty
                        ? null
                        : NetworkImage(profile.avatar),
                    onForegroundImageError: profile.avatar.isEmpty
                        ? null
                        : (_, _) {},
                    child: Text(
                      _initial,
                      style: const TextStyle(
                        color: AppColors.graphite,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.snow,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${profile.city} · ${profile.experienceYears} năm kinh nghiệm',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFE8E8E8),
                            fontSize: 10,
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
        ],
      ),
    ),
  );
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.34),
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.camera_alt_outlined, color: AppColors.snow, size: 13),
        SizedBox(width: 5),
        Text(
          'HỒ SƠ NHIẾP ẢNH GIA',
          style: TextStyle(
            color: AppColors.snow,
            fontSize: 8,
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
    color: AppColors.graphite,
    child: Center(
      child: Icon(
        Icons.photo_camera_back_outlined,
        color: AppColors.ash,
        size: 40,
      ),
    ),
  );
}

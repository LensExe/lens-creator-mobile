import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/models/models.dart';
import '../../bookings/widgets/studio_booking_card.dart' show formatDong;
import 'portfolio_photo_grid.dart';
import 'portfolio_profile_header.dart';
import 'portfolio_stats_card.dart';

class PortfolioProfileView extends StatelessWidget {
  const PortfolioProfileView({
    super.key,
    required this.profile,
    required this.onPreview,
    required this.onEdit,
  });

  final Photographer profile;
  final VoidCallback onPreview;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
    children: [
      PortfolioProfileHeader(profile: profile),
      const SizedBox(height: 11),
      PortfolioStatsCard(profile: profile),
      if (profile.styles.isNotEmpty) ...[
        const SizedBox(height: 18),
        const _SectionHeading(
          title: 'Phong cách chụp',
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final style in profile.styles)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.snow,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  border: Border.all(color: AppColors.fog),
                ),
                child: Text(
                  style,
                  style: const TextStyle(
                    color: AppColors.graphite,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: 18),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(title: 'Giới thiệu', icon: Icons.notes_rounded),
          const SizedBox(height: 9),
          Text(
            profile.bio,
            style: const TextStyle(
              color: AppColors.graphite,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.fog),
          ),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppColors.ember,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Giá khởi điểm',
                  style: TextStyle(
                    color: AppColors.steel,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                formatDong(profile.pricePerSession),
                style: const TextStyle(
                  color: AppColors.ember,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const Expanded(
            child: _SectionHeading(
              title: 'Tác phẩm',
              icon: Icons.photo_library_outlined,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(color: AppColors.fog),
            ),
            child: Text(
              '${profile.portfolio.length} ảnh',
              style: const TextStyle(
                color: AppColors.steel,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      PortfolioPhotoGrid(photos: profile.portfolio),
      const SizedBox(height: 18),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onPreview,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.graphite,
              backgroundColor: AppColors.snow,
              side: const BorderSide(color: AppColors.fog),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 17),
            label: const Text(
              'Xem hồ sơ công khai',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 9),
          FilledButton.icon(
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.obsidian,
              foregroundColor: AppColors.snow,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text(
              'Chỉnh sửa',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ],
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.ember, size: 17),
      const SizedBox(width: 7),
      Text(
        title,
        style: const TextStyle(
          color: AppColors.obsidian,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

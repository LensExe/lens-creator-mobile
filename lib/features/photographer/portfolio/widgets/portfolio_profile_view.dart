import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/models.dart';
import 'portfolio_photo_grid.dart';
import 'portfolio_profile_header.dart';

class PortfolioProfileView extends StatelessWidget {
  const PortfolioProfileView({
    super.key,
    required this.profile,
    required this.onPreview,
    required this.onEdit,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onMovePhoto,
    required this.portfolioName,
    required this.uploading,
    required this.uploadProgress,
  });

  final Photographer profile;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;
  final void Function(int index, int delta) onMovePhoto;
  final String? portfolioName;
  final bool uploading;
  final double uploadProgress;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
    children: [
      const Text(
        'HỒ SƠ NĂNG LỰC',
        style: TextStyle(
          color: AppColors.steel,
          fontSize: 11,
          letterSpacing: 1.15,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      PortfolioProfileHeader(
        profile: profile,
        onEdit: onEdit,
        onPreview: onPreview,
      ),
      const SizedBox(height: 14),
      _ProfileDetailsCard(profile: profile, onEdit: onEdit),
      const SizedBox(height: 20),
      _PortfolioGallerySection(
        profile: profile,
        portfolioName: portfolioName,
        uploading: uploading,
        uploadProgress: uploadProgress,
        onAddPhoto: onAddPhoto,
        onRemovePhoto: onRemovePhoto,
        onMovePhoto: onMovePhoto,
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPreview,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1C1D),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFEEEEEF)),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 17),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Xem hồ sơ công khai',
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: onEdit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF5A00),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Chỉnh sửa',
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({required this.profile, required this.onEdit});

  final Photographer profile;
  final VoidCallback onEdit;

  IconData _iconForStyle(String style) {
    final lower = style.toLowerCase();
    if (lower.contains('chân dung')) return Icons.face;
    if (lower.contains('gia đình')) return Icons.diversity_1;
    if (lower.contains('ngoại cảnh')) return Icons.wb_sunny;
    if (lower.contains('cưới')) return Icons.favorite_border;
    if (lower.contains('sự kiện')) return Icons.event;
    if (lower.contains('sản phẩm')) return Icons.inventory_2_outlined;
    if (lower.contains('thời trang')) return Icons.checkroom;
    return Icons.photo_camera_outlined;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bio header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LỜI GIỚI THIỆU',
              style: TextStyle(
                color: Color(0xFF5D5E66),
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 13, color: Color(0xFFA83900)),
                    SizedBox(width: 3),
                    Text(
                      'Sửa',
                      style: TextStyle(
                        color: Color(0xFFA83900),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          profile.bio,
          style: const TextStyle(
            color: Color(0xFF1A1C1D),
            fontSize: 14,
            height: 1.55,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1, color: Color(0xFFEEEEEF)),
        ),

        // Style & Price header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Text(
              'PHONG CÁCH',
              style: TextStyle(
                color: Color(0xFF5D5E66),
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Style Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final style in profile.styles)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F4),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0xFFEEEEEF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForStyle(style),
                      size: 14,
                      color: const Color(0xFFFF5A00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      style,
                      style: const TextStyle(
                        color: Color(0xFF1A1C1D),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Color(0xFF5F5E60)),
                    SizedBox(width: 2),
                    Text(
                      'Thêm',
                      style: TextStyle(
                        color: Color(0xFF5F5E60),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PortfolioGallerySection extends StatelessWidget {
  const _PortfolioGallerySection({
    required this.profile,
    required this.portfolioName,
    required this.uploading,
    required this.uploadProgress,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onMovePhoto,
  });

  final Photographer profile;
  final String? portfolioName;
  final bool uploading;
  final double uploadProgress;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;
  final void Function(int index, int delta) onMovePhoto;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tác phẩm tiêu biểu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  portfolioName == null
                      ? 'Chưa có bộ sưu tập'
                      : '$portfolioName · ${profile.portfolio.length} tác phẩm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5F5E60),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      PortfolioPhotoGrid(
        photos: profile.portfolio,
        onRemove: uploading ? null : onRemovePhoto,
        onMove: uploading ? null : onMovePhoto,
      ),
      const SizedBox(height: 12),
      if (uploading) ...[
        const Text(
          'Đang tải ảnh và chờ Backend xử lý…',
          style: TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: uploadProgress),
      ] else
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onAddPhoto,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Thêm ảnh vào portfolio'),
          ),
        ),
    ],
  );
}

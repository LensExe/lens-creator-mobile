import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import 'portfolio_photo_grid.dart';

class PortfolioEditorForm extends StatelessWidget {
  const PortfolioEditorForm({
    super.key,
    required this.formKey,
    required this.city,
    required this.cities,
    required this.onCityChanged,
    required this.priceController,
    required this.experienceController,
    required this.bioController,
    required this.availableStyles,
    required this.selectedStyles,
    required this.onToggleStyle,
    required this.photos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final GlobalKey<FormState> formKey;
  final String? city;
  final List<String> cities;
  final ValueChanged<String?> onCityChanged;
  final TextEditingController priceController;
  final TextEditingController experienceController;
  final TextEditingController bioController;
  final List<String> availableStyles;
  final List<String> selectedStyles;
  final ValueChanged<String> onToggleStyle;
  final List<String> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: AppColors.obsidian,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Cập nhật thông tin và tác phẩm khách nhìn thấy trên hồ sơ.',
          style: TextStyle(color: AppColors.steel, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 17),
        _EditorSection(
          title: 'Thông tin cơ bản',
          subtitle: 'Thông tin hiển thị cùng hồ sơ nhiếp ảnh gia.',
          icon: Icons.person_outline_rounded,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: cities.contains(city) ? city : null,
                decoration: _inputDecoration(
                  'Tỉnh / Thành phố',
                  Icons.location_on_outlined,
                ),
                items: [
                  for (final value in cities)
                    DropdownMenuItem(value: value, child: Text(value)),
                ],
                onChanged: onCityChanged,
                validator: (value) =>
                    value == null ? 'Chọn tỉnh / thành phố' : null,
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Giá khởi điểm (VNĐ)',
                  Icons.payments_outlined,
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return parsed == null || parsed <= 0
                      ? 'Giá phải lớn hơn 0'
                      : null;
                },
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Số năm kinh nghiệm',
                  Icons.workspace_premium_outlined,
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return parsed == null || parsed < 0
                      ? 'Nhập số năm hợp lệ'
                      : null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _EditorSection(
          title: 'Phong cách chụp',
          subtitle: 'Chọn ít nhất một phong cách bạn cung cấp.',
          icon: Icons.auto_awesome_outlined,
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final style in availableStyles)
                _StyleChip(
                  label: style,
                  selected: selectedStyles.contains(style),
                  onSelected: () => onToggleStyle(style),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _EditorSection(
          title: 'Giới thiệu',
          subtitle: 'Chia sẻ ngắn gọn về phong cách và kinh nghiệm của bạn.',
          icon: Icons.notes_rounded,
          child: TextFormField(
            controller: bioController,
            maxLines: 5,
            minLines: 4,
            maxLength: 500,
            decoration: _inputDecoration('Nội dung giới thiệu', null),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? 'Nhập giới thiệu' : null,
          ),
        ),
        const SizedBox(height: 12),
        _EditorSection(
          title: 'Tác phẩm',
          subtitle: 'Khuyến nghị khoảng 12 ảnh đã hậu kỳ.',
          icon: Icons.photo_library_outlined,
          trailing: _PhotoCount(count: photos.length),
          child: Column(
            children: [
              PortfolioPhotoGrid(photos: photos, onRemove: onRemovePhoto),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddPhoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.graphite,
                    side: const BorderSide(color: AppColors.fog),
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Thêm ảnh bằng URL',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputDecoration(String label, IconData? icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        filled: true,
        fillColor: AppColors.snow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.fog),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.fog),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.ember, width: 1.3),
        ),
      );
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      border: Border.all(color: AppColors.fog),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.ember, size: 16),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 9,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 7), trailing!],
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    ),
  );
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    showCheckmark: selected,
    onSelected: (_) => onSelected(),
    selectedColor: const Color(0xFFFFEEE5),
    checkmarkColor: AppColors.ember,
    side: BorderSide(color: selected ? const Color(0xFFFFD5BF) : AppColors.fog),
    labelStyle: TextStyle(
      color: selected ? AppColors.ember : AppColors.graphite,
      fontSize: 10,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    ),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 4),
  );
}

class _PhotoCount extends StatelessWidget {
  const _PhotoCount({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Text(
      '$count ảnh',
      style: const TextStyle(
        color: AppColors.graphite,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

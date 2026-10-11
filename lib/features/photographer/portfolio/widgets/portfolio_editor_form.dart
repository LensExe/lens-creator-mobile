import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PortfolioEditorForm extends StatelessWidget {
  const PortfolioEditorForm({
    super.key,
    required this.formKey,
    required this.locationController,
    required this.careerStartYearController,
    required this.bioController,
    required this.availableStyles,
    required this.selectedStyles,
    required this.onToggleStyle,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController locationController;
  final TextEditingController careerStartYearController;
  final TextEditingController bioController;
  final Map<String, String> availableStyles;
  final List<String> selectedStyles;
  final ValueChanged<String> onToggleStyle;

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
              TextFormField(
                controller: locationController,
                decoration: _inputDecoration(
                  'Khu vực hoạt động',
                  Icons.location_on_outlined,
                ),
                maxLength: 500,
                validator: (value) {
                  final location = (value ?? '').trim();
                  return location.isEmpty ? 'Nhập khu vực hoạt động' : null;
                },
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: careerStartYearController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Năm bắt đầu hành nghề',
                  Icons.workspace_premium_outlined,
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  return parsed == null ||
                          parsed < 1900 ||
                          parsed > DateTime.now().year
                      ? 'Nhập năm từ 1900 đến ${DateTime.now().year}'
                      : null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _EditorSection(
          title: 'Phong cách chụp',
          subtitle: 'Chọn ít nhất một phong cách bạn cung cấp.',
          icon: Icons.auto_awesome_outlined,
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final style in availableStyles.entries)
                _StyleChip(
                  label: style.value,
                  selected: selectedStyles.contains(style.key),
                  onSelected: () => onToggleStyle(style.key),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: AppColors.ember, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 18,
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
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      child,
    ],
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

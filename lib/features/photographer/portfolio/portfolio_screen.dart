import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart';

const _styles = [
  'Chân dung',
  'Cưới',
  'Sự kiện',
  'Thời trang',
  'Sản phẩm',
  'Gia đình',
  'Du lịch',
  'Ẩm thực',
  'Kiến trúc',
  'Đường phố',
];
const _cities = [
  'Hà Nội',
  'TP. Hồ Chí Minh',
  'Đà Nẵng',
  'Đà Lạt',
  'Cần Thơ',
  'Hải Phòng',
];

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final formKey = GlobalKey<FormState>();
  final bio = TextEditingController();
  final price = TextEditingController();
  final experience = TextEditingController();
  bool editing = false;
  String? city;
  List<String> styles = [];
  List<String> photos = [];

  @override
  void dispose() {
    bio.dispose();
    price.dispose();
    experience.dispose();
    super.dispose();
  }

  void _start(Photographer profile) {
    setState(() {
      editing = true;
      bio.text = profile.bio;
      price.text = '${profile.pricePerSession}';
      experience.text = '${profile.experienceYears}';
      city = profile.city;
      styles = [...profile.styles];
      photos = [...profile.portfolio];
    });
  }

  void _save(Photographer profile) {
    if (!formKey.currentState!.validate()) return;
    if (styles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn ít nhất một phong cách chụp')),
      );
      return;
    }
    ref
        .read(photographersProvider.notifier)
        .update(
          profile.copyWith(
            city: city,
            bio: bio.text.trim(),
            pricePerSession: int.parse(price.text.trim()),
            experienceYears: int.parse(experience.text.trim()),
            styles: [...styles],
            portfolio: [...photos],
          ),
        );
    setState(() => editing = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ')));
  }

  Future<void> _addPhoto() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm ảnh tác phẩm'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'Đường dẫn ảnh HTTPS'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || !mounted) return;
    if (!Uri.tryParse(url).toString().startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập đường dẫn ảnh HTTPS hợp lệ')),
      );
      return;
    }
    setState(() => photos.add(url));
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myPhotographerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Chỉnh sửa hồ sơ' : 'Hồ sơ năng lực'),
        actions: [
          if (profile != null && !editing)
            IconButton(
              tooltip: 'Chỉnh sửa',
              onPressed: () => _start(profile),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : editing
          ? _editor(profile)
          : _view(profile),
    );
  }

  Widget _view(Photographer profile) => ListView(
    padding: AppTokens.pagePadding,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Image.network(
          profile.cover,
          height: 170,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const SizedBox(height: 170, child: Icon(Icons.photo_outlined)),
        ),
      ),
      const SizedBox(height: 16),
      Text(profile.name, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text(
        '${profile.city} · ${profile.experienceYears} năm kinh nghiệm',
        style: const TextStyle(color: AppColors.steel),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        children: [
          for (final style in profile.styles) Chip(label: Text(style)),
        ],
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giới thiệu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(profile.bio),
              const SizedBox(height: 12),
              Text(
                'Giá từ ${formatDong(profile.pricePerSession)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ember,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Tác phẩm · ${profile.portfolio.length} ảnh',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      _PhotoGrid(photos: profile.portfolio),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () => context.push('/photographer_home/public_profile'),
        icon: const Icon(Icons.visibility_outlined),
        label: const Text('Xem hồ sơ công khai'),
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: () => _start(profile),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Chỉnh sửa hồ sơ'),
      ),
    ],
  );

  Widget _editor(Photographer profile) => Form(
    key: formKey,
    child: ListView(
      padding: AppTokens.pagePadding,
      children: [
        const Text(
          'Cập nhật thông tin và tác phẩm khách nhìn thấy trên hồ sơ.',
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _cities.contains(city) ? city : null,
          decoration: const InputDecoration(labelText: 'Tỉnh / Thành phố'),
          items: [
            for (final value in _cities)
              DropdownMenuItem(value: value, child: Text(value)),
          ],
          onChanged: (value) => setState(() => city = value),
          validator: (value) => value == null ? 'Chọn tỉnh / thành phố' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Giá khởi điểm (VNĐ)'),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            return parsed == null || parsed <= 0 ? 'Giá phải lớn hơn 0' : null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: experience,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số năm kinh nghiệm'),
          validator: (value) {
            final parsed = int.tryParse(value ?? '');
            return parsed == null || parsed < 0 ? 'Nhập số năm hợp lệ' : null;
          },
        ),
        const SizedBox(height: 16),
        Text('Phong cách chụp', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final style in _styles)
              FilterChip(
                label: Text(style),
                selected: styles.contains(style),
                onSelected: (_) => setState(() {
                  if (styles.contains(style)) {
                    styles.remove(style);
                  } else {
                    styles.add(style);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: bio,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Giới thiệu'),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'Nhập giới thiệu' : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Tác phẩm · ${photos.length} ảnh',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          'Khuyến nghị khoảng 12 ảnh đã hậu kỳ.',
          style: TextStyle(color: AppColors.steel, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _PhotoGrid(
          photos: photos,
          onRemove: (index) => setState(() => photos.removeAt(index)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addPhoto,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Thêm ảnh bằng URL'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => editing = false),
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => _save(profile),
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos, this.onRemove});
  final List<String> photos;
  final void Function(int)? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Chưa có tác phẩm')),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) => Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.fog,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                tooltip: 'Xoá ảnh',
                onPressed: () => onRemove!(index),
                icon: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }
}

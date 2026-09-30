import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import '../widgets/photographer_app_bar.dart';
import 'widgets/portfolio_editor_actions.dart';
import 'widgets/portfolio_editor_form.dart';
import 'widgets/portfolio_profile_view.dart';

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
          decoration: InputDecoration(
            labelText: 'Đường dẫn ảnh HTTPS',
            prefixIcon: const Icon(Icons.link_rounded),
            filled: true,
            fillColor: AppColors.mist,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.fog),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Thêm ảnh'),
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
      backgroundColor: AppColors.mist,
      appBar: PhotographerAppBar(
        actions: [
          if (profile != null && !editing) ...[
            IconButton(
              tooltip: 'Xem hồ sơ công khai',
              onPressed: () =>
                  context.push('/photographer_home/public_profile'),
              icon: const Icon(Icons.visibility_outlined),
            ),
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: () => _start(profile),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ],
      ),
      body: profile == null
          ? const Center(
              child: Text(
                'Vui lòng đăng nhập',
                style: TextStyle(color: AppColors.steel),
              ),
            )
          : editing
          ? PortfolioEditorForm(
              formKey: formKey,
              city: city,
              cities: _cities,
              onCityChanged: (value) => setState(() => city = value),
              priceController: price,
              experienceController: experience,
              bioController: bio,
              availableStyles: _styles,
              selectedStyles: styles,
              onToggleStyle: (style) => setState(() {
                if (styles.contains(style)) {
                  styles.remove(style);
                } else {
                  styles.add(style);
                }
              }),
              photos: photos,
              onAddPhoto: _addPhoto,
              onRemovePhoto: (index) => setState(() => photos.removeAt(index)),
            )
          : PortfolioProfileView(
              profile: profile,
              onPreview: () =>
                  context.push('/photographer_home/public_profile'),
              onEdit: () => _start(profile),
            ),
      bottomNavigationBar: profile != null && editing
          ? PortfolioEditorActions(
              onCancel: () => setState(() => editing = false),
              onSave: () => _save(profile),
            )
          : null,
    );
  }
}

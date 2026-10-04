import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
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
  bool saving = false;
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

  Future<void> _save(Photographer profile) async {
    if (!formKey.currentState!.validate()) return;
    if (styles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn ít nhất một phong cách chụp')),
      );
      return;
    }
    setState(() => saving = true);
    try {
      await ref
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
      if (!mounted) return;
      setState(() => editing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật hồ sơ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _addPhoto() async {
    final url = await showDialog<String>(
      context: context,
      builder: (_) => const _AddPortfolioPhotoDialog(),
    );
    if (url == null || !mounted) return;
    if (!Uri.tryParse(url).toString().startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập đường dẫn ảnh HTTPS hợp lệ')),
      );
      return;
    }
    setState(() => photos.add(url));
  }

  Future<void> _startAndAddPhoto(Photographer profile) async {
    _start(profile);
    await _addPhoto();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myPhotographerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hồ Sơ Năng Lực',
          style: TextStyle(
            color: Color(0xFF1A1C1D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          if (profile != null && !editing) ...[
            IconButton(
              tooltip: 'Xem hồ sơ công khai',
              onPressed: () =>
                  context.push('/photographer_home/public_profile'),
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFF5F5E60),
                size: 22,
              ),
            ),
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: () => _start(profile),
              icon: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF5F5E60),
                size: 22,
              ),
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
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.contentMaxWidth,
                ),
                child: PortfolioEditorForm(
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
                  onRemovePhoto: (index) =>
                      setState(() => photos.removeAt(index)),
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTokens.contentMaxWidth,
                ),
                child: PortfolioProfileView(
                  profile: profile,
                  onPreview: () =>
                      context.push('/photographer_home/public_profile'),
                  onEdit: () => _start(profile),
                  onAddPhoto: () => _startAndAddPhoto(profile),
                ),
              ),
            ),
      bottomNavigationBar: profile != null && editing
          ? PortfolioEditorActions(
              onCancel: () => setState(() => editing = false),
              onSave: () => _save(profile),
              busy: saving,
            )
          : null,
    );
  }
}

class _AddPortfolioPhotoDialog extends StatefulWidget {
  const _AddPortfolioPhotoDialog();

  @override
  State<_AddPortfolioPhotoDialog> createState() =>
      _AddPortfolioPhotoDialogState();
}

class _AddPortfolioPhotoDialogState extends State<_AddPortfolioPhotoDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
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
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text.trim()),
        child: const Text('Thêm ảnh'),
      ),
    ],
  );
}

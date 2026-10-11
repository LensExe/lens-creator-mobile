import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import 'api_portfolio_repository.dart';
import 'widgets/portfolio_editor_actions.dart';
import 'widgets/portfolio_editor_form.dart';
import 'widgets/portfolio_profile_view.dart';

const _styles = <String, String>{
  'portrait': 'Chân dung',
  'vintage': 'Hoài cổ',
  'korean': 'Hàn Quốc',
  'wedding': 'Cưới',
  'concept': 'Concept',
  'pre-wedding': 'Tiền cưới',
  'beach': 'Biển',
  'lifestyle': 'Lifestyle',
  'event': 'Sự kiện',
  'corporate': 'Doanh nghiệp',
  'family': 'Gia đình',
  'outdoor': 'Ngoại cảnh',
  'kids': 'Trẻ em',
  'streetwear': 'Thời trang đường phố',
  'fashion': 'Thời trang',
  'film': 'Film',
  'maternity': 'Mẹ và bé',
  'commercial': 'Thương mại',
};

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  final formKey = GlobalKey<FormState>();
  final bio = TextEditingController();
  final location = TextEditingController();
  final careerStartYear = TextEditingController();
  bool editing = false;
  bool saving = false;
  bool uploading = false;
  double uploadProgress = 0;
  List<String> styles = [];

  final ImagePicker imagePicker = ImagePicker();

  @override
  void dispose() {
    bio.dispose();
    location.dispose();
    careerStartYear.dispose();
    super.dispose();
  }

  void _start(Photographer profile) {
    setState(() {
      editing = true;
      bio.text = profile.bio;
      location.text = profile.city;
      careerStartYear.text = profile.experienceYears > 0
          ? '${DateTime.now().year - profile.experienceYears}'
          : '';
      styles = [...profile.styles];
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
          .read(currentPhotographerProvider.notifier)
          .update(
            profile.copyWith(
              city: location.text.trim(),
              bio: bio.text.trim(),
              experienceYears:
                  DateTime.now().year - int.parse(careerStartYear.text.trim()),
              styles: [...styles],
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

  Future<String?> _createAlbumName() async {
    final controller = TextEditingController(text: 'Hồ sơ năng lực');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tạo bộ sưu tập'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Tên bộ sưu tập'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name?.trim().isNotEmpty == true ? name!.trim() : null;
  }

  Future<String?> _chooseAlbum(List<PortfolioAlbum> albums) async {
    if (albums.isEmpty) return null;
    if (albums.length == 1) return albums.first.id;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Chọn bộ sưu tập'),
        children: [
          for (final album in albums)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, album.id),
              child: Text(album.name),
            ),
        ],
      ),
    );
  }

  Future<void> _addPhoto(PortfolioWorkspace workspace) async {
    final albumId = await _chooseAlbum(workspace.albums);
    if (workspace.albums.isNotEmpty && albumId == null) return;
    final albumName = workspace.albums.isEmpty
        ? await _createAlbumName()
        : null;
    if (workspace.albums.isEmpty && albumName == null) return;
    final file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      requestFullMetadata: false,
    );
    if (file == null || !mounted) return;
    setState(() {
      uploading = true;
      uploadProgress = 0;
    });
    try {
      await ref
          .read(apiPortfolioRepositoryProvider)
          .uploadAndAdd(
            file,
            portfolioId: albumId,
            newAlbumName: albumName,
            onProgress: (progress) {
              if (mounted) {
                setState(() => uploadProgress = progress.clamp(0, 1));
              }
            },
          );
      ref.invalidate(photographerPortfolioProvider);
      ref.invalidate(myPhotographerProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend đã xử lý và thêm ảnh vào portfolio.'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể thêm ảnh: $error')));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> _removePhoto(PortfolioWorkspace workspace, int index) async {
    final item = workspace.assets[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá ảnh khỏi portfolio?'),
        content: const Text('Ảnh sẽ được gỡ khỏi bộ sưu tập này.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(apiPortfolioRepositoryProvider).removeItem(item);
      ref.invalidate(photographerPortfolioProvider);
      ref.invalidate(myPhotographerProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gỡ ảnh khỏi portfolio.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không thể gỡ ảnh: $error')));
      }
    }
  }

  Future<void> _movePhoto(
    PortfolioWorkspace workspace,
    int index,
    int delta,
  ) async {
    final item = workspace.assets[index];
    final albumItems =
        workspace.assets
            .where((asset) => asset.portfolioId == item.portfolioId)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
    final current = albumItems.indexWhere(
      (asset) => asset.portfolioItemId == item.portfolioItemId,
    );
    final target = current + delta;
    if (current < 0 || target < 0 || target >= albumItems.length) return;
    final reordered = [...albumItems];
    final moved = reordered.removeAt(current);
    reordered.insert(target, moved);
    try {
      await ref
          .read(apiPortfolioRepositoryProvider)
          .reorderAlbum(
            item.portfolioId,
            reordered.map((asset) => asset.portfolioItemId).toList(),
          );
      ref.invalidate(photographerPortfolioProvider);
      ref.invalidate(myPhotographerProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể sắp xếp ảnh: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myPhotographerProvider);
    final portfolio = ref.watch(photographerPortfolioProvider);
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
                  locationController: location,
                  careerStartYearController: careerStartYear,
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
                ),
              ),
            )
          : portfolio.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_outlined, size: 36),
                      const SizedBox(height: 8),
                      const Text('Không thể tải portfolio từ Backend'),
                      Text('$error', textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(photographerPortfolioProvider),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (workspace) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppTokens.contentMaxWidth,
                  ),
                  child: PortfolioProfileView(
                    profile: profile.copyWith(
                      portfolio: workspace.assets
                          .map((item) => item.url)
                          .toList(),
                    ),
                    onPreview: () =>
                        context.push('/photographer_home/public_profile'),
                    onEdit: () => _start(profile),
                    onAddPhoto: uploading ? () {} : () => _addPhoto(workspace),
                    onRemovePhoto: (index) => _removePhoto(workspace, index),
                    onMovePhoto: (index, delta) =>
                        _movePhoto(workspace, index, delta),
                    portfolioName: workspace.albums.firstOrNull?.name,
                    uploading: uploading,
                    uploadProgress: uploadProgress,
                  ),
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

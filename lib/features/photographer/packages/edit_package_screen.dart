import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../core/widgets/creator_section_header.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import 'widgets/package_editor_actions.dart';
import 'widgets/package_editor_field.dart';

class EditPackageScreen extends ConsumerStatefulWidget {
  const EditPackageScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends ConsumerState<EditPackageScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final photoCount = TextEditingController();
  final duration = TextEditingController();
  final deliveryDays = TextEditingController();
  bool initialized = false;
  bool saving = false;

  @override
  void dispose() {
    for (final controller in [
      name,
      description,
      price,
      photoCount,
      duration,
      deliveryDays,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _integer(String? value, int min, int max, String label) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < min || parsed > max) {
      return '$label phải từ $min đến $max';
    }
    return null;
  }

  Future<void> _save(Photographer profile) async {
    if (!formKey.currentState!.validate()) return;
    final hours = double.parse(duration.text.trim().replaceAll(',', '.'));
    final package = PhotographerPackage(
      id: widget.id == 'new'
          ? 'pkg-${DateTime.now().microsecondsSinceEpoch}'
          : widget.id,
      name: name.text.trim(),
      description: description.text.trim(),
      price: int.parse(price.text.trim()),
      photoCount: int.parse(photoCount.text.trim()),
      durationHours: hours,
      duration: '${hours.toString().replaceAll('.0', '')} giờ',
      deliveryDays: int.parse(deliveryDays.text.trim()),
    );
    final packages = [...profile.packages];
    final index = packages.indexWhere((item) => item.id == package.id);
    if (index == -1) {
      packages.add(package);
    } else {
      packages[index] = package;
    }
    setState(() => saving = true);
    try {
      await ref
          .read(photographersProvider.notifier)
          .update(profile.copyWith(packages: packages));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu gói dịch vụ')));
      context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lưu gói dịch vụ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _delete(Photographer profile) async {
    if (profile.packages.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần ít nhất một gói dịch vụ')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá gói dịch vụ?'),
        content: const Text(
          'Các lịch đã đặt vẫn giữ điều khoản gói tại thời điểm đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      setState(() => saving = true);
      await ref
          .read(photographersProvider.notifier)
          .update(
            profile.copyWith(
              packages: profile.packages
                  .where((item) => item.id != widget.id)
                  .toList(),
            ),
          );
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xoá gói dịch vụ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(myPhotographerProvider);
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }
    PhotographerPackage? current;
    for (final package in profile.packages) {
      if (package.id == widget.id) {
        current = package;
        break;
      }
    }
    if (widget.id != 'new' && current == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy gói dịch vụ')),
      );
    }
    if (!initialized) {
      name.text = current?.name ?? '';
      description.text = current?.description ?? '';
      price.text = '${current?.price ?? 200000}';
      photoCount.text = '${current?.photoCount ?? 20}';
      duration.text = '${current?.durationHours ?? 1}';
      deliveryDays.text = '${current?.deliveryDays ?? 7}';
      initialized = true;
    }
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        title: Text(widget.id == 'new' ? 'Thêm gói chụp' : 'Sửa gói chụp'),
        actions: [
          if (current != null)
            IconButton(
              tooltip: 'Xoá gói',
              onPressed: saving ? null : () => _delete(profile),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.destructive,
              ),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      bottomNavigationBar: PackageEditorActions(
        onCancel: () => context.pop(),
        onSave: () => _save(profile),
        saveLabel: current == null ? 'Tạo gói chụp' : 'Lưu thay đổi',
        busy: saving,
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                CreatorPageHeader(
                  title: current == null ? 'Tạo gói chụp' : 'Cập nhật gói chụp',
                  subtitle: current == null
                      ? 'Thiết lập nội dung và cam kết để khách chọn khi đặt lịch.'
                      : 'Chỉnh sửa thông tin gói. Lịch đã đặt vẫn giữ điều khoản cũ.',
                ),
                const SizedBox(height: 24),
                const CreatorSectionHeader(
                  title: 'Thông tin hiển thị',
                  subtitle: 'Tên và mô tả giúp khách hiểu phong cách gói chụp.',
                ),
                const SizedBox(height: 14),
                PackageEditorField(
                  controller: name,
                  label: 'Tên gói',
                  hintText: 'Ví dụ: Chân dung cá nhân',
                  maxLength: 80,
                  enabled: !saving,
                  validator: (value) =>
                      (value ?? '').trim().length < 2 ? 'Nhập tên gói' : null,
                ),
                PackageEditorField(
                  controller: description,
                  label: 'Mô tả',
                  hintText: 'Nội dung hoặc điểm nổi bật của gói',
                  maxLength: 160,
                  maxLines: 3,
                  enabled: !saving,
                  validator: (value) => (value ?? '').length > 160
                      ? 'Mô tả tối đa 160 ký tự'
                      : null,
                ),
                const SizedBox(height: 24),
                const CreatorSectionHeader(
                  title: 'Giá và cam kết',
                  subtitle: 'Các thông tin này được lưu cùng lịch đặt mới.',
                ),
                const SizedBox(height: 14),
                PackageEditorField(
                  controller: price,
                  label: 'Giá gói',
                  suffixText: '₫',
                  keyboardType: TextInputType.number,
                  enabled: !saving,
                  validator: (value) =>
                      _integer(value, 10000, 1000000000, 'Giá'),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PackageEditorField(
                        controller: photoCount,
                        label: 'Ảnh bàn giao',
                        suffixText: 'ảnh',
                        keyboardType: TextInputType.number,
                        enabled: !saving,
                        validator: (value) => _integer(value, 1, 500, 'Số ảnh'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PackageEditorField(
                        controller: duration,
                        label: 'Thời lượng',
                        suffixText: 'giờ',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        enabled: !saving,
                        validator: (value) {
                          final parsed = double.tryParse(
                            (value ?? '').replaceAll(',', '.'),
                          );
                          return parsed == null || parsed < 0.5 || parsed > 12
                              ? 'Từ 0,5 đến 12 giờ'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                PackageEditorField(
                  controller: deliveryDays,
                  label: 'Thời gian giao ảnh',
                  suffixText: 'ngày',
                  keyboardType: TextInputType.number,
                  enabled: !saving,
                  validator: (value) => _integer(value, 1, 60, 'Số ngày'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

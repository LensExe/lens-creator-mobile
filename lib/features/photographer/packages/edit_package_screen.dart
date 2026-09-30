import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/creator_section_header.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';

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

  void _save(Photographer profile) {
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
    ref
        .read(photographersProvider.notifier)
        .update(profile.copyWith(packages: packages));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã lưu gói dịch vụ')));
    context.pop();
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
    ref
        .read(photographersProvider.notifier)
        .update(
          profile.copyWith(
            packages: profile.packages
                .where((item) => item.id != widget.id)
                .toList(),
          ),
        );
    context.pop();
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
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        title: Text(widget.id == 'new' ? 'Thêm gói dịch vụ' : 'Chỉnh sửa gói'),
        actions: [
          if (current != null)
            IconButton(
              tooltip: 'Xoá gói',
              onPressed: () => _delete(profile),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                const Text(
                  'Điều khoản gói được lưu vào từng lịch đặt của khách.',
                  style: TextStyle(color: AppColors.steel, fontSize: 13),
                ),
                const SizedBox(height: 24),
                const CreatorSectionHeader(title: 'Thông tin gói'),
                const SizedBox(height: 14),
                _Field(
                  controller: name,
                  label: 'Tên gói',
                  maxLength: 80,
                  validator: (value) =>
                      (value ?? '').trim().length < 2 ? 'Nhập tên gói' : null,
                ),
                _Field(
                  controller: description,
                  label: 'Mô tả',
                  maxLength: 160,
                  maxLines: 3,
                  validator: (value) => (value ?? '').length > 160
                      ? 'Mô tả tối đa 160 ký tự'
                      : null,
                ),
                _Field(
                  controller: price,
                  label: 'Giá (VNĐ)',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      _integer(value, 10000, 1000000000, 'Giá'),
                ),
                const SizedBox(height: 12),
                const CreatorSectionHeader(title: 'Cam kết buổi chụp'),
                const SizedBox(height: 14),
                _Field(
                  controller: photoCount,
                  label: 'Số ảnh bàn giao',
                  keyboardType: TextInputType.number,
                  validator: (value) => _integer(value, 1, 500, 'Số ảnh'),
                ),
                _Field(
                  controller: duration,
                  label: 'Thời lượng (giờ)',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(
                      (value ?? '').replaceAll(',', '.'),
                    );
                    return parsed == null || parsed < 0.5 || parsed > 12
                        ? 'Thời lượng từ 0,5 đến 12 giờ'
                        : null;
                  },
                ),
                _Field(
                  controller: deliveryDays,
                  label: 'Giao trong (ngày)',
                  keyboardType: TextInputType.number,
                  validator: (value) => _integer(value, 1, 60, 'Số ngày'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _save(profile),
                  child: const Text('Lưu gói dịch vụ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
    ),
  );
}

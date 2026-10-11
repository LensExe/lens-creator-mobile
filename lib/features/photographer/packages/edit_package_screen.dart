import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import 'booking_plan_repository.dart';
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
  final retouchedPhotoCount = TextEditingController();
  final duration = TextEditingController();
  final features = TextEditingController();
  bool isActive = true;
  bool initialized = false;
  bool saving = false;

  String _digits(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  String _formatPrice(int value) =>
      NumberFormat.decimalPattern('vi').format(value);

  @override
  void dispose() {
    for (final controller in [
      name,
      description,
      price,
      photoCount,
      retouchedPhotoCount,
      duration,
      features,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _integer(
    String? value,
    int min,
    int max,
    String label, {
    bool grouped = false,
  }) {
    final raw = (value ?? '').trim();
    final normalized = grouped ? raw.replaceAll('.', '') : raw;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < min || parsed > max) {
      return '$label phải từ $min đến $max';
    }
    return null;
  }

  Future<void> _save(PhotographerPackage? current) async {
    if (!formKey.currentState!.validate()) return;
    final hours = double.parse(duration.text.trim().replaceAll(',', '.'));
    final package = PhotographerPackage(
      id: current?.id ?? '',
      name: name.text.trim(),
      description: description.text.trim(),
      price: int.parse(_digits(price.text)),
      photoCount: int.parse(photoCount.text.trim()),
      retouchedPhotoCount: int.parse(retouchedPhotoCount.text.trim()),
      durationHours: hours,
      duration: '${hours.toString().replaceAll('.0', '')} giờ',
      features: features.text
          .split('\n')
          .map((feature) => feature.trim())
          .where((feature) => feature.isNotEmpty)
          .toList(),
      isActive: isActive,
    );
    setState(() => saving = true);
    try {
      if (current == null) {
        await ref.read(bookingPlansProvider.notifier).create(package);
      } else {
        await ref.read(bookingPlansProvider.notifier).updatePlan(package);
      }
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

  Future<void> _delete(PhotographerPackage package) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá gói dịch vụ?'),
        content: const Text(
          'Backend chỉ cho xoá gói chưa có booking. Gói đã có booking cần được tắt trong phần cập nhật.',
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
      await ref.read(bookingPlansProvider.notifier).delete(package.id);
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
    final plansState = ref.watch(bookingPlansProvider);
    if (ref.watch(authUserProvider) == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }
    if (plansState.isLoading && widget.id != 'new') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (plansState.hasError) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(bookingPlansProvider),
            child: Text(
              'Không tải được gói chụp. Thử lại: ${plansState.error}',
            ),
          ),
        ),
      );
    }
    final current = widget.id == 'new'
        ? null
        : plansState.value?.where((item) => item.id == widget.id).firstOrNull;
    if (widget.id != 'new' && current == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy gói dịch vụ')),
      );
    }
    if (!initialized) {
      name.text = current?.name ?? '';
      description.text = current?.description ?? '';
      price.text = _formatPrice(current?.price ?? 200000);
      photoCount.text = '${current?.photoCount ?? 20}';
      retouchedPhotoCount.text = '${current?.retouchedPhotoCount ?? 0}';
      duration.text = '${current?.durationHours ?? 1}';
      features.text = current?.features.join('\n') ?? '';
      isActive = current?.isActive ?? true;
      initialized = true;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        toolbarHeight: 56,
        leadingWidth: 48,
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          widget.id == 'new' ? 'Thêm gói chụp' : 'Cập nhật gói chụp',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (current != null)
            IconButton(
              tooltip: 'Xoá gói',
              onPressed: saving ? null : () => _delete(current),
              color: AppColors.destructive,
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
            ),
        ],
      ),
      bottomNavigationBar: PackageEditorActions(
        onCancel: () => context.pop(),
        onSave: () => _save(current),
        saveLabel: current == null ? 'Tạo gói chụp' : 'Lưu gói chụp',
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
              children: [
                _PackageFormHeader(
                  title: current == null ? 'Tạo gói chụp' : 'Cập nhật gói chụp',
                  subtitle: current == null
                      ? 'Thiết lập nội dung và cam kết để khách chọn khi đặt lịch.'
                      : 'Chỉnh sửa thông tin gói. Lịch đã đặt vẫn giữ điều khoản cũ.',
                ),
                const SizedBox(height: 17),
                _PackageEditorSection(
                  icon: Icons.edit_document,
                  title: 'Thông tin hiển thị',
                  subtitle: 'Tên và mô tả giúp khách hiểu phong cách gói chụp.',
                  children: [
                    PackageEditorField(
                      controller: name,
                      label: 'Tên gói',
                      requiredField: true,
                      hintText: 'Ví dụ: Chân dung cá nhân',
                      maxLength: 80,
                      enabled: !saving,
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Nhập tên gói'
                          : null,
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
                  ],
                ),
                const SizedBox(height: 16),
                _PackageEditorSection(
                  icon: Icons.sell_outlined,
                  title: 'Giá và cam kết dịch vụ',
                  subtitle: 'Các thông tin này được lưu cùng lịch đặt mới.',
                  children: [
                    PackageEditorField(
                      controller: price,
                      label: 'Giá gói',
                      requiredField: true,
                      suffixText: '₫',
                      hintText: '0',
                      helperText: 'Nhập giá gói bằng VND',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_VietnamesePriceInputFormatter()],
                      textStyle: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      enabled: !saving,
                      validator: (value) => _integer(
                        value,
                        1,
                        9000000000000,
                        'Giá',
                        grouped: true,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PackageEditorField(
                            controller: photoCount,
                            label: 'Ảnh bàn giao',
                            suffixText: 'ảnh',
                            helperText: 'Từ 0 đến 10.000 ảnh',
                            keyboardType: TextInputType.number,
                            enabled: !saving,
                            validator: (value) =>
                                _integer(value, 0, 10000, 'Số ảnh'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PackageEditorField(
                            controller: duration,
                            label: 'Thời lượng',
                            suffixText: 'giờ',
                            helperText: 'Từ 0,25 đến 24 giờ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            enabled: !saving,
                            validator: (value) {
                              final parsed = double.tryParse(
                                (value ?? '').replaceAll(',', '.'),
                              );
                              return parsed == null ||
                                      parsed < 0.25 ||
                                      parsed > 24
                                  ? 'Từ 0,25 đến 24 giờ'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    PackageEditorField(
                      controller: retouchedPhotoCount,
                      label: 'Ảnh chỉnh sửa',
                      suffixText: 'ảnh',
                      helperText: 'Từ 0 đến 10.000 ảnh',
                      keyboardType: TextInputType.number,
                      enabled: !saving,
                      validator: (value) => _integer(
                        value,
                        0,
                        int.tryParse(photoCount.text) ?? 10000,
                        'Số ảnh chỉnh sửa',
                      ),
                    ),
                    PackageEditorField(
                      controller: features,
                      label: 'Tính năng đi kèm',
                      hintText: 'Mỗi dòng là một tính năng',
                      maxLines: 4,
                      enabled: !saving,
                      validator: (value) =>
                          (value ?? '')
                                  .split('\n')
                                  .where((line) => line.trim().isNotEmpty)
                                  .length >
                              50
                          ? 'Tối đa 50 tính năng'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (current != null)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gói đang hoạt động'),
                    subtitle: const Text(
                      'Gói tắt sẽ không xuất hiện trong lựa chọn booking mới.',
                    ),
                    value: isActive,
                    onChanged: saving
                        ? null
                        : (value) => setState(() => isActive = value),
                  ),
                if (current != null) ...[
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      TextButton.icon(
                        onPressed: saving ? null : () => _delete(current),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.destructive,
                          backgroundColor: const Color(0xFFFFDAD6)
                              .withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 18,
                        ),
                        label: const Text('Xoá gói dịch vụ này'),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Gói đã có booking chỉ được tắt, không thể xoá.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.steel, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageFormHeader extends StatelessWidget {
  const _PackageFormHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(
            Icons.photo_camera_back_outlined,
            color: AppColors.ember,
            size: 18,
          ),
          SizedBox(width: 7),
          Text(
            'GÓI DỊCH VỤ NHIẾP ẢNH',
            style: TextStyle(
              color: AppColors.ember,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.65,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        title,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.steel,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _PackageEditorSection extends StatelessWidget {
  const _PackageEditorSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.ember, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.steel,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

class _VietnamesePriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    final digitsBeforeCursor = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    var seenDigits = 0;
    var selectionOffset = 0;
    if (digitsBeforeCursor > 0) {
      for (var index = 0; index < formatted.length; index++) {
        if (RegExp(r'[0-9]').hasMatch(formatted[index])) {
          seenDigits++;
          if (seenDigits == digitsBeforeCursor) {
            selectionOffset = index + 1;
            break;
          }
        }
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}

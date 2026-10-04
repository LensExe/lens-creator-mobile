import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
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
      duration,
      deliveryDays,
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

  Future<void> _save(Photographer profile) async {
    if (!formKey.currentState!.validate()) return;
    final hours = double.parse(duration.text.trim().replaceAll(',', '.'));
    final package = PhotographerPackage(
      id: widget.id == 'new'
          ? 'pkg-${DateTime.now().microsecondsSinceEpoch}'
          : widget.id,
      name: name.text.trim(),
      description: description.text.trim(),
      price: int.parse(_digits(price.text)),
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
      price.text = _formatPrice(current?.price ?? 200000);
      photoCount.text = '${current?.photoCount ?? 20}';
      duration.text = '${current?.durationHours ?? 1}';
      deliveryDays.text = '${current?.deliveryDays ?? 7}';
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
              onPressed: saving ? null : () => _delete(profile),
              color: AppColors.destructive,
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
            ),
        ],
      ),
      bottomNavigationBar: PackageEditorActions(
        onCancel: () => context.pop(),
        onSave: () => _save(profile),
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
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
                _PackagePreviewBanner(coverUrl: profile.cover),
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
                      helperText: 'Tối thiểu 10.000 ₫',
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
                        10000,
                        1000000000,
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
                            helperText: 'Từ 1 đến 500 ảnh',
                            keyboardType: TextInputType.number,
                            enabled: !saving,
                            validator: (value) =>
                                _integer(value, 1, 500, 'Số ảnh'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PackageEditorField(
                            controller: duration,
                            label: 'Thời lượng',
                            suffixText: 'giờ',
                            helperText: 'Từ 0,5 đến 12 giờ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            enabled: !saving,
                            validator: (value) {
                              final parsed = double.tryParse(
                                (value ?? '').replaceAll(',', '.'),
                              );
                              return parsed == null ||
                                      parsed < 0.5 ||
                                      parsed > 12
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
                      helperText:
                          'Cam kết trả ảnh hoàn thiện cho khách (1–60 ngày)',
                      keyboardType: TextInputType.number,
                      enabled: !saving,
                      validator: (value) => _integer(value, 1, 60, 'Số ngày'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _EscrowNotice(),
                if (current != null) ...[
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      TextButton.icon(
                        onPressed: saving ? null : () => _delete(profile),
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
                        'Cần ít nhất 1 gói dịch vụ hoạt động',
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

class _PackagePreviewBanner extends StatelessWidget {
  const _PackagePreviewBanner({required this.coverUrl});

  final String coverUrl;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            coverUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3F3F46), Color(0xFF18181B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: AppColors.snow,
                size: 28,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 14,
            child: Row(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'LENS CREATOR STUDIO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _EscrowNotice extends StatelessWidget {
  const _EscrowNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE5E1E4).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.snow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.ember,
              size: 18,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đảm bảo thanh toán LENS Escrow',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Tiền cọc được giữ đến khi khách nghiệm thu ảnh theo điều khoản đặt lịch.',
                style: TextStyle(
                  color: AppColors.steel,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
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

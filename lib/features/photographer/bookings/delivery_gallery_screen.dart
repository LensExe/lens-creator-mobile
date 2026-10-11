import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import '../../../core/widgets/creator_page_header.dart';
import '../../../features/photographer/portfolio/widgets/portfolio_photo_grid.dart';
import 'booking_gallery_repository.dart';

class DeliveryGalleryScreen extends ConsumerStatefulWidget {
  const DeliveryGalleryScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<DeliveryGalleryScreen> createState() =>
      _DeliveryGalleryScreenState();
}

class _DeliveryGalleryScreenState extends ConsumerState<DeliveryGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;
  bool _publishing = false;
  double _uploadProgress = 0;

  Future<void> _upload() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
      requestFullMetadata: false,
    );
    if (file == null || !mounted) return;
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });
    try {
      await ref
          .read(apiBookingGalleryRepositoryProvider)
          .uploadAndAdd(
            widget.bookingId,
            file,
            onProgress: (progress) {
              if (mounted) {
                setState(() => _uploadProgress = progress.clamp(0, 1));
              }
            },
          );
      ref.invalidate(bookingGalleryProvider(widget.bookingId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend đã xử lý ảnh và thêm vào gallery booking.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể thêm ảnh: $error')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _publish(BookingGallerySnapshot gallery) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Công bố gallery cho khách?'),
        content: Text(
          'Backend sẽ công khai ${gallery.items.length} ảnh trong booking này. Sau khi công bố, gallery không thể chỉnh sửa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Công bố'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _publishing = true);
    try {
      await ref
          .read(apiBookingGalleryRepositoryProvider)
          .publish(widget.bookingId);
      ref.invalidate(bookingGalleryProvider(widget.bookingId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend đã xác nhận công bố gallery.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể công bố gallery: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingGalleryProvider(widget.bookingId));
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Gallery bàn giao')),
      body: state.when(
        loading: () =>
            const CreatorLoadingState(label: 'Đang tải booking và gallery…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải gallery',
          description: '$error',
          actionLabel: 'Thử lại',
          onAction: () =>
              ref.invalidate(bookingGalleryProvider(widget.bookingId)),
        ),
        data: (gallery) => _content(gallery),
      ),
    );
  }

  Widget _content(BookingGallerySnapshot gallery) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
        children: [
          CreatorPageHeader(
            title: 'Booking ${widget.bookingId.substring(0, 8)}',
            subtitle: _bookingSubtitle(gallery),
          ),
          const SizedBox(height: 16),
          Text(
            'Trạng thái Backend: ${_statusLabel(gallery.status)}',
            style: const TextStyle(
              color: AppColors.obsidian,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (gallery.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Địa điểm: ${gallery.location}'),
          ],
          if (gallery.publishedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Đã công bố ${DateFormat('dd/MM/yyyy HH:mm').format(gallery.publishedAt!.toLocal())}',
              style: const TextStyle(color: AppColors.steel),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            '${gallery.items.length} ảnh từ Backend',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (gallery.items.isEmpty)
            const CreatorEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'Gallery chưa có ảnh',
              description:
                  'Tải ảnh lên để tạo gallery bàn giao cho booking này.',
            )
          else
            PortfolioPhotoGrid(
              photos: gallery.items.map((item) => item.thumbnailUrl).toList(),
            ),
          if (gallery.publishedAt == null) ...[
            const SizedBox(height: 14),
            if (!gallery.canPublish)
              const Text(
                'Backend chỉ cho phép công bố khi booking ở trạng thái shot hoặc completed.',
                style: TextStyle(color: AppColors.steel, height: 1.4),
              ),
            if (_uploading) ...[
              const Text('Đang tải và chờ Backend xử lý ảnh…'),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: _uploadProgress),
            ] else if (gallery.canPublish) ...[
              OutlinedButton.icon(
                onPressed: _uploading || _publishing ? null : _upload,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Thêm ảnh'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: gallery.items.isEmpty || _publishing
                    ? null
                    : () => _publish(gallery),
                icon: _publishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.publish_outlined),
                label: Text(_publishing ? 'Đang công bố…' : 'Công bố gallery'),
              ),
            ],
          ],
        ],
      ),
    ),
  );

  String _bookingSubtitle(BookingGallerySnapshot gallery) {
    final from = DateTime.tryParse(gallery.from);
    final to = DateTime.tryParse(gallery.to);
    if (from == null || to == null) return 'Chi tiết lấy từ Backend';
    return '${DateFormat('dd/MM/yyyy HH:mm').format(from.toLocal())} – ${DateFormat('HH:mm').format(to.toLocal())}';
  }

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Chờ xác nhận',
    'accepted' => 'Đã xác nhận',
    'in_progress' => 'Đang chụp',
    'shot' => 'Đã chụp',
    'completed' => 'Hoàn tất',
    'cancelled' => 'Đã huỷ',
    'rejected' => 'Từ chối',
    'expired' => 'Hết hạn',
    _ => status,
  };
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import '../storage/storage_provider.dart';

class DeliveryGalleryScreen extends ConsumerStatefulWidget {
  const DeliveryGalleryScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<DeliveryGalleryScreen> createState() =>
      _DeliveryGalleryScreenState();
}

class _DeliveryGalleryScreenState extends ConsumerState<DeliveryGalleryScreen> {
  bool uploading = false;

  Future<void> _uploadMockBatch(Booking booking) async {
    setState(() => uploading = true);
    try {
      // The portal mock upload also supplies stock photos. Replace this adapter
      // with a real media upload when the mobile backend is available.
      final remaining = (booking.promisedPhotos ?? 1) - booking.deliveredPhotos;
      final count = remaining.clamp(1, 5);
      final sample =
          ref.read(myPhotographerProvider)?.portfolio ?? const <String>[];
      final urls = List.generate(
        count,
        (index) => sample.isEmpty
            ? 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=700'
            : sample[(booking.deliveredPhotos + index) % sample.length],
      );
      await ref
          .read(asyncBookingsProvider.notifier)
          .addDeliveryPhotos(booking.id, urls);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã giao $count ảnh mẫu cho khách')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể giao ảnh: $error')));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomingBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ảnh buổi chụp')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Không thể tải bộ ảnh: $error')),
        data: (items) {
          Booking? booking;
          for (final item in items) {
            if (item.id == widget.bookingId) {
              booking = item;
              break;
            }
          }
          if (booking == null) {
            return const Center(child: Text('Không tìm thấy lịch chụp'));
          }
          final b = booking;
          StorageGallery? gallery;
          for (final item in ref.watch(storageGalleriesProvider)) {
            if (item.booking.id == b.id) gallery = item;
          }
          final required = b.promisedPhotos ?? 1;
          final progress = (b.deliveredPhotos / required).clamp(0.0, 1.0);
          return ListView(
            padding: AppTokens.pagePadding,
            children: [
              Text(
                'Buổi chụp ${b.style} · ${b.clientName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã giao ${b.deliveredPhotos}/$required ảnh',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        color: AppColors.ember,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.deliveredPhotos >= required
                            ? 'Đã đủ số ảnh theo gói. Đang chờ khách xác nhận nghiệm thu.'
                            : 'Cần giao thêm ${required - b.deliveredPhotos} ảnh theo gói.',
                        style: const TextStyle(color: AppColors.steel),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (gallery?.locked == true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bộ sưu tập tạm bị khóa vì vượt hạn mức gói hiện tại.',
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/photographer_home/storage'),
                          child: const Text('Nâng cấp gói để mở lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (gallery?.daysLeft != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      gallery!.daysLeft! <= 0
                          ? 'Đã hết hạn lưu trữ'
                          : 'Còn ${gallery.daysLeft} ngày lưu trữ theo gói hiện tại',
                    ),
                  ),
                ),
              if (b.status == BookingStatus.held)
                FilledButton.icon(
                  onPressed: uploading ? null : () => _uploadMockBatch(b),
                  icon: const Icon(Icons.upload_outlined),
                  label: Text(
                    uploading ? 'Đang giao ảnh...' : 'Giao tối đa 5 ảnh mẫu',
                  ),
                ),
              const SizedBox(height: 16),
              if (b.deliveredPhotoUrls.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Chưa có ảnh nào được giao')),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: b.deliveredPhotoUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: gallery?.locked == true ? 8 : 0,
                        sigmaY: gallery?.locked == true ? 8 : 0,
                      ),
                      child: Image.network(
                        b.deliveredPhotoUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColors.fog,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

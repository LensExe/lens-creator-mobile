import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/studio_booking_card.dart';
import 'bookings/widgets/collaborators_panel.dart';

class BookingRequestDetailScreen extends ConsumerStatefulWidget {
  const BookingRequestDetailScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<BookingRequestDetailScreen> createState() =>
      _BookingRequestDetailScreenState();
}

class _BookingRequestDetailScreenState
    extends ConsumerState<BookingRequestDetailScreen> {
  bool deciding = false;

  Future<void> _decide(Booking booking, BookingStatus status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == BookingStatus.confirmed
              ? 'Xác nhận lịch chụp?'
              : 'Từ chối yêu cầu?',
        ),
        content: Text(
          status == BookingStatus.confirmed
              ? 'Khách sẽ được thông báo để thanh toán phần còn lại.'
              : 'Tiền cọc ${formatDong(booking.depositAmount)} sẽ được hoàn đầy đủ cho khách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              status == BookingStatus.confirmed ? 'Xác nhận' : 'Từ chối',
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => deciding = true);
    try {
      await ref
          .read(asyncBookingsProvider.notifier)
          .updateBookingStatus(booking.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == BookingStatus.confirmed
                  ? 'Đã xác nhận lịch chụp'
                  : 'Đã từ chối và hoàn cọc',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(incomingBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch chụp')),
      body: bookings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải lịch chụp'),
              TextButton(
                onPressed: () => ref.invalidate(asyncBookingsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
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
          final date = DateTime.tryParse(b.date);
          return ListView(
            padding: AppTokens.pagePadding,
            children: [
              StudioBookingCard(booking: b, openDetail: false),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin buổi chụp',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _Row('Mã lịch', b.id),
                      _Row('Khách hàng', b.clientName),
                      if (b.contactPhone != null)
                        _Row('Số điện thoại', b.contactPhone!),
                      _Row(
                        'Ngày chụp',
                        date == null
                            ? b.date
                            : DateFormat('dd/MM/yyyy').format(date),
                      ),
                      if (b.timeSlot != null) _Row('Bắt đầu', b.timeSlot!),
                      _Row('Địa điểm', b.location),
                      if (b.packageName != null)
                        _Row('Gói dịch vụ', b.packageName!),
                      if (b.promisedPhotos != null)
                        _Row('Số ảnh cam kết', '${b.promisedPhotos} ảnh'),
                      if (b.deliveryDays != null)
                        _Row(
                          'Hạn giao',
                          '${b.deliveryDays} ngày sau buổi chụp',
                        ),
                      if (b.note?.isNotEmpty == true) _Row('Ghi chú', b.note!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thanh toán',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _Row('Tổng giá', formatDong(b.price)),
                      _Row('Đã đặt cọc', formatDong(b.depositAmount)),
                      _Row(
                        'Phí sàn (10%)',
                        formatDong(BookingRules.commission(b.price)),
                      ),
                      const Divider(),
                      _Row(
                        'Thực nhận sau nghiệm thu',
                        formatDong(BookingRules.payoutFor(b, b.photographerId)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiến trình',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Đặt cọc → Xác nhận → Thanh toán → Giao ảnh → Khách nghiệm thu',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hiện tại: ${BookingRules.statusLabel(b.status)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ember,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (b.status == BookingStatus.pending)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Khách đã đặt cọc ${formatDong(b.depositAmount)}. Xác nhận hoặc từ chối yêu cầu.',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: deciding
                                    ? null
                                    : () => _decide(b, BookingStatus.cancelled),
                                child: const Text('Từ chối'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: deciding
                                    ? null
                                    : () => _decide(b, BookingStatus.confirmed),
                                child: const Text('Xác nhận'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (b.status == BookingStatus.confirmed)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Đang chờ khách thanh toán phần còn lại.'),
                  ),
                ),
              if (b.status == BookingStatus.held ||
                  b.status == BookingStatus.released)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ảnh bàn giao: ${b.deliveredPhotos}/${b.promisedPhotos ?? 1}',
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/photographer_home/booking/${b.id}/gallery',
                          ),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(
                            b.status == BookingStatus.held
                                ? 'Giao ảnh'
                                : 'Xem ảnh',
                          ),
                        ),
                        if (b.status == BookingStatus.held)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Sàn giải ngân sau khi khách xác nhận đã nhận đủ ảnh.',
                              style: TextStyle(color: AppColors.steel),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if ((b.status == BookingStatus.confirmed ||
                      b.status == BookingStatus.held) &&
                  b.deliveredPhotos == 0) ...[
                const SizedBox(height: 12),
                CollaboratorsPanel(booking: b),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(color: AppColors.steel)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

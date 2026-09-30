import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_booking_timeline.dart';
import '../../core/widgets/creator_decision_actions.dart';
import '../../core/widgets/creator_detail_row.dart';
import '../../core/widgets/creator_section_header.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaborators_panel.dart';
import 'bookings/widgets/studio_booking_card.dart';

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
      backgroundColor: AppColors.snow,
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                children: [
                  StudioBookingCard(booking: b, openDetail: false),
                  if (b.status == BookingStatus.pending) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Khách đã đặt cọc ${formatDong(b.depositAmount)}. Xác nhận hoặc từ chối yêu cầu.',
                      style: const TextStyle(
                        color: AppColors.graphite,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CreatorDecisionActions(
                      busy: deciding,
                      onDecline: () => _decide(b, BookingStatus.cancelled),
                      onAccept: () => _decide(b, BookingStatus.confirmed),
                    ),
                  ],
                  if (b.status == BookingStatus.confirmed) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Đang chờ khách thanh toán phần còn lại.',
                      style: TextStyle(color: AppColors.steel, fontSize: 13),
                    ),
                  ],
                  if (b.status == BookingStatus.held ||
                      b.status == BookingStatus.released) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Ảnh bàn giao: ${b.deliveredPhotos}/${b.promisedPhotos ?? 1}',
                      style: const TextStyle(
                        color: AppColors.graphite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/photographer_home/booking/${b.id}/gallery',
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        b.status == BookingStatus.held ? 'Giao ảnh' : 'Xem ảnh',
                      ),
                    ),
                    if (b.status == BookingStatus.held)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Sàn giải ngân sau khi khách xác nhận đã nhận đủ ảnh.',
                          style: TextStyle(
                            color: AppColors.steel,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                  if ((b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.held) &&
                      b.deliveredPhotos == 0) ...[
                    const SizedBox(height: 18),
                    CollaboratorsPanel(booking: b),
                  ],
                  const SizedBox(height: 28),
                  const CreatorSectionHeader(title: 'Thông tin buổi chụp'),
                  const SizedBox(height: 9),
                  CreatorDetailRow(label: 'Mã lịch', value: b.id),
                  CreatorDetailRow(label: 'Khách hàng', value: b.clientName),
                  if (b.contactPhone != null)
                    CreatorDetailRow(
                      label: 'Số điện thoại',
                      value: b.contactPhone!,
                    ),
                  CreatorDetailRow(
                    label: 'Ngày chụp',
                    value: date == null
                        ? b.date
                        : DateFormat('dd/MM/yyyy').format(date),
                  ),
                  if (b.timeSlot != null)
                    CreatorDetailRow(label: 'Bắt đầu', value: b.timeSlot!),
                  CreatorDetailRow(label: 'Địa điểm', value: b.location),
                  if (b.packageName != null)
                    CreatorDetailRow(
                      label: 'Gói dịch vụ',
                      value: b.packageName!,
                    ),
                  if (b.promisedPhotos != null)
                    CreatorDetailRow(
                      label: 'Số ảnh cam kết',
                      value: '${b.promisedPhotos} ảnh',
                    ),
                  if (b.deliveryDays != null)
                    CreatorDetailRow(
                      label: 'Hạn giao',
                      value: '${b.deliveryDays} ngày sau buổi chụp',
                    ),
                  if (b.note?.isNotEmpty == true)
                    CreatorDetailRow(label: 'Ghi chú', value: b.note!),
                  const SizedBox(height: 27),
                  const CreatorSectionHeader(title: 'Thanh toán'),
                  const SizedBox(height: 9),
                  CreatorDetailRow(
                    label: 'Tổng giá',
                    value: formatDong(b.price),
                  ),
                  CreatorDetailRow(
                    label: 'Đã đặt cọc',
                    value: formatDong(b.depositAmount),
                  ),
                  CreatorDetailRow(
                    label: 'Phí sàn (10%)',
                    value: formatDong(BookingRules.commission(b.price)),
                  ),
                  const Divider(),
                  CreatorDetailRow(
                    label: 'Thực nhận sau nghiệm thu',
                    value: formatDong(
                      BookingRules.payoutFor(b, b.photographerId),
                    ),
                    emphasized: true,
                  ),
                  const SizedBox(height: 27),
                  const CreatorSectionHeader(title: 'Tiến trình'),
                  const SizedBox(height: 13),
                  CreatorBookingTimeline(status: b.status),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

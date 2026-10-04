import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_avatar.dart';
import '../../core/widgets/creator_booking_timeline.dart';
import '../../core/widgets/creator_decision_actions.dart';
import '../../core/widgets/creator_detail_row.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_loading_state.dart';
import '../../core/widgets/creator_status_badge.dart';
import '../../domain/booking_rules.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/collaborators_panel.dart';
import 'bookings/widgets/studio_booking_card.dart' show formatDong;
import 'messages/conversation_navigation.dart';

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
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Chi tiết lịch chụp')),
      body: bookings.when(
        loading: () =>
            const CreatorLoadingState(label: 'Đang tải thông tin buổi chụp…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải lịch chụp',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(asyncBookingsProvider),
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
            return const CreatorEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Không tìm thấy lịch chụp',
            );
          }
          final b = booking;
          final date = DateTime.tryParse(b.date);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                children: [
                  _BookingIdentityCard(booking: b, date: date),
                  const SizedBox(height: 12),
                  _ContactActions(
                    booking: b,
                    onMessage: () => openClientConversation(context, ref, b),
                    onShare: () async {
                      final route = GoRouterState.of(context).uri.toString();
                      await Clipboard.setData(ClipboardData(text: route));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép liên kết lịch đặt'),
                          ),
                        );
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Tính năng tải hoá đơn VAT sẽ sớm khả dụng',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.receipt_long_outlined, size: 17),
                      label: const Text('Tải hoá đơn VAT'),
                    ),
                  ),
                  if (b.status == BookingStatus.pending) ...[
                    const SizedBox(height: 4),
                    _DecisionPanel(
                      booking: b,
                      busy: deciding,
                      onDecline: () => _decide(b, BookingStatus.cancelled),
                      onAccept: () => _decide(b, BookingStatus.confirmed),
                    ),
                  ],
                  if (b.status == BookingStatus.confirmed) ...[
                    const SizedBox(height: 4),
                    const _StatusNotice(
                      icon: Icons.hourglass_top_rounded,
                      text: 'Đang chờ khách thanh toán phần còn lại.',
                    ),
                  ],
                  if (b.status == BookingStatus.held ||
                      b.status == BookingStatus.released) ...[
                    const SizedBox(height: 4),
                    _DeliveryPanel(booking: b),
                  ],
                  if ((b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.held) &&
                      b.deliveredPhotos == 0) ...[
                    const SizedBox(height: 14),
                    CollaboratorsPanel(booking: b),
                  ],
                  const SizedBox(height: 18),
                  _DetailSection(
                    title: 'Thông tin buổi chụp',
                    icon: Icons.photo_camera_outlined,
                    children: [
                      CreatorDetailRow(label: 'Mã lịch', value: b.id),
                      CreatorDetailRow(
                        label: 'Khách hàng',
                        value: b.clientName,
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: 'Thanh toán',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
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
                      const Divider(height: 1),
                      CreatorDetailRow(
                        label: 'Thực nhận sau nghiệm thu',
                        value: formatDong(
                          BookingRules.payoutFor(b, b.photographerId),
                        ),
                        emphasized: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: 'Tiến trình',
                    icon: Icons.route_outlined,
                    children: [CreatorBookingTimeline(status: b.status)],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingIdentityCard extends StatelessWidget {
  const _BookingIdentityCard({required this.booking, required this.date});

  final Booking booking;
  final DateTime? date;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.fog),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CreatorAvatar(name: booking.clientName, size: 54),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.clientName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.35,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.style,
                    style: const TextStyle(
                      color: AppColors.steel,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CreatorStatusBadge(status: booking.status),
            if (booking.packageName != null)
              _ContextChip(
                icon: Icons.photo_camera_outlined,
                label: booking.packageName!,
              ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Divider(height: 1),
        ),
        _IdentityMeta(
          icon: Icons.calendar_today_outlined,
          label: date == null
              ? booking.date
              : DateFormat('dd/MM/yyyy').format(date!),
        ),
        if (booking.timeSlot != null) ...[
          const SizedBox(height: 9),
          _IdentityMeta(icon: Icons.schedule_rounded, label: booking.timeSlot!),
        ],
        const SizedBox(height: 9),
        _IdentityMeta(
          icon: Icons.location_on_outlined,
          label: booking.location,
        ),
        const SizedBox(height: 13),
        Text(
          formatDong(booking.price),
          style: const TextStyle(
            color: AppColors.obsidian,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    ),
  );
}

class _IdentityMeta extends StatelessWidget {
  const _IdentityMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AppColors.ember),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 220),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.mist,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.graphite),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.graphite,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({
    required this.booking,
    required this.onMessage,
    required this.onShare,
  });

  final Booking booking;
  final VoidCallback onMessage;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      if (booking.contactPhone?.isNotEmpty == true)
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Số điện thoại: ${booking.contactPhone}')),
          ),
          icon: const Icon(Icons.call_outlined, size: 17),
          label: const Text('Liên hệ'),
        ),
      FilledButton.tonalIcon(
        onPressed: onMessage,
        icon: const Icon(Icons.chat_bubble_outline, size: 17),
        label: const Text('Nhắn tin'),
      ),
      OutlinedButton.icon(
        onPressed: onShare,
        icon: const Icon(Icons.share_outlined, size: 17),
        label: const Text('Chia sẻ'),
      ),
    ],
  );
}

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel({
    required this.booking,
    required this.busy,
    required this.onDecline,
    required this.onAccept,
  });

  final Booking booking;
  final bool busy;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.emberSoft,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yêu cầu đang chờ phản hồi',
          style: TextStyle(
            color: AppColors.obsidian,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Khách đã đặt cọc ${formatDong(booking.depositAmount)}. Xác nhận hoặc từ chối yêu cầu.',
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        CreatorDecisionActions(
          busy: busy,
          onDecline: onDecline,
          onAccept: onAccept,
        ),
      ],
    ),
  );
}

class _DeliveryPanel extends StatelessWidget {
  const _DeliveryPanel({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.fog),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ảnh bàn giao: ${booking.deliveredPhotos}/${booking.promisedPhotos ?? 1}',
          style: const TextStyle(
            color: AppColors.graphite,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () =>
              context.push('/photographer_home/booking/${booking.id}/gallery'),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(
            booking.status == BookingStatus.held ? 'Giao ảnh' : 'Xem ảnh',
          ),
        ),
        if (booking.status == BookingStatus.held) ...[
          const SizedBox(height: 7),
          const Text(
            'Sàn giải ngân sau khi khách xác nhận đã nhận đủ ảnh.',
            style: TextStyle(color: AppColors.steel, fontSize: 12),
          ),
        ],
      ],
    ),
  );
}

class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.fog),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.ember),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.graphite, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 14, 15, 11),
    decoration: BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.fog),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.ember, size: 17),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.obsidian,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ...children,
      ],
    ),
  );
}

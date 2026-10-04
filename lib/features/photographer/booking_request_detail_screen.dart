import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_avatar.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_loading_state.dart';
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
      backgroundColor: const Color(0xFFF9F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF1A1C1D),
          ),
          tooltip: 'Quay lại',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Chi tiết lịch chụp',
          style: TextStyle(
            color: Color(0xFF1A1C1D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 22,
              color: Color(0xFF5F5E60),
            ),
            tooltip: 'Tuỳ chọn khác',
            onSelected: (value) async {
              if (value == 'share') {
                final route = GoRouterState.of(context).uri.toString();
                await Clipboard.setData(ClipboardData(text: route));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép liên kết lịch đặt'),
                    ),
                  );
                }
              } else if (value == 'invoice') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng tải hoá đơn VAT sẽ sớm khả dụng'),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Color(0xFF5F5E60),
                    ),
                    SizedBox(width: 10),
                    Text('Chia sẻ lịch đặt'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'invoice',
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                      color: Color(0xFF5F5E60),
                    ),
                    SizedBox(width: 10),
                    Text('Tải hoá đơn VAT / Phiếu thu'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  // 1. Hero Identity Card
                  _BookingHeroCard(booking: b, date: date),
                  const SizedBox(height: 14),

                  // 2. Action Required / Decision Panel (Pending)
                  if (b.status == BookingStatus.pending) ...[
                    _DecisionPanel(
                      booking: b,
                      busy: deciding,
                      onDecline: () => _decide(b, BookingStatus.cancelled),
                      onAccept: () => _decide(b, BookingStatus.confirmed),
                    ),
                    const SizedBox(height: 14),
                  ] else if (b.status == BookingStatus.confirmed) ...[
                    const _StatusNoticeCard(
                      icon: Icons.hourglass_top_rounded,
                      text: 'Đang chờ khách thanh toán phần còn lại.',
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3. Quick Contact Strip
                  _QuickContactStrip(
                    booking: b,
                    onCall: () {
                      if (b.contactPhone?.isNotEmpty == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Số điện thoại: ${b.contactPhone}'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chưa có số điện thoại khách hàng'),
                          ),
                        );
                      }
                    },
                    onMessage: () => openClientConversation(context, ref, b),
                    onDownloadInvoice: () => ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng tải hoá đơn VAT sẽ sớm khả dụng',
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Delivery Progress
                  if (b.status != BookingStatus.cancelled) ...[
                    _DeliveryProgressCard(
                      booking: b,
                      onManage: () => context.push(
                        '/photographer_home/booking/${b.id}/gallery',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Collaborator Invitation Panel (for confirmed/held shoots)
                  if ((b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.held) &&
                      b.deliveredPhotos == 0) ...[
                    CollaboratorsPanel(booking: b),
                    const SizedBox(height: 14),
                  ],

                  // 5. Payment & Payout Summary
                  _PaymentPayoutSummaryCard(booking: b),
                  const SizedBox(height: 14),

                  // 6. Additional Details
                  _AdditionalDetailsCard(booking: b),
                  const SizedBox(height: 14),

                  // 7. Booking Timeline
                  _BookingTimelineCard(booking: b, date: date),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 1. HERO IDENTITY CARD
// ============================================================================
class _BookingHeroCard extends StatelessWidget {
  const _BookingHeroCard({required this.booking, required this.date});

  final Booking booking;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final styleOrPackage = booking.packageName ?? booking.style;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name/Package + Status Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFDBCF), width: 2),
                ),
                child: ClipOval(
                  child: CreatorAvatar(name: booking.clientName, size: 48),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1C1D),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEF),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              styleOrPackage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5B4137),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 0,
                child: _BookingStatusPill(status: booking.status),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Logistics Box (Date/Time & Location)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFFFF5A00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _formatVietnameseDate(date, booking.date),
                              style: const TextStyle(
                                color: Color(0xFF1A1C1D),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (booking.timeSlot != null) ...[
                              const TextSpan(
                                text: '  •  ',
                                style: TextStyle(
                                  color: Color(0xFF5F5E60),
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: booking.timeSlot!,
                                style: const TextStyle(
                                  color: Color(0xFF5F5E60),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFFFF5A00),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.location,
                        style: const TextStyle(
                          color: Color(0xFF5F5E60),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total Booking Value
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEEEEF))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Expanded(
                  child: Text(
                    'Tổng giá trị buổi chụp',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF5F5E60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDong(booking.price),
                  style: const TextStyle(
                    color: Color(0xFFFF5A00),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS PILL (Matching HTML)
// ============================================================================
class _BookingStatusPill extends StatelessWidget {
  const _BookingStatusPill({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color dot;
    String label;

    switch (status) {
      case BookingStatus.pending:
        bg = const Color(0xFFFFDBCF);
        text = const Color(0xFF802900);
        dot = const Color(0xFFFF5A00);
        label = 'Chờ phản hồi';
        break;
      case BookingStatus.awaitingDeposit:
        bg = const Color(0xFFFFF4E5);
        text = const Color(0xFFB45309);
        dot = const Color(0xFFF59E0B);
        label = 'Chờ đặt cọc';
        break;
      case BookingStatus.confirmed:
        bg = const Color(0xFFE9F6EF);
        text = const Color(0xFF047857);
        dot = const Color(0xFF10B981);
        label = 'Đã xác nhận';
        break;
      case BookingStatus.held:
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        dot = const Color(0xFF3B82F6);
        label = 'Đang thực hiện';
        break;
      case BookingStatus.released:
        bg = const Color(0xFFE9F6EF);
        text = const Color(0xFF047857);
        dot = const Color(0xFF10B981);
        label = 'Đã hoàn thành';
        break;
      case BookingStatus.cancelled:
        bg = const Color(0xFFEEEEEE);
        text = const Color(0xFF6B7280);
        dot = const Color(0xFF9CA3AF);
        label = 'Đã huỷ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. DECISION PANEL (Action Required)
// ============================================================================
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
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0x59FFDBCF),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x99FFB59A)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_active,
              size: 20,
              color: Color(0xFFFF5A00),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yêu cầu đang chờ bạn phản hồi',
                    style: TextStyle(
                      color: Color(0xFF1A1C1D),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Khách hàng đã đặt cọc '),
                        TextSpan(
                          text: formatDong(booking.depositAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1C1D),
                          ),
                        ),
                        const TextSpan(
                          text: ' qua LENS Escrow. Vui lòng phản hồi sớm để hoàn tất xác nhận lịch.',
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      color: Color(0xFF5B4137),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5F5E60),
                    side: const BorderSide(color: Color(0xFFEEEEEF)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    elevation: 0,
                  ),
                  onPressed: busy ? null : onDecline,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Từ chối lịch',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  onPressed: busy ? null : onAccept,
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Xác nhận lịch',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ============================================================================
// STATUS NOTICE CARD (For Confirmed State)
// ============================================================================
class _StatusNoticeCard extends StatelessWidget {
  const _StatusNoticeCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF5A00)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5F5E60),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// 3. QUICK CONTACT STRIP
// ============================================================================
class _QuickContactStrip extends StatelessWidget {
  const _QuickContactStrip({
    required this.booking,
    required this.onCall,
    required this.onMessage,
    required this.onDownloadInvoice,
  });

  final Booking booking;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onDownloadInvoice;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: InkWell(
                  onTap: onCall,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.call_outlined,
                          size: 18,
                          color: Color(0xFF5F5E60),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Gọi khách',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF1A1C1D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: InkWell(
                  onTap: onMessage,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDBCF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          size: 17,
                          color: Color(0xFF802900),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Nhắn tin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF802900),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onDownloadInvoice,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: Color(0xFF5F5E60),
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Tải hoá đơn VAT / Phiếu thu (.PDF)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5F5E60),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF5F5E60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// 4. DELIVERY PROGRESS
// ============================================================================
class _DeliveryProgressCard extends StatelessWidget {
  const _DeliveryProgressCard({required this.booking, required this.onManage});

  final Booking booking;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final promised = booking.promisedPhotos ?? 35;
    final delivered = booking.deliveredPhotos;
    final ratio = promised > 0 ? (delivered / promised).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 20,
                      color: Color(0xFFFF5A00),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Tiến độ bàn giao',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1A1C1D),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$delivered / $promised ảnh',
                style: const TextStyle(
                  color: Color(0xFF5F5E60),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 8,
              width: double.infinity,
              color: const Color(0xFFEEEEEF),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(color: const Color(0xFFFF5A00)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Footer
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Giao ảnh sau buổi chụp qua thư viện LENS',
                  style: TextStyle(color: Color(0xFF5F5E60), fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onManage,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F4),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFFEEEEEF)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quản lý giao ảnh',
                        style: TextStyle(
                          color: Color(0xFF1A1C1D),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 13,
                        color: Color(0xFF1A1C1D),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. PAYMENT & PAYOUT SUMMARY
// ============================================================================
class _PaymentPayoutSummaryCard extends StatelessWidget {
  const _PaymentPayoutSummaryCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final remaining = (booking.price - booking.depositAmount).clamp(
      0,
      booking.price,
    );
    final platformFee = BookingRules.commission(booking.price);
    final payout = BookingRules.payoutFor(booking, booking.photographerId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: Color(0xFFFF5A00),
              ),
              SizedBox(width: 8),
              Text(
                'Thanh toán & Thu nhập',
                style: TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEF)),
          const SizedBox(height: 10),

          // Total
          _buildPaymentRow(
            label: 'Tổng giá trị đơn',
            value: formatDong(booking.price),
            valueColor: const Color(0xFF1A1C1D),
          ),
          const SizedBox(height: 8),

          // Deposit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Đã đặt cọc (Escrow giữ)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF5F5E60),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Color(0xFFA83900),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDong(booking.depositAmount),
                style: const TextStyle(
                  color: Color(0xFFA83900),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Remaining
          _buildPaymentRow(
            label: 'Thu còn lại khi giao ảnh',
            value: formatDong(remaining),
            valueColor: const Color(0xFF1A1C1D),
          ),
          const SizedBox(height: 8),

          // Platform Fee
          _buildPaymentRow(
            label: 'Phí nền tảng (10%)',
            value: '-${formatDong(platformFee)}',
            valueColor: const Color(0xFF5F5E60),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEF)),
          const SizedBox(height: 10),

          // Net Payout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Text(
                  'Thực nhận sau nghiệm thu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDong(payout),
                style: const TextStyle(
                  color: Color(0xFFFF5A00),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    required Color valueColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// ============================================================================
// 6. ADDITIONAL DETAILS
// ============================================================================
class _AdditionalDetailsCard extends StatelessWidget {
  const _AdditionalDetailsCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Color(0xFFFF5A00)),
            SizedBox(width: 8),
            Text(
              'Thông tin bổ sung',
              style: TextStyle(
                color: Color(0xFF1A1C1D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFEEEEEF)),
        const SizedBox(height: 10),

        // Booking ID with Copy
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Mã đơn đặt',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  '#${booking.id}',
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: booking.id));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép mã đơn!')),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.content_copy,
                      size: 15,
                      color: Color(0xFF5F5E60),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Phone
        if (booking.contactPhone != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Số điện thoại',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _maskPhone(booking.contactPhone!),
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Turnaround time
        if (booking.deliveryDays != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Hạn bàn giao cam kết',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${booking.deliveryDays} ngày sau buổi chụp',
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Promised Photos
        if (booking.promisedPhotos != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Số ảnh cam kết',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${booking.promisedPhotos} ảnh',
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Customer Note
        if (booking.note?.isNotEmpty == true) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_note, size: 16, color: Color(0xFF5F5E60)),
                    SizedBox(width: 4),
                    Text(
                      'Ghi chú từ khách:',
                      style: TextStyle(
                        color: Color(0xFF5F5E60),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '“${booking.note}”',
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

// ============================================================================
// 7. BOOKING TIMELINE
// ============================================================================
class _BookingTimelineCard extends StatelessWidget {
  const _BookingTimelineCard({required this.booking, required this.date});

  final Booking booking;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final payout = BookingRules.payoutFor(booking, booking.photographerId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, size: 20, color: Color(0xFFFF5A00)),
              SizedBox(width: 8),
              Text(
                'Tiến trình lịch chụp',
                style: TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEF)),
          const SizedBox(height: 14),

          // Step 1: Deposit
          _buildTimelineStep(
            isLast: false,
            isCompleted: booking.status != BookingStatus.awaitingDeposit,
            isActive: booking.status == BookingStatus.awaitingDeposit,
            title:
                'Đặt cọc Escrow thành công (${formatDong(booking.depositAmount)})',
            badgeText: booking.status != BookingStatus.awaitingDeposit
                ? 'Xong'
                : 'Chờ',
            subtitle: 'Đã hoàn tất thanh toán cọc',
          ),

          // Step 2: Confirmation
          _buildTimelineStep(
            isLast: false,
            isCompleted:
                booking.status == BookingStatus.confirmed ||
                booking.status == BookingStatus.held ||
                booking.status == BookingStatus.released,
            isActive: booking.status == BookingStatus.pending,
            isCancelled: booking.status == BookingStatus.cancelled,
            title: booking.status == BookingStatus.cancelled
                ? 'Lịch chụp đã bị từ chối / huỷ'
                : (booking.status == BookingStatus.pending
                      ? 'Đang chờ studio xác nhận'
                      : 'Studio đã xác nhận lịch'),
            badgeText: booking.status == BookingStatus.pending
                ? 'Đang chờ'
                : (booking.status == BookingStatus.cancelled
                      ? 'Đã huỷ'
                      : 'Xong'),
            subtitle: booking.status == BookingStatus.pending
                ? 'Hiện tại'
                : (booking.status == BookingStatus.cancelled
                      ? 'Đã hoàn cọc cho khách'
                      : 'Đã chấp nhận yêu cầu'),
          ),

          // Step 3: Shooting Session
          _buildTimelineStep(
            isLast: false,
            isCompleted: booking.status == BookingStatus.released,
            isActive: booking.status == BookingStatus.held,
            title: booking.status == BookingStatus.held
                ? 'Đang thực hiện & chuẩn bị giao ảnh'
                : (booking.status == BookingStatus.released
                      ? 'Đã thực hiện buổi chụp'
                      : 'Thực hiện buổi chụp'),
            badgeText: booking.status == BookingStatus.held
                ? 'Đang chụp'
                : (booking.status == BookingStatus.released ? 'Xong' : null),
            subtitle: 'Dự kiến ${_formatVietnameseDate(date, booking.date)}',
          ),

          // Step 4: Release & Payout
          _buildTimelineStep(
            isLast: true,
            isCompleted: booking.status == BookingStatus.released,
            isActive: false,
            title: 'Nghiệm thu & Giải ngân ví Studio (${formatDong(payout)})',
            badgeText: booking.status == BookingStatus.released ? 'Xong' : null,
            subtitle: 'Dự kiến sau bàn giao',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required bool isLast,
    required bool isCompleted,
    required bool isActive,
    bool isCancelled = false,
    required String title,
    String? badgeText,
    required String subtitle,
  }) {
    Color indicatorBg;
    Widget indicatorChild;

    if (isCancelled) {
      indicatorBg = AppColors.destructive;
      indicatorChild = const Icon(Icons.close, size: 11, color: Colors.white);
    } else if (isCompleted) {
      indicatorBg = const Color(0xFFFF5A00);
      indicatorChild = const Icon(Icons.check, size: 11, color: Colors.white);
    } else if (isActive) {
      indicatorBg = const Color(0xFFFF5A00);
      indicatorChild = Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      indicatorBg = const Color(0xFFEEEEEF);
      indicatorChild = Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFF5F5E60),
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator & vertical line
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: indicatorBg,
                  shape: BoxShape.circle,
                ),
                child: indicatorChild,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFEEEEEF)),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFFFF5A00)
                              : (isCompleted || isCancelled
                                    ? const Color(0xFF1A1C1D)
                                    : const Color(0xFF5F5E60)),
                          fontSize: 13,
                          fontWeight: isActive || isCompleted
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFDBCF)
                                : (isCancelled
                                      ? const Color(0xFFFFDAD6)
                                      : const Color(0xFFEEEEEF)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF802900)
                                  : (isCancelled
                                        ? const Color(0xFFBA1A1A)
                                        : const Color(0xFF5F5E60)),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF5F5E60),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HELPERS
// ============================================================================
String _formatVietnameseDate(DateTime? date, String fallback) {
  if (date == null) return fallback;
  const days = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];
  final dayName = days[date.weekday - 1];
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$dayName, $d/$m/$y';
}

String _maskPhone(String phone) {
  final clean = phone.replaceAll(' ', '');
  if (clean.length >= 8) {
    final prefix = clean.substring(0, 4);
    final suffix = clean.substring(clean.length - 3);
    return '$prefix ••• $suffix';
  }
  return phone;
}

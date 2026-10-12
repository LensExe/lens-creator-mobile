import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/creator_avatar.dart';
import '../../core/widgets/creator_empty_state.dart';
import '../../core/widgets/creator_loading_state.dart';
import '../../data/repositories/api_booking_repository.dart';
import '../../domain/models/models.dart';
import '../../providers/data_providers.dart';
import 'bookings/widgets/studio_booking_card.dart' show formatDong;

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
    final reason = status == BookingStatus.rejected
        ? await _askRejectReason()
        : null;
    if (!mounted) return;
    if (status == BookingStatus.rejected && reason == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == BookingStatus.accepted
              ? 'Xác nhận lịch chụp?'
              : 'Từ chối yêu cầu?',
        ),
        content: Text(
          status == BookingStatus.accepted
              ? 'Backend sẽ kiểm tra trạng thái thanh toán và xung đột lịch trước khi chấp nhận.'
              : 'Lý do từ chối sẽ được lưu vào lịch sử booking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              status == BookingStatus.accepted ? 'Xác nhận' : 'Từ chối',
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
          .updateBookingStatus(booking.id, status, reason: reason);
      ref.invalidate(creatorBookingDetailProvider(booking.id));
      ref.invalidate(creatorBookingTimelineProvider(booking.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == BookingStatus.accepted
                  ? 'Backend đã chấp nhận booking'
                  : 'Backend đã ghi nhận việc từ chối',
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

  Future<String?> _askRejectReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 10000,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Nhập lý do'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Từ chối booking'),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
  }

  Future<void> _advanceLifecycle(Booking booking, BookingStatus status) async {
    final isStarting = status == BookingStatus.inProgress;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isStarting ? 'Bắt đầu buổi chụp?' : 'Xác nhận đã chụp?'),
        content: Text(
          isStarting
              ? 'Backend sẽ xác nhận điều kiện thanh toán trước khi chuyển booking sang đang chụp.'
              : 'Backend sẽ ghi nhận buổi chụp hoàn tất. Sau đó bạn có thể quản lý gallery cho booking này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(isStarting ? 'Bắt đầu' : 'Xác nhận'),
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
      ref.invalidate(creatorBookingDetailProvider(booking.id));
      ref.invalidate(creatorBookingTimelineProvider(booking.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isStarting
                  ? 'Backend đã ghi nhận bắt đầu buổi chụp.'
                  : 'Backend đã ghi nhận buổi chụp hoàn tất.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backend chưa cập nhật booking: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(
      creatorBookingDetailProvider(widget.bookingId),
    );
    final timelineState = ref.watch(
      creatorBookingTimelineProvider(widget.bookingId),
    );
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
            ],
          ),
        ],
      ),
      body: bookingState.when(
        loading: () =>
            const CreatorLoadingState(label: 'Đang tải thông tin buổi chụp…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải lịch chụp',
          actionLabel: 'Thử lại',
          onAction: () =>
              ref.invalidate(creatorBookingDetailProvider(widget.bookingId)),
        ),
        data: (b) {
          final date = DateTime.tryParse(b.date);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTokens.contentMaxWidth,
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  // 1. Hero Identity Card
                  _BookingHeroCard(booking: b, date: date),
                  const SizedBox(height: 14),

                  // 2. Action Required / Decision Panel (Pending)
                  if (b.status == BookingStatus.pending) ...[
                    _DecisionPanel(
                      booking: b,
                      busy: deciding,
                      onDecline: () => _decide(b, BookingStatus.rejected),
                      onAccept: () => _decide(b, BookingStatus.accepted),
                    ),
                    const SizedBox(height: 14),
                  ] else if (b.status == BookingStatus.accepted) ...[
                    _LifecycleActionCard(
                      title: 'Booking đã được chấp nhận',
                      description: 'Backend sẽ kiểm tra khoản cọc khi bắt đầu buổi chụp.',
                      actionLabel: 'Bắt đầu buổi chụp',
                      busy: deciding,
                      onPressed: () =>
                          _advanceLifecycle(b, BookingStatus.inProgress),
                    ),
                    const SizedBox(height: 14),
                  ] else if (b.status == BookingStatus.inProgress) ...[
                    _LifecycleActionCard(
                      title: 'Buổi chụp đang diễn ra',
                      description: 'Sau khi hoàn tất buổi chụp, cập nhật trạng thái để mở gallery bàn giao.',
                      actionLabel: 'Xác nhận đã chụp',
                      busy: deciding,
                      onPressed: () => _advanceLifecycle(b, BookingStatus.shot),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (b.status == BookingStatus.shot ||
                      b.status == BookingStatus.completed) ...[
                    _DeliveryProgressCard(
                      booking: b,
                      onManage: () => context.push(
                        '/photographer_home/booking/${b.id}/gallery',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  _BookingAmountsCard(booking: b),
                  const SizedBox(height: 14),

                  _AdditionalDetailsCard(booking: b),
                  const SizedBox(height: 14),

                  _BookingTimelineCard(
                    state: timelineState,
                    onRetry: () =>
                        ref.invalidate(creatorBookingTimelineProvider(b.id)),
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
                  child: CreatorAvatar(name: booking.displayClientName, size: 48),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.displayClientName,
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
      case BookingStatus.accepted:
      case BookingStatus.confirmed:
        bg = const Color(0xFFE9F6EF);
        text = const Color(0xFF047857);
        dot = const Color(0xFF10B981);
        label = 'Đã chấp nhận';
        break;
      case BookingStatus.inProgress:
      case BookingStatus.held:
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        dot = const Color(0xFF3B82F6);
        label = 'Đang chụp';
        break;
      case BookingStatus.shot:
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF1D4ED8);
        dot = const Color(0xFF3B82F6);
        label = 'Đã chụp';
        break;
      case BookingStatus.completed:
      case BookingStatus.released:
        bg = const Color(0xFFE9F6EF);
        text = const Color(0xFF047857);
        dot = const Color(0xFF10B981);
        label = 'Hoàn thành';
        break;
      case BookingStatus.rejected:
      case BookingStatus.expired:
      case BookingStatus.cancelled:
        bg = const Color(0xFFEEEEEE);
        text = const Color(0xFF6B7280);
        dot = const Color(0xFF9CA3AF);
        label = switch (status) {
          BookingStatus.rejected => 'Đã từ chối',
          BookingStatus.expired => 'Hết hạn',
          _ => 'Đã huỷ',
        };
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
                        const TextSpan(
                          text: 'Backend kiểm tra khoản cọc và xung đột lịch khi chấp nhận booking. Nếu chưa đủ điều kiện, thao tác sẽ trả lỗi để bạn xử lý.',
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
// BOOKING LIFECYCLE ACTIONS
// ============================================================================
class _LifecycleActionCard extends StatelessWidget {
  const _LifecycleActionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.busy,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String actionLabel;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: busy ? null : onPressed,
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(actionLabel),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// DELIVERY GALLERY ENTRY
// ============================================================================
class _DeliveryProgressCard extends StatelessWidget {
  const _DeliveryProgressCard({required this.booking, required this.onManage});

  final Booking booking;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final canManage = booking.status == BookingStatus.shot;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_library_outlined, color: Color(0xFFFF5A00)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Gallery được quản lý và công bố qua Backend cho booking này.',
              style: TextStyle(color: Color(0xFF5F5E60), fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onManage,
            child: Text(canManage ? 'Quản lý gallery' : 'Mở gallery'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. PAYMENT & PAYOUT SUMMARY
// ============================================================================
class _BookingAmountsCard extends StatelessWidget {
  const _BookingAmountsCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giá trị booking',
          style: TextStyle(
            color: Color(0xFF1A1C1D),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _amountRow('Tổng giá trị', formatDong(booking.price)),
        const SizedBox(height: 8),
        _amountRow('Mức cọc yêu cầu', formatDong(booking.depositAmount)),
        const SizedBox(height: 8),
        const Text(
          'Trạng thái thanh toán và số tiền đã thu không có trong response booking này.',
          style: TextStyle(color: Color(0xFF71717A), fontSize: 11, height: 1.4),
        ),
      ],
    ),
  );

  Widget _amountRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Mã booking',
            style: TextStyle(color: Color(0xFF5F5E60), fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            booking.id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: 'Sao chép mã booking',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: booking.id));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép mã booking.')),
              );
            }
          },
          icon: const Icon(Icons.content_copy, size: 16),
        ),
      ],
    ),
  );
}

// ============================================================================
// 7. BOOKING TIMELINE
// ============================================================================
class _BookingTimelineCard extends StatelessWidget {
  const _BookingTimelineCard({required this.state, required this.onRetry});

  final AsyncValue<List<BookingTimelineEntry>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEEEEEF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.timeline, size: 20, color: Color(0xFFFF5A00)),
            SizedBox(width: 8),
            Text(
              'Lịch sử booking',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        state.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Row(
            children: [
              const Expanded(child: Text('Không tải được lịch sử từ Backend.')),
              TextButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
          data: (entries) => entries.isEmpty
              ? const Text('Backend chưa có bản ghi lịch sử cho booking này.')
              : Column(
                  children: [
                    for (final entry in entries)
                      _TimelineEntryTile(entry: entry),
                  ],
                ),
        ),
      ],
    ),
  );
}

class _TimelineEntryTile extends StatelessWidget {
  const _TimelineEntryTile({required this.entry});

  final BookingTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final from = entry.fromStatus.isEmpty
        ? null
        : _timelineStatusLabel(entry.fromStatus);
    final title = from == null
        ? 'Tạo booking · ${_timelineStatusLabel(entry.toStatus)}'
        : '$from → ${_timelineStatusLabel(entry.toStatus)}';
    final date = entry.createdAt;
    final timestamp = date == null
        ? 'Thời gian không có trong response'
        : DateFormat('dd/MM/yyyy HH:mm').format(date);
    final actor = switch (entry.actorRole) {
      'customer' => 'Khách hàng',
      'photographer' => 'Nhiếp ảnh gia',
      'admin' => 'Quản trị viên',
      'system' => 'Hệ thống',
      _ => 'Backend',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 9, color: Color(0xFFFF5A00)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '$actor · $timestamp',
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 11,
                  ),
                ),
                if (entry.reason.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text('Lý do: ${entry.reason}'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _timelineStatusLabel(String status) => switch (status) {
  'pending' => 'Chờ xác nhận',
  'accepted' => 'Đã chấp nhận',
  'rejected' => 'Đã từ chối',
  'cancelled' => 'Đã huỷ',
  'expired' => 'Hết hạn',
  'in_progress' => 'Đang chụp',
  'shot' => 'Đã chụp',
  'completed' => 'Hoàn thành',
  _ => status,
};

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

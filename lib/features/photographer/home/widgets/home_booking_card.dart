import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/creator_avatar.dart';
import '../../../../domain/booking_rules.dart';
import '../../../../domain/models/models.dart';

class HomeBookingCard extends StatelessWidget {
  const HomeBookingCard({super.key, required this.booking, this.onDecide});

  final Booking booking;
  final Future<void> Function(BookingStatus, {String? reason})? onDecide;

  String get _money =>
      '${NumberFormat.decimalPattern('vi').format(booking.price)} đ';

  String get _deposit =>
      '${NumberFormat.decimalPattern('vi').format(booking.depositAmount)} đ';

  String get _dateAndTime {
    final date = DateTime.tryParse(booking.date);
    final dateLabel = date == null
        ? booking.date
        : DateFormat('dd/MM/yyyy').format(date);
    final start = booking.timeSlot;
    if (start == null || start.isEmpty) return dateLabel;

    final duration = booking.durationHours;
    if (duration == null) return '$dateLabel · $start';
    final parts = start.split(':');
    if (parts.length != 2) return '$dateLabel · $start';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return '$dateLabel · $start';
    final totalMinutes = (hour * 60 + minute + duration * 60).round().clamp(
      0,
      24 * 60,
    );
    final end =
        '${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')}';
    return '$dateLabel · $start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E5E4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.push('/photographer_home/booking/${booking.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isPending && onDecide != null
                ? _buildPendingCard(context)
                : _buildUpcomingCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    final hasDeposit = booking.depositAmount > 0;
    final package = booking.packageName?.trim();
    final service = package == null || package.isEmpty
        ? booking.style
        : '${booking.style} · $package';
    final locationText = booking.location.isNotEmpty
        ? ' (${booking.location})'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreatorAvatar(name: booking.displayClientName, size: 40),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mã booking ${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                    style: TextStyle(color: Color(0xFF8E8D91), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDBCF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Chờ duyệt',
                style: TextStyle(
                  color: Color(0xFFA83900),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: Color(0xFFA83900),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1C1D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    size: 16,
                    color: Color(0xFF656466),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$_dateAndTime$locationText',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF656466),
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F1),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Tổng: ',
                      style: const TextStyle(
                        color: Color(0xFF737278),
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: _money,
                          style: const TextStyle(
                            color: Color(0xFF1A1C1D),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasDeposit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x66A7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: Color(0xFF047857),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Mức cọc yêu cầu: $_deposit',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: () async {
                    final reason = await _askRejectReason(context);
                    if (reason != null) {
                      await onDecide!(BookingStatus.rejected, reason: reason);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    foregroundColor: const Color(0xFF474649),
                    side: const BorderSide(color: Color(0xFFE2E1E3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text(
                    'Từ chối',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 36,
                child: FilledButton(
                  onPressed: () => onDecide!(BookingStatus.accepted),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    backgroundColor: const Color(0xFF1A1C1D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text(
                    'Xác nhận',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(BuildContext context) {
    final package = booking.packageName?.trim();
    final service = package == null || package.isEmpty
        ? booking.style
        : '${booking.style} · $package';
    final galleryAvailable =
        booking.status == BookingStatus.shot ||
        booking.status == BookingStatus.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreatorAvatar(name: booking.displayClientName, size: 40),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mã booking ${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                    style: const TextStyle(
                      color: Color(0xFF8E8D91),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                BookingRules.statusLabel(booking.status),
                style: const TextStyle(
                  color: Color(0xFF52525B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: const Color(0xFFFF5A00).withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1A1C1D),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: Color(0xFF8E8D91),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _dateAndTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF656466),
                      ),
                    ),
                  ),
                ],
              ),
              if (booking.location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xFF8E8D91),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF656466),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF4F3F4)),
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (galleryAvailable) ...[
                  TextButton.icon(
                    onPressed: () => context.push(
                      '/photographer_home/booking/${booking.id}/gallery',
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 15),
                    label: const Text(
                      'Mở gallery',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<String?> _askRejectReason(BuildContext context) async {
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
}

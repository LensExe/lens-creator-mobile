import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/surface_card.dart';
import '../../providers/data_providers.dart';
import '../../domain/models/models.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    final user = ref.watch(authUserProvider);

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        title: const Text(
          'Lịch đặt của tôi',
          style: TextStyle(color: AppColors.obsidian, fontSize: 16),
        ),
      ),
      body: bookings.isEmpty
          ? Center(
              child: const Text(
                'Chưa có lịch đặt nào',
                style: TextStyle(color: AppColors.steel),
              ).animate().fade(),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final isCustomer = user?.role == 'client';
                final otherName = isCustomer
                    ? b.photographerName
                    : b.clientName;

                return SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(b.status)
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(b.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(b.status),
                                  ),
                                ),
                              ),
                              Text(
                                '${b.price} đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chụp ${b.style} - $otherName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${b.date} • ${b.location}',
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    )
                    .animate()
                    .fade(delay: (index * 100).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.awaitingDeposit:
        return 'Chờ đặt cọc';
      case BookingStatus.pending:
        return 'Đang chờ';
      case BookingStatus.accepted:
      case BookingStatus.confirmed:
        return 'Đã chấp nhận';
      case BookingStatus.inProgress:
      case BookingStatus.held:
        return 'Đang chụp';
      case BookingStatus.shot:
        return 'Đã chụp';
      case BookingStatus.completed:
      case BookingStatus.released:
        return 'Hoàn thành';
      case BookingStatus.rejected:
        return 'Đã từ chối';
      case BookingStatus.expired:
        return 'Hết hạn';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.awaitingDeposit:
        return Colors.orange;
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.accepted:
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
      case BookingStatus.held:
        return Colors.purple;
      case BookingStatus.shot:
        return Colors.indigo;
      case BookingStatus.completed:
      case BookingStatus.released:
        return Colors.green;
      case BookingStatus.rejected:
      case BookingStatus.expired:
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}

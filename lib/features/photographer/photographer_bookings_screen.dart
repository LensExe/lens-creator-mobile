import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';

class PhotographerBookingsScreen extends StatelessWidget {
  const PhotographerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.mist,
        appBar: AppBar(
          backgroundColor: AppColors.snow,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Lịch đặt',
            style: TextStyle(
              color: AppColors.obsidian,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.obsidian,
            unselectedLabelColor: AppColors.steel,
            indicatorColor: AppColors.obsidian,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            dividerColor: AppColors.fog,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Held'),
              Tab(text: 'Released'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingList(status: 'pending'),
            _BookingList(status: 'confirmed'),
            _BookingList(status: 'held'),
            _BookingList(status: 'released'),
            _BookingList(status: 'canceled'),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final String status;

  const _BookingList({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusMap = {
      'pending': 'Chờ duyệt',
      'confirmed': 'Đã xác nhận',
      'held': 'Đang giữ chỗ',
      'released': 'Hoàn thành',
      'canceled': 'Đã huỷ',
    };

    // Generate dummy data based on status
    final bookings = List.generate(3, (index) {
      return {
        'id': 'BK-${status.toUpperCase()}-${1000 + index}',
        'client': 'Khách hàng $index',
        'date': '24/10/2026',
        'package': 'Gói Tiệc Cưới',
        'price': '3.500.000đ',
        'status': status,
        'statusLabel': statusMap[status]!,
      };
    });

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final b = bookings[index];
        return GestureDetector(
          onTap: () {
            context.push('/photographer_home/booking/${b['id']}');
          },
          child: SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b['id'] as String,
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildBadge(
                      b['status'] as String,
                      b['statusLabel'] as String,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  b['client'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.obsidian,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.steel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      b['date'] as String,
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: AppColors.steel,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      b['package'] as String,
                      style: const TextStyle(
                        color: AppColors.steel,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.fog),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(color: AppColors.steel),
                    ),
                    Text(
                      b['price'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.obsidian,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String s, String label) {
    if (s == 'pending') return LensBadge(text: label, type: BadgeType.ember);
    if (s == 'confirmed')
      return LensBadge(text: label, type: BadgeType.darkFilled);
    if (s == 'held')
      return LensBadge(
        text: label,
        type: BadgeType.darkOverlay,
      ); // Outline badge
    if (s == 'released')
      return LensBadge(text: label, type: BadgeType.darkFilled);
    return LensBadge(text: label, type: BadgeType.darkOverlay);
  }
}

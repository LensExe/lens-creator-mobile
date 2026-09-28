import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/surface_card.dart';
import 'package:lens_creator_mobile/core/widgets/lens_badge.dart';
import 'package:lens_creator_mobile/core/widgets/primary_button.dart';
import 'package:lens_creator_mobile/core/widgets/outlined_button.dart';

class BookingRequestDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingRequestDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    // Determine status from mock ID for demonstration
    String status = 'pending';
    if (bookingId.contains('CONFIRMED')) status = 'confirmed';
    if (bookingId.contains('HELD')) status = 'held';
    if (bookingId.contains('RELEASED')) status = 'released';
    if (bookingId.contains('CANCELED')) status = 'canceled';

    final booking = {
      'id': bookingId,
      'clientName': 'Trần Thị Thu Phương',
      'photographerName': 'Studio Ánh Sáng',
      'style': 'Chụp Tiệc Cưới',
      'date': '24-10-2026',
      'location': 'Nhà hàng White Palace, Phạm Văn Đồng, HCM',
      'price': 3500000,
      'status': status,
      'collaborators': <String>[],
    };

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.obsidian),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chi tiết yêu cầu',
          style: TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(booking),
            const SizedBox(height: 24),
            _buildPriceBreakdown(booking),
            const SizedBox(height: 24),
            _buildTimeline(booking),
            const SizedBox(height: 24),
            _buildActionCard(context, booking),
            if (status == 'held' || status == 'released') ...[
              const SizedBox(height: 24),
              _buildGalleryPanel(booking),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  BadgeType _getBadgeType(String status) {
    switch (status) {
      case 'pending':
        return BadgeType.ember;
      case 'confirmed':
        return BadgeType.blue;
      case 'held':
        return BadgeType.purple;
      case 'released':
        return BadgeType.green;
      case 'canceled':
        return BadgeType.red;
      default:
        return BadgeType.darkFilled;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đợi thanh toán';
      case 'held':
        return 'Đang thực hiện';
      case 'released':
        return 'Hoàn thành';
      case 'canceled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Widget _buildSummaryCard(Map<String, dynamic> booking) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã: ${booking['id']}',
                style: const TextStyle(
                  color: AppColors.steel,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              LensBadge(
                text: _getStatusLabel(booking['status'] as String),
                type: _getBadgeType(booking['status'] as String),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            booking['clientName'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.category, 'Gói: ${booking['style']}'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, 'Ngày chụp: ${booking['date']}'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Địa điểm: ${booking['location']}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.steel),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.obsidian, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(Map<String, dynamic> booking) {
    final price = booking['price'] as int;
    final commission = (price * 0.1).toInt(); // 10%
    final payout = price - commission;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pebble),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng giá', style: TextStyle(color: AppColors.steel)),
              Text(
                '${price.toString()}đ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.obsidian,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phí nền tảng (10%)',
                style: TextStyle(color: AppColors.steel),
              ),
              Text(
                '-${commission.toString()}đ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ember,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.mist),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bạn nhận được',
                style: TextStyle(
                  color: AppColors.obsidian,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${payout.toString()}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến trình',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.obsidian,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem('Khách hàng đặt lịch', true),
          _buildTimelineItem(
            'Thợ chụp xác nhận',
            booking['status'] != 'pending',
          ),
          _buildTimelineItem(
            'Khách hàng thanh toán',
            booking['status'] == 'held' || booking['status'] == 'released',
          ),
          _buildTimelineItem(
            'Giao ảnh & Hoàn thành',
            booking['status'] == 'released',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String text,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.ember : AppColors.pebble,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.ember : AppColors.pebble,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isCompleted ? AppColors.obsidian : AppColors.steel,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> booking) {
    final status = booking['status'] as String;

    Widget content;
    switch (status) {
      case 'pending':
        content = Column(
          children: [
            const Text(
              'Xác nhận hoặc từ chối yêu cầu này.',
              style: TextStyle(
                color: AppColors.obsidian,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedWhiteButton(text: 'Từ chối', onPressed: () {}),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(text: 'Xác nhận', onPressed: () {}),
                ),
              ],
            ),
          ],
        );
        break;
      case 'confirmed':
        content = Column(
          children: [
            const Row(
              children: [
                Icon(Icons.access_time_filled, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đang chờ khách thanh toán để giữ lịch.',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(text: 'Thêm thợ phụ / Ghép thợ', onPressed: () {}),
          ],
        );
        break;
      case 'held':
        content = Column(
          children: [
            const Row(
              children: [
                Icon(Icons.shield, color: Colors.purple, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tiền đang được sàn giữ. Bạn sẽ nhận tiền sau khi khách xác nhận đã nhận ảnh.',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedWhiteButton(text: 'Thêm thợ phụ', onPressed: () {}),
          ],
        );
        break;
      case 'released':
        content = const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Đã nhận tiền (đã trừ phí sàn). Giao dịch hoàn tất.',
                style: TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
        break;
      case 'canceled':
      default:
        content = const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Yêu cầu này đã bị hủy.',
                style: TextStyle(
                  color: AppColors.obsidian,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pebble),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildGalleryPanel(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final isReadonly = status == 'released';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ảnh giao khách',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.obsidian,
                ),
              ),
              if (!isReadonly)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.upload_file,
                    color: AppColors.ember,
                    size: 18,
                  ),
                  label: const Text(
                    'Tải ảnh',
                    style: TextStyle(
                      color: AppColors.ember,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.pebble,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/seed/booking${booking['id']}_$index/200',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

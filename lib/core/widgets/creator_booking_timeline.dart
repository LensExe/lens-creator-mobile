import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../theme/app_colors.dart';

class CreatorBookingTimeline extends StatelessWidget {
  const CreatorBookingTimeline({super.key, required this.status});

  final BookingStatus status;

  static const _steps = [
    (BookingStatus.awaitingDeposit, 'Đặt cọc'),
    (BookingStatus.pending, 'Xác nhận'),
    (BookingStatus.confirmed, 'Thanh toán'),
    (BookingStatus.held, 'Chụp & giao ảnh'),
    (BookingStatus.released, 'Hoàn thành'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == BookingStatus.cancelled) {
      return const Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.steel, size: 20),
          SizedBox(width: 10),
          Text(
            'Buổi chụp đã huỷ',
            style: TextStyle(color: AppColors.graphite, fontSize: 13),
          ),
        ],
      );
    }
    final current = _steps.indexWhere((step) => step.$1 == status);
    return Column(
      children: [
        for (var index = 0; index < _steps.length; index++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= current
                          ? index == current && status != BookingStatus.released
                                ? AppColors.ember
                                : AppColors.obsidian
                          : AppColors.mist,
                    ),
                    child: index <= current
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.snow,
                            size: 14,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: AppColors.steel,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  if (index < _steps.length - 1)
                    Container(
                      width: 1,
                      height: 25,
                      color: index < current
                          ? AppColors.obsidian
                          : AppColors.fog,
                    ),
                ],
              ),
              const SizedBox(width: 11),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _steps[index].$2,
                  style: TextStyle(
                    color: index > current ? AppColors.ash : AppColors.obsidian,
                    fontSize: 13,
                    fontWeight: index == current
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

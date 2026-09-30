import 'package:flutter/material.dart';

class CreatorDestination {
  const CreatorDestination(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}

const creatorMoreDestinations = [
  CreatorDestination(
    'Lịch làm việc',
    '/photographer_home/availability',
    Icons.calendar_month_outlined,
  ),
  CreatorDestination(
    'Hồ sơ năng lực',
    '/photographer_home/portfolio',
    Icons.photo_library_outlined,
  ),
  CreatorDestination(
    'Lưu trữ ảnh',
    '/photographer_home/storage',
    Icons.cloud_outlined,
  ),
  CreatorDestination(
    'Thành tựu',
    '/photographer_home/achievements',
    Icons.emoji_events_outlined,
  ),
  CreatorDestination(
    'Trợ lý AI',
    '/photographer_home/assistant',
    Icons.auto_awesome_outlined,
  ),
  CreatorDestination(
    'Ví của tôi',
    '/photographer_home/wallet',
    Icons.account_balance_wallet_outlined,
  ),
  CreatorDestination(
    'Cài đặt',
    '/photographer_home/settings',
    Icons.settings_outlined,
  ),
];

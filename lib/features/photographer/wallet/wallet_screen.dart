import 'package:flutter/material.dart';
import 'package:lens_creator_mobile/core/theme/app_colors.dart';
import 'package:lens_creator_mobile/core/widgets/outlined_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'widgets/transaction_item.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock transactions
    final transactions = [
      {
        'title': 'Nhận tiền - Minh & Lan',
        'date': 'Hôm nay, 14:30',
        'amount': '+ 3.500.000đ',
        'isIncome': true,
      },
      {
        'title': 'Rút tiền về VCB',
        'date': 'Hôm qua, 09:15',
        'amount': '- 5.000.000đ',
        'isIncome': false,
      },
      {
        'title': 'Nhận tiền - Ngoại cảnh',
        'date': '12/10/2026, 16:00',
        'amount': '+ 800.000đ',
        'isIncome': true,
      },
      {
        'title': 'Phí nền tảng T10',
        'date': '01/10/2026, 00:00',
        'amount': '- 100.000đ',
        'isIncome': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(
        backgroundColor: AppColors.mist,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ví của tôi',
          style: TextStyle(
            color: AppColors.obsidian,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBalanceCard(context)
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 32),
                  const Text(
                    'Lịch sử giao dịch',
                    style: TextStyle(
                      color: AppColors.obsidian,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ).animate().fade().slideY(begin: 0.1, delay: 100.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final t = transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                      TransactionItem(
                            title: t['title'] as String,
                            date: t['date'] as String,
                            amount: t['amount'] as String,
                            isIncome: t['isIncome'] as bool,
                          )
                          .animate()
                          .fade(duration: 400.ms, delay: ((index + 2) * 100).ms)
                          .slideY(begin: 0.1),
                );
              }, childCount: transactions.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.obsidian,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppColors.obsidian, Color(0xFF27272A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.obsidian.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng số dư',
            style: TextStyle(
              color: AppColors.ash,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '12.500.000đ',
            style: TextStyle(
              color: AppColors.snow,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 32),
          // We use OutlinedWhiteButton here because it has a white background
          // which creates high contrast on the dark balance card.
          OutlinedWhiteButton(text: 'Rút tiền về Ngân hàng', onPressed: () {}),
        ],
      ),
    );
  }
}

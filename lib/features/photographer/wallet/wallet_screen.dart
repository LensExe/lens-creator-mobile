import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/booking_rules.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart';
import 'wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  Future<void> _withdraw(
    BuildContext context,
    WidgetRef ref,
    int balance,
  ) async {
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rút tiền về ngân hàng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Số dư khả dụng: ${formatDong(balance)}'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Số tiền muốn rút',
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final share in [0.25, 0.5, 1.0])
                    ActionChip(
                      label: Text(
                        share == 1 ? 'Rút hết' : '${(share * 100).round()}%',
                      ),
                      onPressed: () => setDialogState(
                        () => controller.text =
                            '${((balance * share) / 1000).floor() * 1000}',
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed:
                  (int.tryParse(controller.text) ?? 0) <= 0 ||
                      (int.tryParse(controller.text) ?? 0) > balance
                  ? null
                  : () => Navigator.pop(context, int.parse(controller.text)),
              child: const Text('Xác nhận rút'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (amount == null || !context.mounted) return;
    ref.read(walletProvider.notifier).withdraw(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi yêu cầu rút ${formatDong(amount)}')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(walletProvider);
    final balance = entries.fold<int>(0, (sum, item) => sum + item.amount);
    final bookings = ref.watch(myBookingsProvider);
    final collaborations = ref.watch(myCollaborationsProvider);
    final userId = ref.watch(authUserProvider)?.id;
    final pending = [...bookings, ...collaborations]
        .where((b) => b.status == BookingStatus.held)
        .fold<int>(
          0,
          (sum, b) =>
              sum + (userId == null ? 0 : BookingRules.payoutFor(b, userId)),
        );
    final now = DateTime.now();
    final received = entries
        .where(
          (entry) =>
              entry.amount > 0 &&
              entry.date.year == now.year &&
              entry.date.month == now.month,
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
    final withdrawn = -entries
        .where((entry) => entry.amount < 0)
        .fold<int>(0, (sum, item) => sum + item.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Ví của tôi')),
      body: ListView(
        padding: AppTokens.pagePadding,
        children: [
          Card(
            color: AppColors.obsidian,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư khả dụng',
                    style: TextStyle(color: AppColors.ash),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatDong(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: balance <= 0
                        ? null
                        : () => _withdraw(context, ref, balance),
                    child: const Text('Rút tiền về ngân hàng'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Stat('Đang chờ giải ngân', formatDong(pending)),
          _Stat('Đã nhận tháng này', formatDong(received)),
          _Stat('Đã rút về ngân hàng', formatDong(withdrawn)),
          const SizedBox(height: 20),
          Text(
            'Lịch sử giao dịch',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có giao dịch'),
              ),
            ),
          for (final entry in entries)
            Card(
              child: ListTile(
                leading: Icon(
                  entry.amount >= 0 ? Icons.south_west : Icons.north_east,
                  color: entry.amount >= 0
                      ? AppColors.success
                      : AppColors.steel,
                ),
                title: Text(entry.note),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
                ),
                trailing: Text(
                  '${entry.amount > 0 ? '+' : ''}${formatDong(entry.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: entry.amount >= 0
                        ? AppColors.success
                        : AppColors.obsidian,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.steel, fontSize: 13),
      ),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import '../../../core/widgets/creator_list_row.dart';
import '../../../core/widgets/creator_section_header.dart';
import '../../../core/widgets/creator_summary_strip.dart';
import '../../../domain/booking_rules.dart';
import '../../../domain/models/models.dart';
import '../../../providers/data_providers.dart';
import '../bookings/widgets/studio_booking_card.dart';
import 'wallet_entry.dart';
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
    try {
      await ref.read(walletProvider.notifier).withdraw(amount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gửi yêu cầu rút ${formatDong(amount)}')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể rút tiền: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesState = ref.watch(walletProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Ví của tôi')),
      body: entriesState.when(
        loading: () =>
            const CreatorLoadingState(label: 'Đang tải lịch sử giao dịch…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải lịch sử giao dịch',
          description: 'Kiểm tra kết nối rồi thử tải lại.',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(walletProvider),
        ),
        data: (entries) => _walletContent(context, ref, entries),
      ),
    );
  }

  Widget _walletContent(
    BuildContext context,
    WidgetRef ref,
    List<WalletEntry> entries,
  ) {
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư khả dụng',
                    style: TextStyle(color: AppColors.pebble, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDong(balance),
                    style: const TextStyle(
                      color: AppColors.snow,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: balance <= 0
                        ? null
                        : () => _withdraw(context, ref, balance),
                    child: const Text('Rút tiền về ngân hàng'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CreatorSummaryStrip(
              items: [
                CreatorSummaryItem('Chờ giải ngân', formatDong(pending)),
                CreatorSummaryItem('Nhận tháng này', formatDong(received)),
                CreatorSummaryItem('Đã rút', formatDong(withdrawn)),
              ],
            ),
            const SizedBox(height: 28),
            const CreatorSectionHeader(title: 'Lịch sử giao dịch'),
            const SizedBox(height: 6),
            if (entries.isEmpty)
              const CreatorEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Chưa có giao dịch',
              )
            else
              for (final entry in entries) ...[
                CreatorListRow(
                  icon: entry.amount >= 0
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  title: entry.note,
                  subtitle: DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
                  trailing: Text(
                    '${entry.amount > 0 ? '+' : ''}${formatDong(entry.amount)}',
                    style: TextStyle(
                      color: entry.amount >= 0
                          ? AppColors.success
                          : AppColors.obsidian,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(),
              ],
          ],
        ),
      ),
    );
  }
}

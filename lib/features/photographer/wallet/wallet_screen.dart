import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import '../../../core/widgets/creator_list_row.dart';
import '../../../core/widgets/creator_section_header.dart';
import '../../../core/widgets/creator_summary_strip.dart';
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
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final bankCodeController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final request = await showDialog<WalletWithdrawalRequest>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Tạo yêu cầu rút tiền'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Số dư khả dụng từ Backend: ${formatDong(balance)}'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Số tiền (tối thiểu 10.000 ₫)',
                      ),
                      validator: (value) {
                        final amount = int.tryParse(value ?? '');
                        if (amount == null || amount < 10000) {
                          return 'Số tiền tối thiểu là 10.000 ₫';
                        }
                        if (amount > balance) return 'Vượt số dư khả dụng';
                        return null;
                      },
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final share in [0.25, 0.5, 1.0])
                          ActionChip(
                            label: Text(
                              share == 1
                                  ? 'Rút hết'
                                  : '${(share * 100).round()}%',
                            ),
                            onPressed: balance < 10000
                                ? null
                                : () => setDialogState(() {
                                    amountController.text =
                                        '${(balance * share).floor()}';
                                  }),
                          ),
                      ],
                    ),
                    TextFormField(
                      controller: reasonController,
                      maxLength: 1000,
                      decoration: const InputDecoration(labelText: 'Lý do rút'),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Nhập lý do rút tiền'
                          : null,
                    ),
                    TextFormField(
                      controller: bankCodeController,
                      maxLength: 32,
                      decoration: const InputDecoration(
                        labelText: 'Mã BIN hoặc mã ngân hàng',
                      ),
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Mã ngân hàng tối thiểu 2 ký tự'
                          : null,
                    ),
                    TextFormField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản',
                      ),
                      validator: (value) =>
                          (value ?? '').length < 4 || (value ?? '').length > 34
                          ? 'Số tài khoản phải có 4–34 chữ số'
                          : null,
                    ),
                    TextFormField(
                      controller: accountNameController,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tên chủ tài khoản',
                      ),
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Tên chủ tài khoản tối thiểu 2 ký tự'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  dialogContext,
                  WalletWithdrawalRequest(
                    amount: int.parse(amountController.text),
                    reason: reasonController.text.trim(),
                    bankCode: bankCodeController.text.trim(),
                    accountNumber: accountNumberController.text.trim(),
                    accountName: accountNameController.text.trim(),
                    idempotencyKey:
                        'lens-creator:withdraw:${DateTime.now().microsecondsSinceEpoch}',
                  ),
                );
              },
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
    reasonController.dispose();
    bankCodeController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    if (request == null || !context.mounted) return;
    try {
      await ref.read(walletProvider.notifier).withdraw(request);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Backend đã nhận yêu cầu rút và sẽ xử lý theo trạng thái của request.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gửi yêu cầu rút: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Ví của tôi')),
      body: walletState.when(
        loading: () =>
            const CreatorLoadingState(label: 'Đang tải ví và sổ cái…'),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải ví',
          description: '$error',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(walletProvider),
        ),
        data: (snapshot) => _walletContent(context, ref, snapshot),
      ),
    );
  }

  Widget _walletContent(
    BuildContext context,
    WidgetRef ref,
    WalletSnapshot snapshot,
  ) {
    final now = DateTime.now();
    final availableIncrease = snapshot.entries
        .where(
          (entry) =>
              entry.amount > 0 &&
              entry.date.year == now.year &&
              entry.date.month == now.month,
        )
        .fold<int>(0, (sum, entry) => sum + entry.amount);
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
                    formatDong(snapshot.balance),
                    style: const TextStyle(
                      color: AppColors.snow,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Đang giữ: ${formatDong(snapshot.frozenBalance)}',
                    style: const TextStyle(color: AppColors.pebble),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: snapshot.balance < 10000
                        ? null
                        : () => _withdraw(context, ref, snapshot.balance),
                    child: const Text('Tạo yêu cầu rút tiền'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CreatorSummaryStrip(
              items: [
                CreatorSummaryItem(
                  'Đang giữ',
                  formatDong(snapshot.frozenBalance),
                ),
                CreatorSummaryItem(
                  'Tăng khả dụng tháng này',
                  formatDong(availableIncrease),
                ),
                CreatorSummaryItem(
                  'Bản ghi sổ cái',
                  '${snapshot.entries.length}',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const CreatorSectionHeader(title: 'Sổ cái ví · VND'),
            const SizedBox(height: 6),
            if (snapshot.entries.isEmpty)
              const CreatorEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Chưa có biến động ví',
              )
            else
              for (final entry in snapshot.entries) ...[
                CreatorListRow(
                  icon: entry.amount + entry.frozenDelta >= 0
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  title: entry.note.isEmpty ? entry.entryType : entry.note,
                  subtitle:
                      '${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}${entry.entryType.isEmpty ? '' : ' · ${entry.entryType}'}',
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Khả dụng ${_signed(entry.amount)}'),
                      if (entry.frozenDelta != 0)
                        Text('Đang giữ ${_signed(entry.frozenDelta)}'),
                    ],
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

String _signed(int value) => '${value > 0 ? '+' : ''}${formatDong(value)}';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
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

    final request = await showModalBottomSheet<WalletWithdrawalRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E4E7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Yêu cầu rút tiền',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C1D),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Balance banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Khả dụng có thể rút',
                            style: TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            formatDong(balance),
                            style: const TextStyle(
                              color: Color(0xFF1A1C1D),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Số tiền rút (tối thiểu 10.000 ₫)',
                        suffixText: '₫',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                      ),
                      validator: (value) {
                        final amount = int.tryParse(value ?? '');
                        if (amount == null || amount < 10000) {
                          return 'Số tiền tối thiểu là 10.000 ₫';
                        }
                        if (amount > balance) return 'Vượt quá số dư khả dụng';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Quick percentage chips
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final share in [0.25, 0.5, 1.0])
                          ActionChip(
                            label: Text(
                              share == 1.0 ? 'Tất cả' : '${(share * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: const Color(0xFFF4F4F6),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onPressed: balance < 10000
                                ? null
                                : () => setModalState(() {
                                      amountController.text =
                                          '${(balance * share).floor()}';
                                    }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bank Info Fields
                    TextFormField(
                      controller: bankCodeController,
                      maxLength: 32,
                      decoration: InputDecoration(
                        labelText: 'Mã ngân hàng (ví dụ: VCB, MB, TCB)',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                      ),
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Mã ngân hàng tối thiểu 2 ký tự'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Số tài khoản thụ hưởng',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                      ),
                      validator: (value) =>
                          (value ?? '').length < 4 || (value ?? '').length > 34
                          ? 'Số tài khoản phải có 4–34 chữ số'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: accountNameController,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Tên chủ tài khoản (in hoa không dấu)',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                      ),
                      validator: (value) => (value ?? '').trim().length < 2
                          ? 'Tên chủ tài khoản tối thiểu 2 ký tự'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: reasonController,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText: 'Lý do rút tiền',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
                        ),
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Vui lòng nhập lý do rút tiền'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Submit CTA
                    FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(
                          sheetContext,
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
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ember,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Gửi yêu cầu rút tiền'),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            'Yêu cầu rút tiền đã gửi thành công và đang được xử lý.',
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
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF1A1C1D),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ví của tôi',
          style: TextStyle(
            color: Color(0xFF1A1C1D),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại ví',
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Color(0xFF71717A),
            ),
            onPressed: () => ref.invalidate(walletProvider),
          ),
        ],
      ),
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            // Premium Fintech Card
            _buildFintechCard(context, ref, snapshot),
            const SizedBox(height: 18),

            // Summary Metrics Card (3 balanced columns)
            _buildMetricsStrip(snapshot, availableIncrease),
            const SizedBox(height: 26),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử giao dịch',
                  style: TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${snapshot.entries.length} giao dịch',
                    style: const TextStyle(
                      color: Color(0xFF52525B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Transaction Ledger Card
            if (snapshot.entries.isEmpty)
              const CreatorEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Chưa có biến động ví',
                description: 'Các khoản thanh toán và giải ngân Escrow sẽ hiển thị tại đây.',
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8ED)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      for (var i = 0; i < snapshot.entries.length; i++) ...[
                        _buildTransactionRow(snapshot.entries[i]),
                        if (i < snapshot.entries.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 64,
                            endIndent: 16,
                            color: Color(0xFFF4F4F6),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechCard(
    BuildContext context,
    WidgetRef ref,
    WalletSnapshot snapshot,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF141518), Color(0xFF22252A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x22FFFFFF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 13,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'TÀI KHOẢN VÍ LENS',
                      style: TextStyle(
                        color: Color(0xFFD4D4D8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.contactless_rounded,
                color: Color(0x4DFFFFFF),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Available Balance
          const Text(
            'Số dư khả dụng',
            style: TextStyle(
              color: Color(0xFFA1A1AA),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDong(snapshot.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 20),

          // Bottom Controls: Frozen balance & Withdraw CTA
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF5A00),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33FF5A00)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_clock_outlined,
                        size: 14,
                        color: Color(0xFFFF7A33),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Đang giữ: ${formatDong(snapshot.frozenBalance)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFB899),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: snapshot.balance < 10000
                    ? null
                    : () => _withdraw(context, ref, snapshot.balance),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ember,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                label: const Text(
                  'Rút tiền',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsStrip(WalletSnapshot snapshot, int availableIncrease) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              label: 'Đang giữ Escrow',
              value: formatDong(snapshot.frozenBalance),
              valueColor: const Color(0xFFD97706),
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
          Expanded(
            child: _buildMetricItem(
              label: 'Tăng trong tháng',
              value: formatDong(availableIncrease),
              valueColor: const Color(0xFF10B981),
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
          Expanded(
            child: _buildMetricItem(
              label: 'Tổng giao dịch',
              value: '${snapshot.entries.length}',
              valueColor: const Color(0xFF1A1C1D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF71717A),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(WalletEntry entry) {
    final meta = _resolveEntryMeta(entry);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: meta.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, size: 20, color: meta.iconColor),
          ),
          const SizedBox(width: 12),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1A1C1D),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('dd/MM/yyyy · HH:mm').format(entry.date)} · ${meta.typeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount values
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (entry.amount != 0)
                Text(
                  '${entry.amount > 0 ? '+' : ''}${formatDong(entry.amount)}',
                  style: TextStyle(
                    color: entry.amount > 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (entry.frozenDelta != 0) ...[
                if (entry.amount != 0) const SizedBox(height: 2),
                Text(
                  '${entry.frozenDelta > 0 ? '+' : ''}${formatDong(entry.frozenDelta)} (Escrow)',
                  style: TextStyle(
                    color: entry.frozenDelta > 0
                        ? const Color(0xFFD97706)
                        : const Color(0xFF71717A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (entry.amount == 0 && entry.frozenDelta == 0)
                const Text(
                  '0 ₫',
                  style: TextStyle(
                    color: Color(0xFF71717A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _EntryMeta _resolveEntryMeta(WalletEntry entry) {
    final type = entry.entryType.toLowerCase();
    final note = entry.note.trim();

    // Friendly Vietnamese title
    String title = note;
    if (title.isEmpty) {
      title = _formatEntryTypeLabel(type);
    } else {
      // Localize common English backend notes
      if (title == 'Booking funds held until booking completion') {
        title = 'Tạm giữ tiền cọc qua bảo vệ Escrow';
      } else if (title.contains('Escrow demo được giải ngân sau khi hoàn thành.')) {
        title = 'Giải ngân Escrow hoàn tất buổi chụp';
      } else if (title.contains('Tiền booking demo được ghi nhận vào escrow.')) {
        title = 'Ghi nhận cọc booking vào Escrow';
      }
    }

    final typeLabel = _formatEntryTypeLabel(type);

    if (entry.amount > 0) {
      return _EntryMeta(
        title: title,
        typeLabel: typeLabel,
        icon: Icons.south_west_rounded,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
      );
    }

    if (entry.amount < 0) {
      return _EntryMeta(
        title: title,
        typeLabel: typeLabel,
        icon: Icons.north_east_rounded,
        iconColor: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      );
    }

    if (entry.frozenDelta > 0) {
      return _EntryMeta(
        title: title,
        typeLabel: typeLabel,
        icon: Icons.lock_clock_rounded,
        iconColor: const Color(0xFFFF8A00),
        bgColor: const Color(0xFFFFF6ED),
      );
    }

    return _EntryMeta(
      title: title,
      typeLabel: typeLabel,
      icon: Icons.swap_horiz_rounded,
      iconColor: const Color(0xFF3B82F6),
      bgColor: const Color(0xFFEFF6FF),
    );
  }

  String _formatEntryTypeLabel(String type) {
    switch (type) {
      case 'booking_escrow_hold':
        return 'Tạm giữ Escrow';
      case 'booking_escrow_release':
        return 'Giải ngân Escrow';
      case 'withdrawal_request':
        return 'Yêu cầu rút';
      case 'withdrawal_completed':
        return 'Rút tiền';
      case 'withdrawal_failed':
        return 'Rút tiền lỗi';
      case 'deposit_hold':
        return 'Giữ cọc';
      default:
        return type.isEmpty ? 'Giao dịch' : type;
    }
  }
}

class _EntryMeta {
  const _EntryMeta({
    required this.title,
    required this.typeLabel,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String title;
  final String typeLabel;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}

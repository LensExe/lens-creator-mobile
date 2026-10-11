import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/creator_empty_state.dart';
import '../../../core/widgets/creator_loading_state.dart';
import 'subscription_repository.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionWorkspaceProvider);
    return Scaffold(
      backgroundColor: AppColors.mist,
      appBar: AppBar(title: const Text('Dung lượng & gói đăng ký')),
      body: state.when(
        loading: () => const CreatorLoadingState(
          label: 'Đang tải gói, quyền lợi và dung lượng từ Backend…',
        ),
        error: (error, _) => CreatorEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không thể tải subscription',
          description: '$error',
          actionLabel: 'Thử lại',
          onAction: () => ref.invalidate(subscriptionWorkspaceProvider),
        ),
        data: (workspace) => _content(context, ref, workspace),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    SubscriptionWorkspace workspace,
  ) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppTokens.contentMaxWidth),
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(subscriptionWorkspaceProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
          children: [
            _CurrentSubscriptionCard(
              current: workspace.current,
              features: workspace.features,
              onCancel:
                  workspace.current == null ||
                      workspace.current!.status != 'active' ||
                      workspace.current!.cancelAtPeriodEnd
                  ? null
                  : () => _cancel(context, ref, workspace.current!),
            ),
            const SizedBox(height: 14),
            _UsageCard(usage: workspace.usage),
            const SizedBox(height: 22),
            const _SectionTitle('Các gói Backend đang cung cấp'),
            const SizedBox(height: 8),
            if (workspace.plans.isEmpty)
              const CreatorEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Backend chưa có gói đang hoạt động',
              )
            else
              for (final plan in workspace.plans) ...[
                _PlanCard(
                  plan: plan,
                  current: workspace.current,
                  busy:
                      workspace.current?.status == 'active' ||
                      workspace.current?.status == 'pending',
                  onSubscribe: () => _subscribe(context, ref, plan),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            const _SectionTitle('Lịch sử subscription'),
            const SizedBox(height: 8),
            if (workspace.history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Backend chưa trả về sự kiện lịch sử.'),
                ),
              )
            else
              for (final event in workspace.history)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(_eventLabel(event.eventType)),
                    subtitle: Text(
                      [
                        if (event.createdAt != null)
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(event.createdAt!.toLocal()),
                        if (event.fromStatus != null || event.toStatus != null)
                          '${event.fromStatus ?? '—'} → ${event.toStatus ?? '—'}',
                        if (event.note.isNotEmpty) event.note,
                      ].join(' · '),
                    ),
                  ),
                ),
          ],
        ),
      ),
    ),
  );

  Future<void> _subscribe(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Đăng ký ${plan.name}?'),
        content: Text(
          'Backend sẽ khởi tạo subscription và bản ghi thanh toán ${_money(plan.price)} cho chu kỳ ${plan.billingCycleDays} ngày. Quyền lợi chỉ có hiệu lực khi Backend xác nhận trạng thái active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final result = await ref
          .read(apiSubscriptionRepositoryProvider)
          .create(plan.id);
      ref.invalidate(subscriptionWorkspaceProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.status == 'active'
                ? 'Backend xác nhận subscription active.'
                : result.checkoutUrl == null
                ? 'Backend tạo subscription ở trạng thái ${result.status}; chưa trả checkout URL hoặc QR nên chưa xác nhận thanh toán.'
                : 'Backend tạo checkout. Hoàn tất thanh toán tại liên kết đã trả về.',
          ),
        ),
      );
      if (result.checkoutUrl != null && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Checkout từ Backend'),
            content: SelectableText(result.checkoutUrl!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể khởi tạo subscription: $error')),
        );
      }
    }
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    CurrentSubscription current,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Huỷ gia hạn subscription?'),
        content: const Text(
          'Backend sẽ ngừng gia hạn sau kỳ đã thanh toán. Quyền lợi hiện tại còn đến ngày kết thúc của kỳ này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Giữ gói'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Huỷ gia hạn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(apiSubscriptionRepositoryProvider).cancel(current.id);
      ref.invalidate(subscriptionWorkspaceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend đã xác nhận yêu cầu huỷ gia hạn.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể huỷ gia hạn: $error')),
        );
      }
    }
  }
}

class _CurrentSubscriptionCard extends StatelessWidget {
  const _CurrentSubscriptionCard({
    required this.current,
    required this.features,
    required this.onCancel,
  });

  final CurrentSubscription? current;
  final List<SubscriptionFeature> features;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Subscription hiện tại'),
          const SizedBox(height: 8),
          if (current == null)
            const Text('Backend chưa có subscription hiện tại cho tài khoản.')
          else ...[
            Text(
              current!.planName.isEmpty
                  ? 'Gói ${current!.planId}'
                  : current!.planName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Trạng thái: ${_statusLabel(current!.status)}'),
            Text('Giá đã ghi nhận: ${_money(current!.price)}'),
            if (current!.startAt != null)
              Text(
                'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(current!.startAt!.toLocal())}',
              ),
            if (current!.endAt != null)
              Text(
                'Kết thúc: ${DateFormat('dd/MM/yyyy').format(current!.endAt!.toLocal())}',
              ),
            if (current!.cancelAtPeriodEnd)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Đã yêu cầu dừng gia hạn; quyền lợi còn đến cuối kỳ.',
                ),
              ),
            if (onCancel != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: onCancel,
                child: const Text('Huỷ gia hạn'),
              ),
            ],
          ],
          if (features.isNotEmpty) ...[
            const Divider(height: 24),
            const Text('Entitlement do Backend trả về'),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  feature.value.isEmpty
                      ? feature.label
                      : '${feature.label}: ${feature.value}',
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.usage});
  final SubscriptionUsage usage;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Dung lượng và quota thực tế'),
          const SizedBox(height: 10),
          Text('Dung lượng tệp: ${_bytes(usage.storageBytes)}'),
          Text('Upload đang giữ chỗ: ${_bytes(usage.reservedStorageBytes)}'),
          Text(
            usage.storageLimitBytes == null
                ? 'Hạn mức dung lượng: Backend không trả giới hạn hiện tại'
                : 'Hạn mức: ${_bytes(usage.storageLimitBytes!)} · còn ${_bytes(usage.storageRemainingBytes ?? 0)}',
          ),
          if (usage.storageOverLimit)
            const Text('Dung lượng đang vượt hạn mức Backend.'),
          const Divider(height: 24),
          Text('Portfolio: ${usage.portfolioCount}'),
          Text(
            usage.portfolioLimit == null
                ? 'Backend không trả giới hạn số portfolio hiện tại'
                : 'Giới hạn: ${usage.portfolioLimit} · còn ${usage.portfolioRemainingCount ?? 0}',
          ),
          if (usage.portfolioOverLimit)
            const Text('Số portfolio đang vượt quota Backend.'),
        ],
      ),
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.current,
    required this.busy,
    required this.onSubscribe,
  });

  final SubscriptionPlan plan;
  final CurrentSubscription? current;
  final bool busy;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isCurrent = current?.planId == plan.id;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(_money(plan.price)),
              ],
            ),
            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(plan.description),
            ],
            const SizedBox(height: 6),
            Text('Chu kỳ: ${plan.billingCycleDays} ngày · mã ${plan.code}'),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  feature.value.isEmpty
                      ? feature.label
                      : '${feature.label}: ${feature.value}',
                ),
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: busy || isCurrent ? null : onSubscribe,
                child: Text(
                  isCurrent
                      ? 'Subscription hiện tại'
                      : busy
                      ? 'Có subscription đang xử lý'
                      : 'Đăng ký gói',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.value);
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

String _statusLabel(String status) => switch (status) {
  'pending' => 'Chờ thanh toán',
  'active' => 'Đang hoạt động',
  'expired' => 'Hết hạn',
  'cancelled' => 'Đã huỷ',
  _ => status.isEmpty ? 'Chưa rõ' : status,
};

String _eventLabel(String event) => switch (event) {
  'created' => 'Đã tạo subscription',
  'renewal_cancelled' => 'Đã huỷ gia hạn',
  'payment_activated' => 'Thanh toán được kích hoạt',
  'payment_timeout' => 'Thanh toán hết hạn',
  'payment_late_review' => 'Thanh toán chờ đối soát',
  'payment_reconciled' => 'Thanh toán đã đối soát',
  'payment_refunded' => 'Thanh toán được hoàn',
  'expired' => 'Subscription hết hạn',
  'imported' => 'Subscription được import',
  _ => event,
};

String _money(int value) => NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
).format(value);

String _bytes(int value) {
  if (value < 1024) return '$value B';
  if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
  if (value < 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

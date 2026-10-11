import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../providers/data_providers.dart';

class SubscriptionFeature {
  const SubscriptionFeature({required this.label, required this.value});
  final String label;
  final String value;
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycleDays,
    required this.features,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int price;
  final int billingCycleDays;
  final List<SubscriptionFeature> features;
}

class CurrentSubscription {
  const CurrentSubscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    required this.price,
    required this.startAt,
    required this.endAt,
    required this.autoRenew,
    required this.cancelAtPeriodEnd,
  });

  final String id;
  final String planId;
  final String planName;
  final String status;
  final int price;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool autoRenew;
  final bool cancelAtPeriodEnd;
}

class SubscriptionUsage {
  const SubscriptionUsage({
    required this.storageBytes,
    required this.reservedStorageBytes,
    required this.storageLimitBytes,
    required this.storageRemainingBytes,
    required this.storageOverLimit,
    required this.portfolioCount,
    required this.portfolioLimit,
    required this.portfolioRemainingCount,
    required this.portfolioOverLimit,
  });

  final int storageBytes;
  final int reservedStorageBytes;
  final int? storageLimitBytes;
  final int? storageRemainingBytes;
  final bool storageOverLimit;
  final int portfolioCount;
  final int? portfolioLimit;
  final int? portfolioRemainingCount;
  final bool portfolioOverLimit;
}

class SubscriptionHistoryEvent {
  const SubscriptionHistoryEvent({
    required this.id,
    required this.eventType,
    required this.fromStatus,
    required this.toStatus,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String eventType;
  final String? fromStatus;
  final String? toStatus;
  final DateTime? createdAt;
  final String note;
}

class SubscriptionWorkspace {
  const SubscriptionWorkspace({
    required this.plans,
    required this.current,
    required this.features,
    required this.usage,
    required this.history,
  });

  final List<SubscriptionPlan> plans;
  final CurrentSubscription? current;
  final List<SubscriptionFeature> features;
  final SubscriptionUsage usage;
  final List<SubscriptionHistoryEvent> history;
}

class SubscriptionCheckoutResult {
  const SubscriptionCheckoutResult({
    required this.status,
    required this.paymentId,
    required this.paymentStatus,
    required this.checkoutUrl,
  });

  final String status;
  final String? paymentId;
  final String? paymentStatus;
  final String? checkoutUrl;
}

class ApiSubscriptionRepository {
  const ApiSubscriptionRepository(this._dio);
  final Dio _dio;

  Future<SubscriptionWorkspace> load() async {
    try {
      final responses = await Future.wait([
        _dio.get<dynamic>('subscriptions/plans'),
        _dio.get<dynamic>('subscriptions/me'),
        _dio.get<dynamic>('subscriptions/me/usage'),
        _dio.get<dynamic>('subscriptions/me/history'),
      ]);
      final planBody = _asMap(_unwrap(responses[0].data));
      final meBody = _asMap(_unwrap(responses[1].data));
      final usageBody = _asMap(_unwrap(responses[2].data));
      final historyBody = _asMap(_unwrap(responses[3].data));
      final currentRaw = meBody['subscription'];
      final usageSubscription = usageBody['subscription'];
      final rawCurrent = currentRaw is Map
          ? _asMap(currentRaw)
          : usageSubscription is Map
          ? _asMap(usageSubscription)
          : null;
      final rawPlans = planBody['items'];
      final rawHistory = historyBody['items'];
      return SubscriptionWorkspace(
        plans: rawPlans is List
            ? rawPlans.map((item) => _plan(_asMap(item))).toList()
            : const [],
        current: rawCurrent == null ? null : _current(rawCurrent),
        features: _features(meBody['features'] ?? usageBody['features']),
        usage: _usage(usageBody),
        history: rawHistory is List
            ? rawHistory.map((item) => _history(_asMap(item))).toList()
            : const [],
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<SubscriptionCheckoutResult> create(String planId) async {
    final key =
        'lens-creator-sub:$planId:${DateTime.now().toUtc().microsecondsSinceEpoch}';
    try {
      final response = await _dio.post<dynamic>(
        'subscriptions',
        data: {'photographer_plan_id': planId, 'idempotency_key': key},
      );
      final body = _asMap(_unwrap(response.data));
      final subscription = _asMap(body['subscription']);
      final paymentValue = body['payment'];
      final payment = paymentValue is Map ? _asMap(paymentValue) : const {};
      return SubscriptionCheckoutResult(
        status: subscription['status']?.toString() ?? 'unknown',
        paymentId: payment['id']?.toString(),
        paymentStatus: payment['status']?.toString(),
        checkoutUrl: payment['checkout_url']?.toString(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> cancel(String subscriptionId) async {
    try {
      await _dio.post<dynamic>('subscriptions/$subscriptionId/cancel');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  SubscriptionPlan _plan(Map<String, dynamic> json) => SubscriptionPlan(
    id: _string(json['id']),
    code: _string(json['code']),
    name: _string(json['name']),
    description: _string(json['description']),
    price: _int(json['price']),
    billingCycleDays: _int(json['billing_cycle']),
    features: _features(json['features']),
  );

  CurrentSubscription _current(Map<String, dynamic> json) {
    final snapshot = json['plan_snapshot'] is Map
        ? _asMap(json['plan_snapshot'])
        : const <String, dynamic>{};
    return CurrentSubscription(
      id: _string(json['id']),
      planId: _string(json['plan_id'] ?? snapshot['id']),
      planName: _string(snapshot['name'] ?? json['name']),
      status: _string(json['status']),
      price: _int(json['price'] ?? snapshot['price']),
      startAt: DateTime.tryParse(_string(json['start_at'])),
      endAt: DateTime.tryParse(_string(json['end_at'])),
      autoRenew: json['auto_renew'] == true,
      cancelAtPeriodEnd: json['cancel_at_period_end'] == true,
    );
  }

  SubscriptionUsage _usage(Map<String, dynamic> json) => SubscriptionUsage(
    storageBytes: _int(json['storage_bytes']),
    reservedStorageBytes: _int(json['reserved_storage_bytes']),
    storageLimitBytes: _nullableInt(json['storage_limit_bytes']),
    storageRemainingBytes: _nullableInt(json['storage_remaining_bytes']),
    storageOverLimit: json['storage_over_limit'] == true,
    portfolioCount: _int(json['portfolio_count']),
    portfolioLimit: _nullableInt(json['portfolio_limit']),
    portfolioRemainingCount: _nullableInt(json['portfolio_remaining_count']),
    portfolioOverLimit: json['portfolio_over_limit'] == true,
  );

  SubscriptionHistoryEvent _history(Map<String, dynamic> json) =>
      SubscriptionHistoryEvent(
        id: _string(json['id']),
        eventType: _string(json['event_type']),
        fromStatus: json['from_status']?.toString(),
        toStatus: json['to_status']?.toString(),
        createdAt: DateTime.tryParse(_string(json['created_at'])),
        note: _string(json['note']),
      );
}

final apiSubscriptionRepositoryProvider = Provider<ApiSubscriptionRepository>(
  (ref) => ApiSubscriptionRepository(ref.watch(dioProvider)),
);

final subscriptionWorkspaceProvider = FutureProvider<SubscriptionWorkspace>((
  ref,
) {
  final user = ref.watch(authUserProvider);
  if (user == null || user.role != 'photographer') {
    throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia');
  }
  return ref.read(apiSubscriptionRepositoryProvider).load();
});

List<SubscriptionFeature> _features(Object? value) {
  if (value is! List) return const [];
  return [
    for (final raw in value)
      if (raw is String && raw.trim().isNotEmpty)
        SubscriptionFeature(label: raw, value: '')
      else if (raw is Map)
        SubscriptionFeature(
          label: _string(raw['name'] ?? raw['code']),
          value: _featureValue(raw),
        ),
  ];
}

String _featureValue(Map<dynamic, dynamic> json) {
  final value = _string(json['value']);
  final unit = _string(json['unit']);
  if (value.isEmpty) return '';
  return unit.isEmpty ? value : '$value $unit';
}

Object? _unwrap(Object? value) {
  var result = value;
  while (result is Map && result.containsKey('data')) {
    result = result['data'];
  }
  return result;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  throw const ApiException('Backend trả về subscription không hợp lệ.');
}

String _string(Object? value) => value?.toString().trim() ?? '';

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(_string(value)) ?? 0;
}

int? _nullableInt(Object? value) => value == null ? null : _int(value);

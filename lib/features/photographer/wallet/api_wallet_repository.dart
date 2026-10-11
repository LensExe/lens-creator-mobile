import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import 'wallet_entry.dart';

class ApiWalletRepository {
  const ApiWalletRepository(this._dio);
  final Dio _dio;

  Future<WalletSnapshot> getSnapshot() async {
    try {
      final walletResponse = await _dio.get<dynamic>('wallet');
      final wallet = _asMap(_unwrap(walletResponse.data));
      const pageSize = 100;
      var offset = 0;
      var total = 0;
      final entries = <WalletEntry>[];
      do {
        final response = await _dio.get<dynamic>(
          'wallet/ledger',
          queryParameters: {'limit': pageSize, 'offset': offset},
        );
        final page = _asMap(_unwrap(response.data));
        final items = page['items'];
        if (items is! List) {
          throw const ApiException('Sổ cái ví từ Backend không hợp lệ.');
        }
        entries.addAll(items.map((item) => _entry(_asMap(item))));
        total = _integer(page['total'], fallback: offset + items.length);
        offset += items.length;
        if (items.isEmpty) break;
      } while (offset < total);
      return WalletSnapshot(
        balance: _integer(wallet['balance']),
        frozenBalance: _integer(wallet['frozen_balance']),
        entries: entries,
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> requestWithdrawal(WalletWithdrawalRequest request) async {
    if (request.amount < 10000) {
      throw const ApiException('Rút tối thiểu 10.000 ₫.');
    }
    try {
      await _dio.post<dynamic>(
        'wallet/withdrawals',
        data: {
          'amount': request.amount,
          'reason': request.reason.trim(),
          'payout_destination': {
            'bank_code': request.bankCode.trim(),
            'account_number': request.accountNumber.trim(),
            'account_name': request.accountName.trim(),
          },
          'idempotency_key': request.idempotencyKey,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  WalletEntry _entry(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse('${json['created_at']}');
    if (createdAt == null) {
      throw const ApiException(
        'Backend trả về thời điểm giao dịch không hợp lệ.',
      );
    }
    return WalletEntry(
      amount: _integer(json['available_delta']),
      frozenDelta: _integer(json['frozen_delta']),
      entryType: json['entry_type']?.toString() ?? '',
      note: json['description']?.toString() ?? '',
      date: createdAt,
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry('$key', value));
  throw const ApiException('Backend trả về dữ liệu ví không hợp lệ.');
}

Object? _unwrap(Object? value) {
  var result = value;
  while (result is Map && result.containsKey('data')) {
    result = result['data'];
  }
  return result;
}

int _integer(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

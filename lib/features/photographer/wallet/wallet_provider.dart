import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../providers/data_providers.dart';
import 'api_wallet_repository.dart';
import 'wallet_entry.dart';

final apiWalletRepositoryProvider = Provider<ApiWalletRepository>(
  (ref) => ApiWalletRepository(ref.watch(dioProvider)),
);

class WalletNotifier extends AsyncNotifier<WalletSnapshot> {
  bool _withdrawing = false;

  @override
  Future<WalletSnapshot> build() async {
    final user = ref.watch(authUserProvider);
    if (user == null || user.role != 'photographer') {
      throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia.');
    }
    return ref.read(apiWalletRepositoryProvider).getSnapshot();
  }

  Future<void> withdraw(WalletWithdrawalRequest request) async {
    if (_withdrawing) throw StateError('Yêu cầu rút tiền đang được gửi.');
    final user = ref.read(authUserProvider);
    final previous = state.value;
    if (user == null || user.role != 'photographer') {
      throw StateError(
        'Chỉ tài khoản nhiếp ảnh gia đã đăng nhập mới được rút tiền.',
      );
    }
    _withdrawing = true;
    state = const AsyncLoading();
    try {
      await ref.read(apiWalletRepositoryProvider).requestWithdrawal(request);
      state = AsyncData(
        await ref.read(apiWalletRepositoryProvider).getSnapshot(),
      );
    } catch (error, stackTrace) {
      if (previous != null) state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      _withdrawing = false;
    }
  }
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletSnapshot>(
  WalletNotifier.new,
);

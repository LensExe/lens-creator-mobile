import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/data_providers.dart';
import 'mock_wallet_repository.dart';
import 'wallet_entry.dart';
import 'wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => MockWalletRepository(),
);

class WalletNotifier extends AsyncNotifier<List<WalletEntry>> {
  @override
  Future<List<WalletEntry>> build() async {
    final user = ref.watch(authUserProvider);
    if (user == null || user.role != 'photographer') return [];
    return ref.read(walletRepositoryProvider).getTransactions(user.id);
  }

  Future<void> withdraw(int amount) async {
    final user = ref.read(authUserProvider);
    final previous = state.value ?? const <WalletEntry>[];
    if (user == null || user.role != 'photographer') {
      throw StateError('Chỉ nhiếp ảnh gia mới có thể rút tiền');
    }
    state = const AsyncLoading();
    try {
      final updated = await ref
          .read(walletRepositoryProvider)
          .requestWithdraw(user.id, amount);
      state = AsyncData(updated);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final walletProvider = AsyncNotifierProvider<WalletNotifier, List<WalletEntry>>(
  WalletNotifier.new,
);

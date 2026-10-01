import 'wallet_entry.dart';

abstract interface class WalletRepository {
  Future<List<WalletEntry>> getTransactions(String userId);

  Future<List<WalletEntry>> requestWithdraw(String userId, int amount);
}

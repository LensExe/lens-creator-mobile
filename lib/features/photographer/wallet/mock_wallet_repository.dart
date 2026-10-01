import 'wallet_entry.dart';
import 'wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  static const _delay = Duration(milliseconds: 350);
  static final Map<String, List<WalletEntry>> _ledgers = {};

  List<WalletEntry> _seed(String userId) {
    final now = DateTime.now();
    if (userId != 'me') return [];
    return [
      WalletEntry(
        amount: 405000,
        note: 'Giải ngân buổi chụp Chân dung',
        date: now.subtract(const Duration(days: 9)),
      ),
      WalletEntry(
        amount: -500000,
        note: 'Rút tiền về ngân hàng',
        date: now.subtract(const Duration(days: 20)),
      ),
      WalletEntry(
        amount: 495000,
        note: 'Giải ngân buổi chụp Gia đình',
        date: now.subtract(const Duration(days: 30)),
      ),
    ];
  }

  @override
  Future<List<WalletEntry>> getTransactions(String userId) async {
    await Future.delayed(_delay);
    final ledger = _ledgers.putIfAbsent(userId, () => _seed(userId));
    return List.unmodifiable(ledger);
  }

  @override
  Future<List<WalletEntry>> requestWithdraw(String userId, int amount) async {
    await Future.delayed(_delay);
    final ledger = _ledgers.putIfAbsent(userId, () => _seed(userId));
    final balance = ledger.fold<int>(0, (sum, entry) => sum + entry.amount);
    if (amount <= 0 || amount > balance) {
      throw StateError('Số tiền rút vượt số dư');
    }
    final updated = [
      WalletEntry(
        amount: -amount,
        note: 'Rút tiền về ngân hàng',
        date: DateTime.now(),
      ),
      ...ledger,
    ];
    _ledgers[userId] = updated;
    return List.unmodifiable(updated);
  }
}

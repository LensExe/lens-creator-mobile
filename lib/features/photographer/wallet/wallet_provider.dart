import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';

class WalletEntry {
  const WalletEntry({
    required this.amount,
    required this.note,
    required this.date,
  });
  final int amount;
  final String note;
  final DateTime date;
}

class WalletNotifier extends Notifier<List<WalletEntry>> {
  @override
  List<WalletEntry> build() {
    if (ref.watch(authUserProvider)?.id != 'me') return [];
    final now = DateTime.now();
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

  int get balance => state.fold(0, (sum, entry) => sum + entry.amount);

  void withdraw(int amount) {
    if (amount <= 0 || amount > balance) {
      throw StateError('Số tiền rút vượt số dư');
    }
    state = [
      WalletEntry(
        amount: -amount,
        note: 'Rút tiền về ngân hàng',
        date: DateTime.now(),
      ),
      ...state,
    ];
  }
}

final walletProvider = NotifierProvider<WalletNotifier, List<WalletEntry>>(
  WalletNotifier.new,
);

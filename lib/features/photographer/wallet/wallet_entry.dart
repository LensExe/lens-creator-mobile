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

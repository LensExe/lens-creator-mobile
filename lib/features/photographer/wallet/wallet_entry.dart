class WalletEntry {
  const WalletEntry({
    required this.amount,
    required this.note,
    required this.date,
    this.frozenDelta = 0,
    this.entryType = '',
  });

  /// Backend available-balance delta in VND.
  final int amount;
  final int frozenDelta;
  final String entryType;
  final String note;
  final DateTime date;
}

class WalletSnapshot {
  const WalletSnapshot({
    required this.balance,
    required this.frozenBalance,
    required this.entries,
  });

  final int balance;
  final int frozenBalance;
  final List<WalletEntry> entries;
}

class WalletWithdrawalRequest {
  const WalletWithdrawalRequest({
    required this.amount,
    required this.reason,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.idempotencyKey,
  });

  final int amount;
  final String reason;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String idempotencyKey;
}

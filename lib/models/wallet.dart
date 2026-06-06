class Wallet {
  final String? id;
  final String uuid;
  final String currency;
  final double balance;
  final double ledgerBalance;
  final String? accountNumber;
  final String? bankName;
  final String? bankCode;

  Wallet({
    this.id,
    required this.uuid,
    required this.currency,
    required this.balance,
    this.ledgerBalance = 0,
    this.accountNumber,
    this.bankName,
    this.bankCode,
  });

  String get currencySymbol {
    switch (currency) {
      case 'NGN': return '\u20A6';
      case 'USD': return '\$';
      case 'GBP': return '\u00A3';
      case 'CAD': return 'C\$';
      default: return '\$';
    }
  }

  String get formattedBalance {
    final formatter = _formatNumber(balance);
    return '$currencySymbol$formatter';
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString(),
      uuid: json['uuid']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      balance: (json['balance'] ?? 0).toDouble(),
      ledgerBalance: (json['ledger_balance'] ?? json['available_balance'] ?? 0).toDouble(),
      accountNumber: json['account_number']?.toString(),
      bankName: json['bank_name']?.toString() ?? json['account_name']?.toString(),
      bankCode: json['bank_code']?.toString(),
    );
  }

  static String _formatNumber(double n) {
    if (n == n.roundToDouble()) {
      return n.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return n.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

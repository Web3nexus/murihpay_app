class Transaction {
  final String id;
  final String type;
  final double amount;
  final double fee;
  final String currency;
  final String status;
  final String description;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.fee = 0,
    required this.currency,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit' || type == 'deposit' || type == 'fund';
  bool get isDebit => !isCredit;
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed' || status == 'success';

  String get amountDisplay {
    final prefix = isCredit ? '+' : '-';
    final symbol = _currencySymbol(currency);
    return '$prefix$symbol${_formatNumber(amount)}';
  }

  String get formattedDate {
    final d = createdAt;
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'debit',
      amount: (json['amount'] ?? 0).toDouble(),
      fee: (json['fee'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  static String _currencySymbol(String c) {
    switch (c) {
      case 'NGN': return '₦';
      case 'USD': return '\$';
      case 'GBP': return '£';
      default: return '\$';
    }
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

class ExchangeRate {
  final String from;
  final String to;
  final double rate;
  final double? change;

  ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    this.change,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      change: (json['change'] as num?)?.toDouble(),
    );
  }
}

class Investment {
  final String id;
  final String name;
  final String description;
  final double apy;
  final double minInvestment;
  final double? totalInvested;
  final String? status;

  Investment({
    required this.id,
    required this.name,
    required this.description,
    required this.apy,
    required this.minInvestment,
    this.totalInvested,
    this.status,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      apy: (json['apy'] ?? 0).toDouble(),
      minInvestment: (json['min_investment'] ?? 0).toDouble(),
      totalInvested: (json['total_invested'] as num?)?.toDouble(),
      status: json['status']?.toString(),
    );
  }
}

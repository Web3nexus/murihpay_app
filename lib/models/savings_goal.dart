class SavingsGoal {
  final String uuid;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final String? icon;
  final String? color;
  final String? deadline;
  final String status;
  final double progress;
  final String createdAt;

  const SavingsGoal({
    required this.uuid,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    this.icon,
    this.color,
    this.deadline,
    required this.status,
    this.progress = 0,
    required this.createdAt,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      deadline: json['deadline']?.toString(),
      status: json['status']?.toString() ?? 'active',
      progress: (json['progress'] ?? 0).toDouble(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'target_amount': targetAmount,
    'currency': currency,
    'icon': icon,
    'color': color,
    'deadline': deadline,
  };
}

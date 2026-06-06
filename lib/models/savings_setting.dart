class SavingsSetting {
  final int id;
  final int userId;
  final bool spendSaveActive;
  final double spendSavePercentage;
  final String defaultSaveCurrency;

  const SavingsSetting({
    required this.id,
    required this.userId,
    required this.spendSaveActive,
    required this.spendSavePercentage,
    required this.defaultSaveCurrency,
  });

  factory SavingsSetting.fromJson(Map<String, dynamic> json) {
    return SavingsSetting(
      id: (json['id'] ?? 0).toInt(),
      userId: (json['user_id'] ?? 0).toInt(),
      spendSaveActive: json['spend_save_active'] == true,
      spendSavePercentage: (json['spend_save_percentage'] ?? 10).toDouble(),
      defaultSaveCurrency: json['default_save_currency']?.toString() ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {
    'spend_save_active': spendSaveActive,
    'spend_save_percentage': spendSavePercentage,
    'default_save_currency': defaultSaveCurrency,
  };
}

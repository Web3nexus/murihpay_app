class Beneficiary {
  final String id;
  final String name;
  final String? accountNumber;
  final String? bankName;
  final String? email;

  Beneficiary({
    required this.id,
    required this.name,
    this.accountNumber,
    this.bankName,
    this.email,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

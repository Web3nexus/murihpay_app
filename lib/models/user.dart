class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String kycStatus;
  final bool twoFactorEnabled;
  final String? tier;
  final String? avatarUrl;
  final String? referralCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.role = 'user',
    this.kycStatus = 'pending',
    this.twoFactorEnabled = false,
    this.tier,
    this.avatarUrl,
    this.referralCode,
  });

  bool get isAdmin => role == 'admin' || role == 'developer';
  bool get kycApproved => kycStatus == 'approved';
  bool get kycPending => kycStatus == 'pending';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      role: json['role']?.toString() ?? 'user',
      kycStatus: json['kyc_status']?.toString() ?? 'pending',
      twoFactorEnabled: json['two_factor_enabled'] == true,
      tier: json['tier']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      referralCode: json['referral_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone_number': phoneNumber,
    'role': role,
    'kyc_status': kycStatus,
    'two_factor_enabled': twoFactorEnabled,
    'tier': tier,
    'avatar_url': avatarUrl,
    'referral_code': referralCode,
  };
}

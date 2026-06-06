class KycSubmission {
  final String id;
  final String documentType;
  final String status;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? selfieUrl;
  final String? rejectionReason;
  final DateTime createdAt;

  KycSubmission({
    required this.id,
    required this.documentType,
    required this.status,
    this.frontImageUrl,
    this.backImageUrl,
    this.selfieUrl,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory KycSubmission.fromJson(Map<String, dynamic> json) {
    return KycSubmission(
      id: json['id']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      frontImageUrl: json['front_image_url']?.toString(),
      backImageUrl: json['back_image_url']?.toString(),
      selfieUrl: json['selfie_url']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}

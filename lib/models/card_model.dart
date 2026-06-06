class CardModel {
  final String id;
  final String uuid;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String? cvv;
  final String type;
  final double balance;
  final String currency;
  final bool isFrozen;
  final String? brand;

  CardModel({
    required this.id,
    required this.uuid,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    this.cvv,
    required this.type,
    this.balance = 0,
    this.currency = 'USD',
    this.isFrozen = false,
    this.brand,
  });

  String get maskedNumber {
    if (cardNumber.length >= 8) {
      return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      cardNumber: json['card_number']?.toString() ?? '****',
      cardholderName: json['cardholder_name']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '12/28',
      cvv: json['cvv']?.toString(),
      type: json['type']?.toString() ?? 'virtual',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      isFrozen: json['is_frozen'] == true,
      brand: json['brand']?.toString(),
    );
  }
}

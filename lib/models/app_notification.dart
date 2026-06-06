class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final String? publishedAt;
  final bool isRead;
  final String? readAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    this.publishedAt,
    this.isRead = false,
    this.readAt,
  });

  bool get isBanner => type == 'banner';
  bool get isNewsletter => type == 'newsletter';
  bool get isPromotion => type == 'promotion';
  bool get isWarning => type == 'warning';
  bool get isInfo => type == 'info';

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      actionUrl: json['action_url']?.toString(),
      publishedAt: json['published_at']?.toString(),
      isRead: json['is_read'] == true,
      readAt: json['read_at']?.toString(),
    );
  }
}

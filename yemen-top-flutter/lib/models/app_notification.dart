class AppNotification {
  final String id;
  final String kind;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? createdAt;

  AppNotification({required this.id, required this.kind, this.title, this.body,
    this.data = const {}, this.isRead = false, this.createdAt});

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'].toString(),
        kind: j['kind'] ?? 'general',
        title: j['title'],
        body: j['body'],
        data: (j['data'] is Map) ? Map<String, dynamic>.from(j['data']) : const {},
        isRead: j['is_read'] ?? false,
        createdAt: j['created_at'],
      );
}

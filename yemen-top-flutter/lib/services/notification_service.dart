import '../models/app_notification.dart';
import 'api_client.dart';

class NotificationService {
  final _api = ApiClient.instance;

  Future<List<AppNotification>> list() async {
    final res = await _api.get('notifications');
    return (res['data'] as List).map((n) => AppNotification.fromJson(n)).toList();
  }

  Future<int> unreadCount() async {
    final res = await _api.get('notifications/unread-count');
    return res['count'] ?? 0;
  }

  Future<void> markRead(String id) async => _api.post('notifications/$id/read');
  Future<void> markAllRead() async => _api.post('notifications/read-all');

  Future<void> registerDevice(String token, {String platform = 'android'}) async {
    await _api.post('device-tokens', {'token': token, 'platform': platform});
  }
}

import '../models/app_config.dart';
import 'api_client.dart';

/// جلب إعدادات التطبيق من السيرفر: GET /api/app-config
class AppConfigService {
  final _api = ApiClient.instance;

  Future<AppConfig> fetch() async {
    final res = await _api.get('app-config');
    // النقطة قد تُرجع الكائن مباشرة أو مغلّفاً داخل مفتاح data — ندعم الحالتين.
    final map = (res is Map && res['data'] is Map) ? res['data'] : res;
    return AppConfig.fromJson(Map<String, dynamic>.from(map as Map));
  }
}

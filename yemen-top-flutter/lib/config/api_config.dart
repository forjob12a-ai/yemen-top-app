/// إعدادات الاتصال بالـ API
class ApiConfig {
  /// ⚠️ غيّر هذا إلى رابط موقعك (مثال: https://yementop.com/api)
  /// للتجربة على محاكي أندرويد استخدم: http://10.0.2.2:8000/api
  static const String baseUrl = 'https://yementop.com/api';

  static const Duration timeout = Duration(seconds: 30);
}

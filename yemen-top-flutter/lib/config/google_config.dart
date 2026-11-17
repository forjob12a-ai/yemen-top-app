/// إعداد تسجيل الدخول بجوجل.
///
/// serverClientId = «معرّف العميل» من نوع Web application في Google Cloud (مشروع yemen-top-506418)،
/// وهو معرّف عام وليس سراً، ويجب أن يطابق GOOGLE_CLIENT_ID على الخادم.
/// لا تضع أي سر (client secret) في التطبيق.
class GoogleConfig {
  /// ⚠️ ضع هنا Web client ID (ينتهي بـ .apps.googleusercontent.com)
  static const String serverClientId = 'PUT_WEB_CLIENT_ID_HERE';

  static bool get isConfigured =>
      serverClientId.isNotEmpty && !serverClientId.startsWith('PUT_');
}

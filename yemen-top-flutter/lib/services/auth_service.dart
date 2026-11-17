import '../models/user.dart';
import 'api_client.dart';

/// نتيجة التسجيل: الحساب، وهل أُرسل رابط تأكيد البريد
class RegisterResult {
  final User user;
  final bool emailVerificationSent;
  const RegisterResult({required this.user, required this.emailVerificationSent});
}

class AuthService {
  final _api = ApiClient.instance;

  /// البريد مطلوب (مثل الموقع)، والجوال اختياري ويُرسل فقط إن كُتب
  Future<RegisterResult> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _api.post('register', {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _api.setToken(res['token']);
    return RegisterResult(
      user: User.fromJson(res['user']),
      emailVerificationSent: res['email_verification_sent'] == true,
    );
  }

  /// الدخول بالبريد أو رقم الجوال (الخادم يقبل الاثنين في الحقل نفسه)
  Future<User> login({required String identifier, required String password}) async {
    final res = await _api.post('login', {'login': identifier, 'password': password});
    await _api.setToken(res['token']);
    return User.fromJson(res['user']);
  }

  Future<User> me() async {
    final res = await _api.get('me');
    return User.fromJson(res['data'] ?? res);
  }

  Future<void> logout() async {
    try {
      await _api.post('logout');
    } catch (_) {}
    await _api.clearToken();
  }

  Future<User> updateProfile({required String name, required String phone, String? email}) async {
    final res = await _api.put('profile', {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
    });
    return User.fromJson(res['data'] ?? res);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.put('profile/password', {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}

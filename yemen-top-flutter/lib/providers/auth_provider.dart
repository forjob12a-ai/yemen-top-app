import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/google_sign_in_service.dart';

enum AuthStatus { unknown, authenticated, guest }

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// عند تشغيل التطبيق: حمّل التوكن وجرّب جلب المستخدم
  Future<void> bootstrap() async {
    await ApiClient.instance.loadToken();
    if (!ApiClient.instance.isAuthenticated) {
      _set(AuthStatus.guest, null);
      return;
    }
    try {
      _user = await _auth.me();
      _set(AuthStatus.authenticated, _user);
    } catch (_) {
      await ApiClient.instance.clearToken();
      _set(AuthStatus.guest, null);
    }
  }

  /// identifier: البريد أو رقم الجوال
  Future<void> login(String identifier, String password) async {
    _user = await _auth.login(identifier: identifier, password: password);
    _set(AuthStatus.authenticated, _user);
  }

  /// الدخول بحساب جوجل. يرجع false إن ألغى المستخدم النافذة
  Future<bool> signInWithGoogle() async {
    final idToken = await GoogleSignInService.idToken();
    if (idToken == null) return false;
    _user = await _auth.loginWithGoogle(idToken);
    _set(AuthStatus.authenticated, _user);
    return true;
  }

  /// يرجع true إن أُرسل رابط تأكيد البريد (الشراء يحتاج البريد المؤكَّد)
  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _auth.register(
      name: name, email: email, phone: phone,
      password: password, passwordConfirmation: passwordConfirmation,
    );
    _set(AuthStatus.authenticated, result.user);
    return result.emailVerificationSent;
  }

  Future<void> logout() async {
    await _auth.logout();
    _set(AuthStatus.guest, null);
  }

  /// تحديث بيانات المستخدم (بعد تعديل ملف/رصيد)
  Future<void> refresh() async {
    try {
      _user = await _auth.me();
      notifyListeners();
    } catch (_) {}
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void _set(AuthStatus s, User? u) {
    _status = s;
    _user = u;
    notifyListeners();
  }
}

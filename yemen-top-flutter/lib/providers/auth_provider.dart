import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

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

  Future<void> login(String phone, String password) async {
    _user = await _auth.login(phone: phone, password: password);
    _set(AuthStatus.authenticated, _user);
  }

  Future<void> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _user = await _auth.register(
      name: name, phone: phone, email: email,
      password: password, passwordConfirmation: passwordConfirmation,
    );
    _set(AuthStatus.authenticated, _user);
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

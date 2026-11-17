import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient.instance;

  Future<User> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _api.post('register', {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _api.setToken(res['token']);
    return User.fromJson(res['user']);
  }

  Future<User> login({required String phone, required String password}) async {
    final res = await _api.post('login', {'phone': phone, 'password': password});
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

import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_config.dart';

/// يفتح نافذة اختيار حساب جوجل، ويرجع رمز الهوية (id_token) الذي يتحقق منه الخادم.
class GoogleSignInService {
  static bool _initialized = false;

  /// يرجع null إن ألغى المستخدم النافذة
  static Future<String?> idToken() async {
    if (!GoogleConfig.isConfigured) {
      throw StateError('معرّف جوجل غير مضبوط. ضع Web client ID في lib/config/google_config.dart');
    }

    if (!_initialized) {
      await GoogleSignIn.instance.initialize(serverClientId: GoogleConfig.serverClientId);
      _initialized = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw StateError('لم يصل رمز الدخول من جوجل');
      }
      return token;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}

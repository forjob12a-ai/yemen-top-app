import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';
import '../models/currency.dart';
import '../services/app_config_service.dart';

/// يحمل العملات والعملة المختارة وبيانات التواصل، ويحفظ اختيار العملة محلياً.
class AppConfigProvider extends ChangeNotifier {
  static const _prefsKey = 'selected_currency_code';
  final _service = AppConfigService();

  /// العملة الفعّالة التي تقرأها دالة money() في كل التطبيق (ثابتة عامة).
  static Currency activeCurrency = Currency.fallback;

  List<Currency> _currencies = const [Currency.fallback];
  Currency _selected = Currency.fallback;
  ContactInfo _contact = const ContactInfo();
  bool _loaded = false;

  List<Currency> get currencies => _currencies;
  Currency get selected => _selected;
  ContactInfo get contact => _contact;
  bool get loaded => _loaded;

  /// تُستدعى مرة واحدة عند إقلاع التطبيق (من شاشة البداية).
  Future<void> load() async {
    try {
      final config = await _service.fetch();
      if (config.currencies.isNotEmpty) _currencies = config.currencies;
      _contact = config.contact;

      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefsKey);

      _selected = _pickCurrency(savedCode, config.defaultCurrency);
      activeCurrency = _selected;
    } catch (_) {
      // عند فشل الاتصال نبقى على الريال اليمني الافتراضي حتى لا ينكسر التطبيق.
      _currencies = const [Currency.fallback];
      _selected = Currency.fallback;
      activeCurrency = Currency.fallback;
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  /// اختيار العملة: المحفوظة محلياً، وإلا الافتراضية من السيرفر، وإلا أول عملة.
  Currency _pickCurrency(String? savedCode, String defaultCode) {
    Currency? byCode(String? code) {
      if (code == null) return null;
      for (final c in _currencies) {
        if (c.code == code) return c;
      }
      return null;
    }

    return byCode(savedCode) ??
        byCode(defaultCode) ??
        _currencies.firstWhere((c) => c.isDefault,
            orElse: () => _currencies.first);
  }

  /// تغيير العملة المختارة وحفظها محلياً (يُعاد بناء الأسعار في كل التطبيق).
  Future<void> setCurrency(Currency c) async {
    _selected = c;
    activeCurrency = c;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, c.code);
  }
}

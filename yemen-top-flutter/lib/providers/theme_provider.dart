import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

/// يدير وضع الثيم (ليلي/نهاري) ويحفظ التفضيل محليًا.
/// الافتراضي ليلي للحفاظ على السلوك القديم للتطبيق.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_is_dark';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_key) ?? true;
      AppColors.apply(_isDark);
      notifyListeners();
    } catch (_) {
      // عند أي فشل نبقى على الوضع الليلي الافتراضي.
    }
  }

  Future<void> toggle() async {
    await setDark(!_isDark);
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    AppColors.apply(_isDark);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, _isDark);
    } catch (_) {}
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية يمن توب — لوحة ألوان قابلة للتبديل (ليلي/نهاري).
/// ثوابت الهوية لا تتغير بين الوضعين وتبقى const،
/// أما ألوان الخلفيات والنصوص فمتغيّرة ويبدّلها AppColors.apply().
class AppColors {
  // ===== ثوابت الهوية (لا تتغير بين الوضعين) =====
  static const orange = Color(0xFFFE7A39);
  static const orangeDeep = Color(0xFFE85F1F);
  static const royal = Color(0xFF5570E4);
  static const royalDeep = Color(0xFF3752AD);
  static const gold = Color(0xFFF6C44E);
  static const good = Color(0xFF37D6A0);
  static const bad = Color(0xFFFF6B6B);

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDeep],
  );
  static const royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royal, royalDeep],
  );

  // ===== لوحة الوضع الليلي (نفس القيم الأصلية حرفيًا) =====
  static const _dInk = Color(0xFF0B0916);
  static const _dNavy = Color(0xFF160733);
  static const _dNavy2 = Color(0xFF1E0E44);
  static const _dNavy3 = Color(0xFF2A1559);
  static const _dText = Color(0xFFF4F0FB);
  static const _dMuted = Color(0xFFA99FC6);
  static const _dLine = Color(0x14FFFFFF);
  static const _dCard = Color(0x0DFFFFFF);
  static const _dWallet = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [royalDeep, _dNavy3, orangeDeep],
  );

  // ===== لوحة الوضع النهاري =====
  static const _lInk = Color(0xFFF6F4FB);
  static const _lNavy = Color(0xFFFFFFFF);
  static const _lNavy2 = Color(0xFFF1EDF9);
  static const _lNavy3 = Color(0xFFE7E0F5);
  static const _lText = Color(0xFF1A1230);
  static const _lMuted = Color(0xFF6B6386);
  static const _lLine = Color(0x14000000);
  static const _lCard = Color(0x08000000);
  static const _lWallet = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFE3DCFA), Color(0xFFF0E4F7), Color(0xFFFBE3D4)],
  );

  // ===== الحالة الحالية (تبدأ ليلية للحفاظ على السلوك القديم) =====
  static bool isDark = true;
  static Color ink = _dInk;
  static Color navy = _dNavy;
  static Color navy2 = _dNavy2;
  static Color navy3 = _dNavy3;
  static Color text = _dText;
  static Color muted = _dMuted;
  static Color line = _dLine;
  static Color card = _dCard;
  static LinearGradient walletGradient = _dWallet;

  /// تبديل اللوحة بالكامل. تُستدعى تلقائيًا عند بناء الثيم.
  static void apply(bool dark) {
    isDark = dark;
    ink = dark ? _dInk : _lInk;
    navy = dark ? _dNavy : _lNavy;
    navy2 = dark ? _dNavy2 : _lNavy2;
    navy3 = dark ? _dNavy3 : _lNavy3;
    text = dark ? _dText : _lText;
    muted = dark ? _dMuted : _lMuted;
    line = dark ? _dLine : _lLine;
    card = dark ? _dCard : _lCard;
    walletGradient = dark ? _dWallet : _lWallet;
  }
}

class AppTheme {
  static ThemeData get dark => _build(true);
  static ThemeData get light => _build(false);

  static ThemeData _build(bool dark) {
    AppColors.apply(dark);
    final base = dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.orange,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.orange,
        secondary: AppColors.royal,
        surface: AppColors.navy,
        error: AppColors.bad,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.tajawal(
          color: AppColors.text,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      cardColor: AppColors.navy,
      dividerColor: AppColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: TextStyle(color: AppColors.muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static TextStyle get display =>
      GoogleFonts.tajawal(fontWeight: FontWeight.w800, color: AppColors.text);
}
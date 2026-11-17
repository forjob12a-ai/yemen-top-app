import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية يمن توب — نفس ألوان الموقع (public/css/theme-v2.css) وبنفس الأسماء:
/// orange = لون الإجراء الرئيسي (أخضر)، royal = الأزرق، navy = البطاقات والأسطح، ink = خلفية الصفحة.
/// ما يختلف بين الوضعين متغيّر ويبدّله AppColors.apply()، وما يثبت في الوضعين const.
class AppColors {
  // ===== ثابتة في الوضعين =====
  /// الشريط العلوي والسفلي (كحلي ثابت مثل الموقع: --yt2-bar)
  static const bar = Color(0xFF000628);

  /// عناصر الشريط السفلي غير النشطة (أبيض 72%)
  static const barText = Color(0xB8FFFFFF);

  /// العنصر النشط في الشريط، وأي نص أخضر فوق الشريط الكحلي
  static const barActive = Color(0xFF47FF91);

  /// بطاقة المحفظة والدخول (--yt2-brand)
  static const brand = Color(0xFF0277BD);
  static const royal = Color(0xFF0277BD);
  static const royalDeep = Color(0xFF01579B);
  static const royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0288D1), royalDeep],
  );

  // ===== الوضع الداكن (:root في theme-v2.css) =====
  static const _dInk = Color(0xFF000628);
  static const _dNavy = Color(0xFF0B1137);
  static const _dNavy2 = Color(0xFF000628);
  static const _dNavy3 = Color(0xFF1A2150);
  static const _dText = Color(0xFFFFFFFF);
  static const _dMuted = Color(0xFFA6ABCB);
  static const _dLine = Color(0x1FFFFFFF);
  static const _dCard = Color(0x0DFFFFFF);
  static const _dField = Color(0x14FFFFFF);
  static const _dOrange = Color(0xFF4CAF50);
  static const _dOrangeDeep = Color(0xFF43A047);
  static const _dOnAccent = Color(0xFF000628);
  static const _dLink = Color(0xFF4FC3F7);
  static const _dGold = Color(0xFFF6C44E);
  static const _dGood = Color(0xFF37D6A0);
  static const _dBad = Color(0xFFFF6B6B);

  // ===== الوضع الفاتح ([data-theme="light"] في theme-v2.css) =====
  static const _lInk = Color(0xFFF1F1F1);
  static const _lNavy = Color(0xFFFFFFFF);
  static const _lNavy2 = Color(0xFFF1F1F1);
  static const _lNavy3 = Color(0xFFE6E7EE);
  static const _lText = Color(0xFF23233C);
  static const _lMuted = Color(0xFF5D5D78);
  static const _lLine = Color(0x1F000000);
  static const _lCard = Color(0x08000000);
  static const _lField = Color(0x0F000000);
  static const _lOrange = Color(0xFF2E7D32);
  static const _lOrangeDeep = Color(0xFF27692B);
  static const _lOnAccent = Color(0xFFFFFFFF);
  static const _lLink = Color(0xFF0277BD);
  static const _lGold = Color(0xFF8F5D00);
  static const _lGood = Color(0xFF0B7A53);
  static const _lBad = Color(0xFFC62F2F);

  // ===== الحالة الحالية (تبدأ داكنة، ويضبطها ThemeProvider عند التشغيل) =====
  static bool isDark = true;
  static Color ink = _dInk;
  static Color navy = _dNavy;
  static Color navy2 = _dNavy2;
  static Color navy3 = _dNavy3;
  static Color text = _dText;
  static Color muted = _dMuted;
  static Color line = _dLine;
  static Color card = _dCard;
  static Color field = _dField;

  /// لون الإجراء الرئيسي (أخضر الموقع)
  static Color orange = _dOrange;
  static Color orangeDeep = _dOrangeDeep;

  /// لون النص فوق الأخضر (كحلي في الداكن، أبيض في الفاتح — --on-accent)
  static Color onAccent = _dOnAccent;

  /// الروابط والأزرار النصية
  static Color link = _dLink;
  static Color gold = _dGold;
  static Color good = _dGood;
  static Color bad = _dBad;
  static LinearGradient orangeGradient = _gradient(_dOrange, _dOrangeDeep);

  /// بطاقة المحفظة: أزرق الهوية في الوضعين (نصها أبيض)
  static const LinearGradient walletGradient = royalGradient;

  static LinearGradient _gradient(Color a, Color b) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [a, b],
      );

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
    field = dark ? _dField : _lField;
    orange = dark ? _dOrange : _lOrange;
    orangeDeep = dark ? _dOrangeDeep : _lOrangeDeep;
    onAccent = dark ? _dOnAccent : _lOnAccent;
    link = dark ? _dLink : _lLink;
    gold = dark ? _dGold : _lGold;
    good = dark ? _dGood : _lGood;
    bad = dark ? _dBad : _lBad;
    orangeGradient = dark
        ? _gradient(_dOrange, _dOrangeDeep)
        : _gradient(_lOrange, _lOrangeDeep);
  }
}

class AppTheme {
  static ThemeData get dark => _build(true);
  static ThemeData get light => _build(false);

  /// خط الموقع: Tajawal لكل النصوص
  static String? get _font => GoogleFonts.tajawal().fontFamily;

  static ThemeData _build(bool dark) {
    AppColors.apply(dark);
    final base = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: _font,
    );
    final pill = WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder());

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.orange,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.orange,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.royal,
        onSecondary: Colors.white,
        surface: AppColors.navy,
        onSurface: AppColors.text,
        error: AppColors.bad,
      ),
      textTheme: GoogleFonts.tajawalTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),

      // الشريط العلوي كحلي ثابت في الوضعين مثل الموقع، ونصه وأيقوناته بيضاء
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bar,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: AppColors.bar,
        ),
        titleTextStyle: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // الشريط السفلي: كحلي، والعنصر النشط أخضر داخل كبسولة خفيفة
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bar,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.barActive.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.barActive
                  : AppColors.barText,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final on = states.contains(WidgetState.selected);
          return GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: on ? FontWeight.w800 : FontWeight.w600,
            color: on ? AppColors.barActive : AppColors.barText,
          );
        }),
      ),

      cardColor: AppColors.navy,
      dividerColor: AppColors.line,
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.orange),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.field,
        hintStyle: TextStyle(color: AppColors.muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.orange, width: 1.6),
        ),
      ),

      // أزرار بيضاوية مثل الموقع: الإجراء الرئيسي أخضر ونصه --on-accent
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
          shape: const StadiumBorder(),
          textStyle:
              GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: pill,
          foregroundColor: WidgetStateProperty.all(AppColors.text),
          side: WidgetStateProperty.all(BorderSide(color: AppColors.line)),
          textStyle: WidgetStateProperty.all(
              GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          textStyle:
              GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static TextStyle get display =>
      GoogleFonts.tajawal(fontWeight: FontWeight.w800, color: AppColors.text);
}

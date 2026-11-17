import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية يمن توب — نفس ألوان الموقع (داكن)
class AppColors {
  static const ink = Color(0xFF0B0916);
  static const navy = Color(0xFF160733);
  static const navy2 = Color(0xFF1E0E44);
  static const navy3 = Color(0xFF2A1559);
  static const orange = Color(0xFFFE7A39);
  static const orangeDeep = Color(0xFFE85F1F);
  static const royal = Color(0xFF5570E4);
  static const royalDeep = Color(0xFF3752AD);
  static const gold = Color(0xFFF6C44E);
  static const text = Color(0xFFF4F0FB);
  static const muted = Color(0xFFA99FC6);
  static const good = Color(0xFF37D6A0);
  static const bad = Color(0xFFFF6B6B);
  static const line = Color(0x14FFFFFF);
  static const card = Color(0x0DFFFFFF);

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [orange, orangeDeep],
  );
  static const royalGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [royal, royalDeep],
  );
  static const walletGradient = LinearGradient(
    begin: Alignment.topRight, end: Alignment.bottomLeft,
    colors: [royalDeep, navy3, orangeDeep],
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.orange,
      colorScheme: const ColorScheme.dark(
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
          color: AppColors.text, fontSize: 19, fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      cardColor: AppColors.navy,
      dividerColor: AppColors.line,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: const TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.line),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static TextStyle get display => GoogleFonts.tajawal(
        fontWeight: FontWeight.w800, color: AppColors.text);
}

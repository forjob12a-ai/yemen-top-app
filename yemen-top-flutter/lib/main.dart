import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/app_config_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
void main() {
  runApp(const YemenTopApp());
}
class YemenTopApp extends StatelessWidget {
  const YemenTopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AppConfigProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // نبني ثيمًا واحدًا مطابقًا للوضع الحالي، فتتزامن قيم AppColors الساكنة.
          final theme = themeProvider.isDark ? AppTheme.dark : AppTheme.light;
          return MaterialApp(
            title: 'يمن توب',
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/auth/login_screen.dart';

/// شاشة تُعرض للزائر عند محاولة الوصول لقسم يتطلب تسجيل الدخول
class AuthRequiredView extends StatelessWidget {
  final String message;
  const AuthRequiredView({super.key, this.message = 'سجّل الدخول للوصول إلى هذا القسم.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78, height: 78,
              decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text('تسجيل الدخول مطلوب', style: AppTheme.display.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

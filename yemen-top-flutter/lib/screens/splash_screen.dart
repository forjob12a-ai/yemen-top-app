import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await context.read<AuthProvider>().bootstrap();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.4), blurRadius: 30)],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 22),
            Text('يمن توب', style: AppTheme.display.copyWith(fontSize: 30)),
            const SizedBox(height: 6),
            const Text('للخدمات الرقمية', style: TextStyle(color: AppColors.muted, fontSize: 14)),
            const SizedBox(height: 34),
            const CircularProgressIndicator(color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}

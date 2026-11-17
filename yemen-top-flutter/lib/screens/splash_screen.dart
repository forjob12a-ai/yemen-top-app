// شاشة السبلاش — أنميشن «بوابة توب الكونية» (تصميم جسر المعلومات)
// المنطق محفوظ: تحميل بيانات الدخول + الإعدادات بالتوازي، والانتقال بعد اكتمال (التحميل + الأنميشن) معاً.
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_config_provider.dart';
import 'home/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  bool _bootDone = false;
  bool _animDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    final config = context.read<AppConfigProvider>();
    // تحميل بيانات الدخول وإعدادات التطبيق (العملات + التواصل) معاً — كما كان.
    await Future.wait([auth.bootstrap(), config.load()]);
    _bootDone = true;
    _tryNavigate();
  }

  void _tryNavigate() {
    if (_bootDone && _animDone && !_navigated && mounted) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04020C),
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/animations/yemen-top-portal.json',
          controller: _c,
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (comp) {
            _c.duration = comp.duration * 2;
            Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _c.forward(); });
            _c.addStatusListener((s) {
              if (s == AnimationStatus.completed) {
                _animDone = true;
                _tryNavigate();
              }
            });
          },
          errorBuilder: (_, __, ___) {
            // لو تعذّر تحميل الأنميشن لأي سبب — ما نعلّق المستخدم: نعتبره منتهياً.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animDone = true;
              _tryNavigate();
            });
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFE7A39)));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}




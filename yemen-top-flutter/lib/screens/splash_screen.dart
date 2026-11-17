// ط´ط§ط´ط© ط§ظ„ط³ط¨ظ„ط§ط´ â€” ط£ظ†ظ…ظٹط´ظ† آ«ط¨ظˆط§ط¨ط© طھظˆط¨ ط§ظ„ظƒظˆظ†ظٹط©آ» (طھطµظ…ظٹظ… ط¬ط³ط± ط§ظ„ظ…ط¹ظ„ظˆظ…ط§طھ)
// ط§ظ„ظ…ظ†ط·ظ‚ ظ…ط­ظپظˆط¸: طھط­ظ…ظٹظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„ط¯ط®ظˆظ„ + ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ ط¨ط§ظ„طھظˆط§ط²ظٹطŒ ظˆط§ظ„ط§ظ†طھظ‚ط§ظ„ ط¨ط¹ط¯ ط§ظƒطھظ…ط§ظ„ (ط§ظ„طھط­ظ…ظٹظ„ + ط§ظ„ط£ظ†ظ…ظٹط´ظ†) ظ…ط¹ط§ظ‹.
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
    // طھط­ظ…ظٹظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„ط¯ط®ظˆظ„ ظˆط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„طھط·ط¨ظٹظ‚ (ط§ظ„ط¹ظ…ظ„ط§طھ + ط§ظ„طھظˆط§طµظ„) ظ…ط¹ط§ظ‹ â€” ظƒظ…ط§ ظƒط§ظ†.
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
            // ظ„ظˆ طھط¹ط°ظ‘ط± طھط­ظ…ظٹظ„ ط§ظ„ط£ظ†ظ…ظٹط´ظ† ظ„ط£ظٹ ط³ط¨ط¨ â€” ظ…ط§ ظ†ط¹ظ„ظ‘ظ‚ ط§ظ„ظ…ط³طھط®ط¯ظ…: ظ†ط¹طھط¨ط±ظ‡ ظ…ظ†طھظ‡ظٹط§ظ‹.
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




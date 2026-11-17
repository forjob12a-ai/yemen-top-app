import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/google_sign_in_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_phone.text.trim().isEmpty || _password.text.isEmpty) {
      _snack('أدخل بريدك أو رقم جوالك وكلمة المرور');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(_phone.text.trim(), _password.text);
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// الدخول بحساب جوجل: بلا كتابة بريد أو كلمة مرور
  Future<void> _google() async {
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    try {
      final ok = await context.read<AuthProvider>().signInWithGoogle();
      if (ok) navigator.pop(true);
    } on ApiException catch (e) {
      _snack(e.firstError);
    } on StateError catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('تعذّر تسجيل الدخول عبر جوجل. حاول مرة أخرى أو ادخل بالبريد.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.bad));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text('أهلاً بعودتك 👋', style: AppTheme.display.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text('أدخل بريدك أو رقم جوالك وكلمة المرور للمتابعة.',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 26),
            const Text('البريد أو رقم الجوال', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'name@example.com أو 7XXXXXXXX',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 16),
            const Text('كلمة المرور', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'كلمة المرور',
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.muted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('دخول'),
            ),
            const SizedBox(height: 18),
            GoogleSignInButton(onPressed: _loading ? null : _google),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ليس لديك حساب؟', style: TextStyle(color: AppColors.muted)),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final ok = await Navigator.push<bool>(
                        context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    if (ok == true && mounted) navigator.pop(true);
                  },
                  child: const Text('أنشئ حساباً', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

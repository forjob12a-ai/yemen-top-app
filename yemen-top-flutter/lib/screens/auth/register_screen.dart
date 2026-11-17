import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// نفس قواعد الخادم (RegisterRequest): الاسم 3 أحرف فأكثر، والبريد مطلوب وصالح،
  /// والجوال اختياري بصيغة يمنية، وكلمة المرور 8 أحرف فأكثر، والتأكيد مطابق
  String? _validate() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    if (name.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return 'أدخل بريداً إلكترونياً صحيحاً';
    if (phone.isNotEmpty && !RegExp(r'^7[01378][0-9]{7}$').hasMatch(phone)) {
      return 'رقم الجوال 9 أرقام يمنية تبدأ بـ 7';
    }
    if (_password.text.length < 8) return 'كلمة المرور 8 أحرف على الأقل';
    if (_password.text != _confirm.text) return 'تأكيد كلمة المرور غير مطابق';
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      _snack(problem);
      return;
    }
    setState(() => _loading = true);
    try {
      final sent = await context.read<AuthProvider>().register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirm.text,
          );
      if (sent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إنشاء الحساب. أرسلنا رابط التأكيد إلى بريدك، وهو مطلوب قبل الشراء.'),
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// الدخول أو التسجيل بحساب جوجل: بلا كتابة بريد أو كلمة مرور
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
      _snack('تعذّر تسجيل الدخول عبر جوجل. حاول مرة أخرى أو أنشئ الحساب بالبريد.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.bad));

  Widget _field(String label, TextEditingController c,
      {String? hint, TextInputType? type, bool obscure = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Text('انضم إلى يمن توب', style: AppTheme.display.copyWith(fontSize: 23)),
            const SizedBox(height: 6),
            Text('بريدك هو وسيلة دخولك، ونرسل إليه رابط تأكيد الحساب.',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 22),
            _field('الاسم الكامل', _name, hint: 'مثال: محمد أحمد'),
            _field('البريد الإلكتروني', _email,
                hint: 'name@example.com', type: TextInputType.emailAddress),
            _field('رقم الجوال (اختياري)', _phone,
                hint: '7XXXXXXXX', type: TextInputType.phone),
            _field('كلمة المرور', _password,
                hint: '8 أحرف على الأقل، أحرف وأرقام',
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.muted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )),
            _field('تأكيد كلمة المرور', _confirm,
                hint: 'أعد كتابة كلمة المرور', obscure: _obscure),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('إنشاء الحساب'),
            ),
            GoogleSignInButton(onPressed: _loading ? null : _google),
          ],
        ),
      ),
    );
  }
}

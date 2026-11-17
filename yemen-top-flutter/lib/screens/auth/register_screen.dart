import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _email.dispose();
    _password.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _password.text.isEmpty) {
      _snack('أكمل الحقول المطلوبة');
      return;
    }
    if (_password.text != _confirm.text) {
      _snack('تأكيد كلمة المرور غير مطابق');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirm.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر الاتصال بالخادم');
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
            Text('رقم جوالك هو وسيلة دخولك.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 22),
            _field('الاسم الكامل', _name, hint: 'مثال: محمد أحمد'),
            _field('رقم الجوال', _phone, hint: '7XXXXXXXX', type: TextInputType.phone),
            _field('البريد الإلكتروني (اختياري)', _email, hint: 'name@example.com', type: TextInputType.emailAddress),
            _field('كلمة المرور', _password,
                hint: '٨ أحرف على الأقل',
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.muted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )),
            _field('تأكيد كلمة المرور', _confirm, hint: 'أعد كتابة كلمة المرور', obscure: _obscure),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('إنشاء الحساب'),
            ),
          ],
        ),
      ),
    );
  }
}

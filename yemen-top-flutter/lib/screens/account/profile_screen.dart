import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';
import '../../widgets/auth_required.dart';
import '../orders/orders_screen.dart';
import '../wallet/wallet_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي'), automaticallyImplyLeading: false),
      body: !auth.isAuthenticated
          ? const AuthRequiredView(message: 'سجّل الدخول لإدارة حسابك.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // بطاقة المستخدم
                GradientBox(
                  gradient: AppColors.orangeGradient,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Text(
                          (auth.user?.name.isNotEmpty ?? false) ? auth.user!.name[0] : '؟',
                          style: AppTheme.display.copyWith(color: Colors.white, fontSize: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(auth.user?.name ?? '', style: AppTheme.display.copyWith(color: Colors.white, fontSize: 19)),
                            const SizedBox(height: 2),
                            Text(auth.user?.phone ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // رصيد المحفظة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.gold),
                      const SizedBox(width: 10),
                      const Text('رصيد المحفظة', style: TextStyle(color: AppColors.muted)),
                      const Spacer(),
                      Text(money(auth.user?.walletBalance ?? 0),
                          style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 17)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _tile(context, Icons.receipt_long_outlined, 'طلباتي', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                _tile(context, Icons.account_balance_wallet_outlined, 'محفظتي', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()))),
                _tile(context, Icons.notifications_outlined, 'الإشعارات', () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                const Divider(color: AppColors.line, height: 28),
                _tile(context, Icons.edit_outlined, 'تعديل الملف الشخصي', () => _editProfile(context)),
                _tile(context, Icons.lock_outline, 'تغيير كلمة المرور', () => _changePassword(context)),
                _tile(context, Icons.logout, 'تسجيل الخروج', () => _logout(context), color: AppColors.bad),
              ],
            ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
            color: AppColors.navy, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.text, size: 21),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.w700))),
            Icon(Icons.chevron_left, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('خروج', style: TextStyle(color: AppColors.bad)),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameC = TextEditingController(text: auth.user?.name);
    final phoneC = TextEditingController(text: auth.user?.phone);
    final emailC = TextEditingController(text: auth.user?.email);
    _sheet(context, 'تعديل الملف الشخصي', [
      _input('الاسم', nameC),
      _input('رقم الجوال', phoneC, type: TextInputType.phone),
      _input('البريد الإلكتروني', emailC, type: TextInputType.emailAddress),
    ], onSave: () async {
      final user = await AuthService().updateProfile(
        name: nameC.text.trim(), phone: phoneC.text.trim(), email: emailC.text.trim());
      auth.setUser(user);
    });
  }

  void _changePassword(BuildContext context) {
    final curC = TextEditingController();
    final newC = TextEditingController();
    final confC = TextEditingController();
    _sheet(context, 'تغيير كلمة المرور', [
      _input('كلمة المرور الحالية', curC, obscure: true),
      _input('كلمة المرور الجديدة', newC, obscure: true),
      _input('تأكيد كلمة المرور', confC, obscure: true),
    ], onSave: () async {
      await AuthService().changePassword(
        currentPassword: curC.text, password: newC.text, passwordConfirmation: confC.text);
    });
  }

  Widget _input(String label, TextEditingController c, {TextInputType? type, bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 7),
            TextField(controller: c, keyboardType: type, obscureText: obscure),
          ],
        ),
      );

  void _sheet(BuildContext context, String title, List<Widget> fields, {required Future<void> Function() onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Text(title, style: AppTheme.display.copyWith(fontSize: 18))),
                const SizedBox(height: 18),
                ...fields,
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    setSheet(() => saving = true);
                    try {
                      await onSave();
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: AppColors.good));
                      }
                    } on ApiException catch (e) {
                      setSheet(() => saving = false);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(e.firstError), backgroundColor: AppColors.bad));
                    } catch (_) {
                      setSheet(() => saving = false);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('تعذّر الحفظ'), backgroundColor: AppColors.bad));
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ'),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../models/package.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';
import '../payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _orders = OrderService();
  final _noteCtrl = TextEditingController();

  /// كود الخصم: يُفحص ويُحسب في الخادم عند تأكيد الطلب (مثل الموقع)، ولا يُقبل أي خصم من التطبيق
  final _couponCtrl = TextEditingController();
  String? _couponError;
  bool _loading = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    setState(() { _loading = true; _couponError = null; });
    try {
      final order = await _orders.checkout(cart.items,
          note: _noteCtrl.text.trim(), couponCode: _couponCtrl.text.trim());
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => PaymentScreen(order: order)));
    } on ApiException catch (e) {
      // كوبون غير صالح (منتهٍ، استُنفد، حد أدنى، مستوى لا يسمح...): الرسالة تحت الحقل ولا يُنشأ طلب
      final coupon = e.errors?['coupon_code'];
      if (coupon is List && coupon.isNotEmpty && mounted) setState(() => _couponError = coupon.first.toString());
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر إنشاء الطلب');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.bad));

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('بيانات المستلم', [
            _row('الاسم', user?.name ?? '—'),
            _row('الجوال', user?.phone ?? '—'),
          ]),
          const SizedBox(height: 14),
          _card('عناصر الطلب (${cart.count})',
              cart.items
                  .map((i) => _row(
                      // باقة الكمية: عدد الوحدات بدل ×الكمية
                      '${i.productName} — ${i.isQuantity ? '${Package.fmtInt(i.units!)} ${i.unitLabel ?? ''}' : '${i.packageName} ×${i.qty}'}',
                      money(i.total)))
                  .toList()),
          const SizedBox(height: 14),
          const Text('كود الخصم (اختياري)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _couponCtrl,
            textCapitalization: TextCapitalization.characters,
            textDirection: TextDirection.ltr,
            autocorrect: false,
            enableSuggestions: false,
            // إعادة البناء مع كل حرف: عنوان الإجمالي يتغيّر حين يُكتب كوبون، والخطأ يختفي
            onChanged: (_) => setState(() => _couponError = null),
            decoration: InputDecoration(
              hintText: 'مثل EID10',
              prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.muted),
              errorText: _couponError,
              errorMaxLines: 2,
              helperText: 'يُطبَّق عند تأكيد الطلب، وترى المبلغ بعد الخصم قبل الدفع.',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 14),
          const Text('ملاحظة (اختياري)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(controller: _noteCtrl, maxLines: 2,
              decoration: const InputDecoration(hintText: 'أي تفاصيل تساعدنا...')),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.navy, border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          // min: بدونها يأخذ الشريط السفلي الشاشة كلها ويخفي صفحة الطلب
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_couponCtrl.text.trim().isEmpty ? 'الإجمالي' : 'الإجمالي قبل الخصم',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(money(cart.subtotal), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _placeOrder,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تأكيد الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.display.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(l, style: TextStyle(color: AppColors.muted, fontSize: 13.5))),
            const SizedBox(width: 10),
            Text(r, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

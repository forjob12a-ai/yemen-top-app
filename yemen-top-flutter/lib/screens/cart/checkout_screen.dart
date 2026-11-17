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

  /// معاينة الخصم بعد «تطبيق» (من الخادم)، وملاحظة حين لا يدعمها الخادم بعد
  CouponPreview? _preview;
  String? _couponNote;
  bool _checking = false;
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

  /// «تطبيق»: الخصم والإجمالي من الخادم قبل التأكيد (مثل الموقع). عند التأكيد يُفحص الكود مرة أخرى
  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = 'اكتب كود الخصم.');
      return;
    }
    FocusScope.of(context).unfocus();
    final items = context.read<CartProvider>().items;
    setState(() { _checking = true; _couponError = null; _couponNote = null; _preview = null; });
    try {
      final preview = await _orders.couponCheck(items, code);
      if (mounted) setState(() => _preview = preview);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 404) {
        // خادم لم يُحدَّث بعد: الكود يبقى ويُطبَّق عند تأكيد الطلب
        setState(() => _couponNote = 'معاينة الخصم غير متاحة الآن، وسيُطبَّق الكود عند تأكيد الطلب.');
      } else {
        final c = e.errors?['coupon_code'];
        setState(() => _couponError = (c is List && c.isNotEmpty) ? c.first.toString() : e.firstError);
      }
    } catch (_) {
      if (mounted) setState(() => _couponError = 'تعذّر فحص الكود، حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _removeCoupon() => setState(() {
        _couponCtrl.clear();
        _preview = null;
        _couponError = null;
        _couponNote = null;
      });

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textDirection: TextDirection.ltr,
                  autocorrect: false,
                  enableSuggestions: false,
                  // إعادة البناء مع كل حرف: عنوان الإجمالي يتغيّر، والخطأ يختفي، والمعاينة تسقط إن تغيّر الكود
                  onChanged: (v) => setState(() {
                    _couponError = null;
                    _couponNote = null;
                    if (_preview != null && v.trim().toUpperCase() != _preview!.code.toUpperCase()) _preview = null;
                  }),
                  onSubmitted: (_) => _applyCoupon(),
                  decoration: InputDecoration(
                    hintText: 'مثل EID10',
                    prefixIcon: Icon(Icons.local_offer_outlined, color: AppColors.muted),
                    errorText: _couponError,
                    errorMaxLines: 2,
                    helperText: _preview != null ? null : (_couponNote ?? 'اضغط «تطبيق» لترى الخصم قبل تأكيد الطلب.'),
                    helperMaxLines: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _checking || _loading ? null : _applyCoupon,
                  child: _checking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('تطبيق'),
                ),
              ),
            ],
          ),
          if (_preview != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: AppColors.good),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('تم تطبيق ${_preview!.code}: خصم ${money(_preview!.discount)}',
                        style: TextStyle(color: AppColors.good, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  TextButton(onPressed: _removeCoupon, child: const Text('إزالة')),
                ],
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
              // بعد «تطبيق»: المجموع والخصم والإجمالي كما حسبها الخادم
              if (_preview != null) ...[
                _sumRow('المجموع', money(_preview!.subtotal)),
                _sumRow('الخصم (${_preview!.code})', '- ${money(_preview!.discount)}', color: AppColors.good),
                const SizedBox(height: 4),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      _preview != null
                          ? 'الإجمالي بعد الخصم'
                          : (_couponCtrl.text.trim().isEmpty ? 'الإجمالي' : 'الإجمالي قبل الخصم'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(money(_preview?.total ?? cart.subtotal),
                      style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 22)),
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

  Widget _sumRow(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.muted, fontSize: 13.5)),
            Text(value, textDirection: TextDirection.ltr, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.w700)),
          ],
        ),
      );

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

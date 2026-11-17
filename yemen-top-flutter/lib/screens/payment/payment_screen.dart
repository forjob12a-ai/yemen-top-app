import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../models/payment_method.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';
import '../orders/order_detail_screen.dart';
import '../wallet/topup_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;
  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _payment = PaymentService();
  final _refCtrl = TextEditingController();
  final _senderCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<PaymentMethod> _methods = [];
  PaymentMethod? _selectedManual;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _senderCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _methods = await _payment.methods();
      final manual = _methods.where((m) => m.code != 'wallet').toList();
      _selectedManual = manual.isNotEmpty ? manual.first : null;
    } catch (_) {
      _error = 'تعذّر تحميل طرق الدفع.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _payWallet() async {
    setState(() => _submitting = true);
    try {
      await _payment.payWithWallet(widget.order.id);
      await context.read<AuthProvider>().refresh();
      if (!mounted) return;
      _success('تم الدفع من المحفظة بنجاح!');
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر إتمام الدفع');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitManual() async {
    if (_selectedManual == null) return;
    if (_refCtrl.text.trim().isEmpty) {
      _snack('أدخل رقم العملية');
      return;
    }
    setState(() => _submitting = true);
    try {
      await _payment.submitManual(
        orderId: widget.order.id,
        methodId: _selectedManual!.id,
        transactionRef: _refCtrl.text.trim(),
        senderName: _senderCtrl.text.trim(),
      );
      if (!mounted) return;
      _success('تم استلام إثبات الدفع! سنراجعه قريباً.');
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر إرسال الإثبات');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _success(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.good));
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: widget.order.id)));
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.bad));

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<AuthProvider>().user?.walletBalance ?? 0;
    final enough = balance >= widget.order.total;
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الدفع')),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // المحفظة
                    GradientBox(
                      gradient: AppColors.walletGradient,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('رصيد محفظتك', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(money(balance), style: AppTheme.display.copyWith(color: Colors.white, fontSize: 26)),
                              ]),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                const Text('المطلوب', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(money(widget.order.total), style: AppTheme.display.copyWith(color: Colors.white, fontSize: 20)),
                                // خصم الكوبون كما حسبه الخادم عند إنشاء الطلب
                                if (widget.order.discount > 0)
                                  Text('بعد خصم ${money(widget.order.discount)}${widget.order.couponCode != null ? ' (${widget.order.couponCode})' : ''}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (enough)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _payWallet,
                                // زر أبيض فوق بطاقة المحفظة الزرقاء: نصه بلون الهوية في الوضعين (navy3 فاتح في الوضع الفاتح فلا يُقرأ)
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.brand),
                                child: const Text('ادفع الآن من المحفظة'),
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('رصيدك لا يكفي. اشحن محفظتك ثم عُد لإتمام الدفع.',
                                      style: TextStyle(color: Colors.white, fontSize: 12.5)),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                  onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => const TopupScreen())),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                                  child: const Text('اشحن المحفظة'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('أو ادفع بالتحويل', style: AppTheme.display.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._methods.where((m) => m.code != 'wallet').map(_manualTile),
                    if (_methods.any((m) => m.code != 'wallet')) ...[
                      const SizedBox(height: 8),
                      const Text('رقم العملية / المرجع', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(controller: _refCtrl, decoration: const InputDecoration(hintText: 'رقم عملية التحويل')),
                      const SizedBox(height: 12),
                      const Text('اسم المُحوِّل (اختياري)', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(controller: _senderCtrl, decoration: const InputDecoration(hintText: 'الاسم الذي حوّلت منه')),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submitManual,
                          child: _submitting
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('إرسال إثبات الدفع'),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _manualTile(PaymentMethod m) {
    final selected = _selectedManual?.id == m.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedManual = m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange.withValues(alpha: 0.09) : AppColors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? AppColors.orange : AppColors.line, width: selected ? 1.8 : 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(gradient: AppColors.royalGradient, borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(m.name, style: AppTheme.display.copyWith(fontSize: 15.5))),
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? AppColors.orange : AppColors.muted),
              ],
            ),
            if (selected && (m.instructions != null || m.accountNumber != null)) ...[
              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.line)),
              if (m.instructions != null)
                Text(m.instructions!, style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6)),
              if (m.accountNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Text('الرقم: ', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    SelectableText(m.accountNumber!, style: AppTheme.display.copyWith(fontSize: 14)),
                  ]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

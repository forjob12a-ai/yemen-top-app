import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/payment_method.dart';
import '../../services/payment_service.dart';
import '../../services/wallet_service.dart';
import '../../services/api_client.dart';
import '../../widgets/common.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({super.key});
  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final _wallet = WalletService();
  final _payment = PaymentService();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _senderCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<PaymentMethod> _methods = [];
  PaymentMethod? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose(); _refCtrl.dispose(); _senderCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _methods = (await _payment.methods()).where((m) => m.code != 'wallet').toList();
      _selected = _methods.isNotEmpty ? _methods.first : null;
    } catch (_) {
      _error = 'تعذّر تحميل طرق الدفع.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount < 100) { _snack('أدخل مبلغاً صحيحاً (100 ريال فأكثر)'); return; }
    if (_selected == null) { _snack('اختر وسيلة التحويل'); return; }
    if (_refCtrl.text.trim().isEmpty) { _snack('أدخل رقم العملية'); return; }
    setState(() => _submitting = true);
    try {
      await _wallet.topup(
        amount: amount,
        methodId: _selected!.id,
        transactionRef: _refCtrl.text.trim(),
        senderName: _senderCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استلام طلب الشحن! سيُضاف الرصيد بعد المراجعة.'), backgroundColor: AppColors.good));
      Navigator.pop(context);
    } on ApiException catch (e) {
      _snack(e.firstError);
    } catch (_) {
      _snack('تعذّر إرسال الطلب');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.bad));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شحن المحفظة')),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('المبلغ', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTheme.display.copyWith(fontSize: 18),
                      decoration: const InputDecoration(hintText: '0', prefixText: '﷼ '),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9, runSpacing: 9,
                      children: [5000, 10000, 25000, 50000].map((a) => ActionChip(
                        label: Text(money(a).replaceAll(' ﷼', '')),
                        onPressed: () => _amountCtrl.text = a.toString(),
                        backgroundColor: AppColors.card,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), side: BorderSide(color: AppColors.line)),
                      )).toList(),
                    ),
                    const SizedBox(height: 22),
                    Text('وسيلة التحويل', style: AppTheme.display.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    ..._methods.map(_methodTile),
                    const SizedBox(height: 12),
                    const Text('رقم العملية / المرجع', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(controller: _refCtrl, decoration: const InputDecoration(hintText: 'رقم عملية التحويل')),
                    const SizedBox(height: 12),
                    const Text('اسم المُحوِّل (اختياري)', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(controller: _senderCtrl, decoration: const InputDecoration(hintText: 'اختياري')),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('إرسال طلب الشحن'),
                    ),
                  ],
                ),
    );
  }

  Widget _methodTile(PaymentMethod m) {
    final selected = _selected?.id == m.id;
    return GestureDetector(
      onTap: () => setState(() => _selected = m),
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
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(gradient: AppColors.royalGradient, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(m.name, style: AppTheme.display.copyWith(fontSize: 15.5))),
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? AppColors.orange : AppColors.muted),
            ]),
            if (selected && m.accountNumber != null) ...[
              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.line)),
              Row(children: [
                Text('الرقم: ', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                SelectableText(m.accountNumber!, style: AppTheme.display.copyWith(fontSize: 14)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

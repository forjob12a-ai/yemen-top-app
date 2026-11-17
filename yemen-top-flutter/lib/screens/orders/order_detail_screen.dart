import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/order_service.dart';
import '../../widgets/common.dart';
import '../payment/payment_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _service = OrderService();
  bool _loading = true;
  String? _error;
  Order? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _order = await _service.show(widget.orderId);
    } catch (_) {
      _error = 'تعذّر تحميل الطلب.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// نسخ الكود المسلَّم، و«تم النسخ» تظهر فقط بعد نجاح النسخ (مثل الموقع)
  Future<void> _copy(String text) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(SnackBar(content: const Text('تم النسخ'), backgroundColor: AppColors.good));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: const Text('تعذّر النسخ، انسخه يدوياً'), backgroundColor: AppColors.bad));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final o = _order!;
    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o.orderNumber, style: AppTheme.display.copyWith(fontSize: 18)),
                    Text(money(o.total), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 18)),
                  ],
                ),
                if (o.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text('بتاريخ ${localTime(o.createdAt)}', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                ],
                if (o.discount > 0) ...[
                  const SizedBox(height: 6),
                  Text('خصم${o.couponCode != null ? ' (${o.couponCode})' : ''}: ${money(o.discount)}',
                      style: TextStyle(color: AppColors.good, fontSize: 12.5, fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  StatusBadge(o.statusLabel, statusColor(o.status)),
                  const SizedBox(width: 8),
                  StatusBadge(o.paymentLabel, statusColor(o.paymentStatus)),
                ]),
              ],
            ),
          ),
          if (o.isPayable) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PaymentScreen(order: o))).then((_) => _load()),
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('ادفع الآن'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text('عناصر الطلب', style: AppTheme.display.copyWith(fontSize: 16)),
          const SizedBox(height: 10),
          ...o.items.map(_itemTile),
          if (o.timeline.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('تتبع الطلب', style: AppTheme.display.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            _timeline(o.timeline),
          ],
        ],
      ),
    );
  }

  Widget _itemTile(OrderItem item) {
    final code = item.status == 'delivered' ? item.deliveredData : null;
    final amount = item.units != null ? 'العدد: ${item.units}' : 'الكمية: ${item.quantity}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.navy, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('${item.productName} — ${item.packageName}', style: AppTheme.display.copyWith(fontSize: 14.5))),
              StatusBadge(item.statusLabel, statusColor(item.status)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('$amount${item.playerId != null ? ' · المعرّف: ${item.playerId}' : ''}',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ),
              Text(money(item.total), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          if (code != null && code.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 6, 12),
              decoration: BoxDecoration(
                  color: AppColors.good.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان وزر النسخ في سطر، والكود تحتهما (مثل صفحة الطلب في الموقع)
                  Row(
                    children: [
                      Expanded(
                        child: Text('الكود / التسليم:',
                            style: TextStyle(color: AppColors.good, fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () => _copy(code),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('نسخ'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.good,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  SelectableText(code,
                      textDirection: TextDirection.ltr,
                      style: AppTheme.display.copyWith(fontSize: 15)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// خط تتبع الطلب: كل تغيّر في الحالة أو الدفع بوقته بتوقيت اليمن، والأحدث في الأسفل
  Widget _timeline(List<OrderTimelineEntry> entries) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
          color: AppColors.navy, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            _timelineRow(entries[i], last: i == entries.length - 1),
        ],
      ),
    );
  }

  Widget _timelineRow(OrderTimelineEntry e, {required bool last}) {
    final color = e.toStatus != null ? statusColor(e.toStatus!) : AppColors.link;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: last ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                if (!last)
                  Expanded(child: Container(width: 2, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.label,
                      style: TextStyle(
                          color: AppColors.text, fontSize: 13.5, fontWeight: last ? FontWeight.w800 : FontWeight.w600)),
                  if (e.at != null) ...[
                    const SizedBox(height: 2),
                    Text(localTime(e.at),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

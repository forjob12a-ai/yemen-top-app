import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o.orderNumber, style: AppTheme.display.copyWith(fontSize: 18)),
                  Text(money(o.total), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 18)),
                ],
              ),
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
      ],
    );
  }

  Widget _itemTile(item) => Container(
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
                Text('الكمية: ${item.quantity}${item.playerId != null ? ' · المعرّف: ${item.playerId}' : ''}',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                Text(money(item.total), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            if (item.deliveredData != null && item.status == 'delivered') ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.good.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الكود / التسليم:', style: TextStyle(color: AppColors.good, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(height: 4),
                    SelectableText(item.deliveredData!, style: AppTheme.display.copyWith(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}

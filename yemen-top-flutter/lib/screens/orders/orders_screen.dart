import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/common.dart';
import '../../widgets/auth_required.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _service = OrderService();
  bool _loading = false;
  String? _error;
  List<Order> _orders = [];
  bool _loadedFor = false;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _orders = await _service.myOrders();
    } catch (_) {
      _error = 'تعذّر تحميل الطلبات.';
    } finally {
      if (mounted) setState(() { _loading = false; _loadedFor = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthProvider>().isAuthenticated;
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي'), automaticallyImplyLeading: false),
      body: !authed
          ? const AuthRequiredView(message: 'سجّل الدخول لعرض طلباتك.')
          : Builder(builder: (context) {
              if (!_loadedFor && !_loading) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              if (_loading) return const LoadingView();
              if (_error != null) return ErrorView(message: _error!, onRetry: _load);
              if (_orders.isEmpty) {
                return const EmptyView(icon: Icons.receipt_long_outlined, title: 'لا توجد طلبات بعد', subtitle: 'ابدأ أول عملية شحن.');
              }
              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _orderTile(_orders[i]),
                ),
              );
            }),
    );
  }

  Widget _orderTile(Order o) => InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.navy, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o.orderNumber, style: AppTheme.display.copyWith(fontSize: 15)),
                  Text(money(o.total), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusBadge(o.statusLabel, statusColor(o.status)),
                  const SizedBox(width: 8),
                  StatusBadge(o.paymentLabel, statusColor(o.paymentStatus)),
                  const Spacer(),
                  Text('${o.itemsCount} عنصر', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      );
}

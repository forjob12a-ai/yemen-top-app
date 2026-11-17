import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/common.dart';
import '../../widgets/auth_required.dart';
import '../orders/order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  bool _loading = true;
  String? _error;
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    if (context.read<AuthProvider>().isAuthenticated) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await _service.list();
    } catch (_) {
      _error = 'تعذّر تحميل الإشعارات.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    try {
      await _service.markAllRead();
      _load();
    } catch (_) {}
  }

  Future<void> _open(AppNotification n) async {
    if (!n.isRead) {
      try { await _service.markRead(n.id); } catch (_) {}
    }
    final orderId = n.data['order_id'];
    if (orderId != null && mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId is int ? orderId : int.tryParse('$orderId') ?? 0)));
    } else {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthProvider>().isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (authed && _items.isNotEmpty)
            TextButton(onPressed: _markAll, child: const Text('تعليم الكل', style: TextStyle(color: AppColors.orange))),
        ],
      ),
      body: !authed
          ? const AuthRequiredView(message: 'سجّل الدخول لعرض إشعاراتك.')
          : _loading
              ? const LoadingView()
              : _error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : _items.isEmpty
                      ? const EmptyView(icon: Icons.notifications_none, title: 'لا توجد إشعارات', subtitle: 'ستظهر هنا تحديثات طلباتك وعروضنا.')
                      : RefreshIndicator(
                          color: AppColors.orange,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _tile(_items[i]),
                          ),
                        ),
    );
  }

  Widget _tile(AppNotification n) {
    final isOrder = n.kind == 'order';
    return InkWell(
      onTap: () => _open(n),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.navy : AppColors.orange.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: n.isRead ? AppColors.line : AppColors.orange.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  gradient: isOrder ? AppColors.royalGradient : AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(isOrder ? Icons.shopping_bag_outlined : Icons.campaign_outlined, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title ?? 'إشعار', style: AppTheme.display.copyWith(fontSize: 15)),
                  if (n.body != null) ...[
                    const SizedBox(height: 3),
                    Text(n.body!, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
                  ],
                ],
              ),
            ),
            if (!n.isRead)
              Container(width: 9, height: 9, margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/wallet_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../services/wallet_service.dart';
import '../../widgets/common.dart';
import '../../widgets/auth_required.dart';
import 'topup_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _service = WalletService();
  bool _loading = false;
  String? _error;
  double _balance = 0;
  List<WalletTransaction> _txs = [];
  bool _loaded = false;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.wallet();
      _balance = data.balance;
      _txs = data.transactions;
    } catch (_) {
      _error = 'تعذّر تحميل المحفظة.';
    } finally {
      if (mounted) setState(() { _loading = false; _loaded = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthProvider>().isAuthenticated;
    return Scaffold(
      appBar: AppBar(title: const Text('محفظتي'), automaticallyImplyLeading: false),
      body: !authed
          ? const AuthRequiredView(message: 'سجّل الدخول للوصول إلى محفظتك.')
          : Builder(builder: (context) {
              if (!_loaded && !_loading) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              if (_loading) return const LoadingView();
              if (_error != null) return ErrorView(message: _error!, onRetry: _load);
              return RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GradientBox(
                      gradient: AppColors.walletGradient,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(money(_balance), style: AppTheme.display.copyWith(color: Colors.white, fontSize: 34)),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const TopupScreen()));
                              _load();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy3),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('شحن المحفظة'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('سجل الحركات', style: AppTheme.display.copyWith(fontSize: 16)),
                    const SizedBox(height: 12),
                    if (_txs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: EmptyView(icon: Icons.swap_vert, title: 'لا توجد حركات بعد', subtitle: 'ستظهر عملياتك هنا.'),
                      )
                    else
                      ..._txs.map(_txTile),
                  ],
                ),
              );
            }),
    );
  }

  Widget _txTile(WalletTransaction t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.navy, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (t.isCredit ? AppColors.good : AppColors.bad).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(t.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: t.isCredit ? AppColors.good : AppColors.bad, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.typeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (t.description != null)
                    Text(t.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            Text('${t.isCredit ? '+' : '−'}${money(t.amount)}',
                style: TextStyle(color: t.isCredit ? AppColors.good : AppColors.bad, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

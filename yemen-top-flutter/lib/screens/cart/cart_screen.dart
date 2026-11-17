import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common.dart';
import '../auth/login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      if (ok != true) return;
    }
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      body: cart.isEmpty
          ? EmptyView(
              icon: Icons.shopping_cart_outlined,
              title: 'السلة فارغة',
              subtitle: 'لم تُضِف أي منتج بعد.',
              action: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('تصفّح المنتجات')),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CartTile(item: cart.items[i]),
                  ),
                ),
                _summary(context, cart),
              ],
            ),
    );
  }

  Widget _summary(BuildContext context, CartProvider cart) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.navy,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الإجمالي (${0} قطعة)', style: TextStyle(color: AppColors.muted)),
                  Text(money(cart.subtotal), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkout(context),
                  child: const Text('متابعة لإتمام الطلب'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CartTile extends StatelessWidget {
  final dynamic item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(gradient: AppColors.royalGradient, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(item.productName.isNotEmpty ? item.productName[0] : '?',
                style: AppTheme.display.copyWith(color: Colors.white, fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: AppTheme.display.copyWith(fontSize: 15)),
                Text(item.packageName, style: TextStyle(color: AppColors.muted, fontSize: 13)),
                if (item.playerId != null)
                  Text('${item.playerIdLabel ?? 'المعرّف'}: ${item.playerId}',
                      style: const TextStyle(color: AppColors.royal, fontSize: 12)),
                const SizedBox(height: 4),
                Text(money(item.total), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _qtyBtn(Icons.remove, () => cart.updateQty(item, item.qty - 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${item.qty}', style: AppTheme.display.copyWith(fontSize: 15)),
                  ),
                  _qtyBtn(Icons.add, () => cart.updateQty(item, item.qty + 1)),
                ],
              ),
              TextButton.icon(
                onPressed: () => cart.remove(item),
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.bad),
                label: const Text('حذف', style: TextStyle(color: AppColors.bad, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../screens/cart/cart_screen.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
        if (count > 0)
          Positioned(
            right: 6, top: 6,
            // الشارة لا تبتلع الضغطة: الضغط عليها يفتح السلة مثل الأيقونة
            child: IgnorePointer(
              child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                  color: AppColors.orange, borderRadius: BorderRadius.circular(10)),
              child: Text('$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}

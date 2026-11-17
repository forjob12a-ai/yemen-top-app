// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_config_provider.dart';
import '../../widgets/whatsapp_button.dart';
import 'home_screen.dart';
import '../catalog/products_screen.dart';
import '../orders/orders_screen.dart';
import '../favorites/favorites_screen.dart';
import '../account/profile_screen.dart';

/// الشريط السفلي مثل الموقع: الرئيسية، المتجر، الطلبات، المفضّلة، حسابي.
/// «الطلبات» مكان «العروض»، والعروض من رابط «عرض الكل» في الرئيسية.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _ordersTab = 2;
  int _index = 0;

  /// يزيد مع كل فتح لتبويب الطلبات، فتُحمَّل القائمة من جديد في كل مرة
  /// (بعد طلب جديد، أو بحساب آخر بعد الخروج والدخول)، ولا تُحمَّل قبل أول فتح.
  int _ordersVisit = 0;

  void _select(int i) {
    setState(() {
      if (i == _ordersTab && _index != _ordersTab) _ordersVisit++;
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    // الاشتراك بإعدادات التطبيق: عند تغيير العملة تُعاد بناء كل التبويبات بالعملة الجديدة.
    context.watch<AppConfigProvider>();

    // نتركها بدون const عمداً حتى تُعاد بناء الأسعار عند تغيير العملة (مع الحفاظ على حالة كل تبويب).
    final pages = <Widget>[
      HomeScreen(),
      ProductsScreen(),
      _ordersVisit == 0
          ? const SizedBox.shrink()
          : OrdersScreen(key: ValueKey(_ordersVisit)),
      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: const WhatsappButton(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // خط لوني رفيع أعلى الشريط (أزرق ثم أخضر) كما في الموقع
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0x0029B6F6),
                Color(0xB329B6F6),
                Color(0xB34CAF50),
                Color(0x004CAF50),
              ]),
            ),
          ),
          // الألوان من navigationBarTheme في AppTheme: كحلي، والنشط أخضر داخل كبسولة
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
              NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'المتجر'),
              NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'الطلبات'),
              NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'المفضّلة'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
            ],
          ),
        ],
      ),
    );
  }
}

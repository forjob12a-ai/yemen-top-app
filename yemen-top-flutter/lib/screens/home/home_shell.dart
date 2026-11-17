// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_config_provider.dart';
import '../../widgets/whatsapp_button.dart';
import 'home_screen.dart';
import '../catalog/products_screen.dart';
import '../offers/offers_screen.dart';
import '../favorites/favorites_screen.dart';
import '../account/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // ط§ظ„ط§ط´طھط±ط§ظƒ ط¨ط¥ط¹ط¯ط§ط¯ط§طھ ط§ظ„طھط·ط¨ظٹظ‚: ط¹ظ†ط¯ طھط؛ظٹظٹط± ط§ظ„ط¹ظ…ظ„ط© طھظڈط¹ط§ط¯ ط¨ظ†ط§ط، ظƒظ„ ط§ظ„طھط¨ظˆظٹط¨ط§طھ ط¨ط§ظ„ط¹ظ…ظ„ط© ط§ظ„ط¬ط¯ظٹط¯ط©.
    context.watch<AppConfigProvider>();

    // ظ†طھط±ظƒظ‡ط§ ط¨ط¯ظˆظ† const ط¹ظ…ط¯ط§ظ‹ ط­طھظ‰ طھظڈط¹ط§ط¯ ط¨ظ†ط§ط، ط§ظ„ط£ط³ط¹ط§ط± ط¹ظ†ط¯ طھط؛ظٹظٹط± ط§ظ„ط¹ظ…ظ„ط© (ظ…ط¹ ط§ظ„ط­ظپط§ط¸ ط¹ظ„ظ‰ ط­ط§ظ„ط© ظƒظ„ طھط¨ظˆظٹط¨).
    final pages = [
      HomeScreen(),
      ProductsScreen(),
      OffersScreen(),
      FavoritesScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: const WhatsappButton(),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.navy,
          indicatorColor: AppColors.orange.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.all(
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.orange), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view, color: AppColors.orange), label: 'المتجر'),
            NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer, color: AppColors.orange), label: 'العروض'),
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite, color: AppColors.orange), label: 'المفضّلة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.orange), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}







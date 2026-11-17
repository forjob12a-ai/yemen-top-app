// شاشة المفضّلة — تصميم جسر المعلومات
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../services/catalog_service.dart';
import '../catalog/product_detail_screen.dart';
import '../auth/login_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _catalog = CatalogService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Product>> _load() async {
    if (!ApiClient.instance.isAuthenticated) return [];
    return _catalog.favorites();
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضّلة')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (!ApiClient.instance.isAuthenticated) {
              return _centered(
                icon: Icons.lock_outline,
                text: 'سجّل الدخول لعرض قائمة مفضّلتك',
                action: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('تسجيل الدخول'),
                ),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _centered(
                  icon: Icons.wifi_off,
                  text: 'تعذّر جلب المفضّلة — اسحب للأسفل للمحاولة');
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return _centered(
                  icon: Icons.favorite_border,
                  text: 'قائمة المفضّلة فارغة — أضف ما يعجبك بالضغط على القلب');
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _favCard(items[i]),
            );
          },
        ),
      ),
    );
  }

  Widget _favCard(Product p) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: p.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 92,
              height: 92,
              child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                  ? Image.network(p.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0x22FE7A39),
                          child: Icon(Icons.image, color: AppColors.orange)))
                  : const ColoredBox(
                      color: Color(0x22FE7A39),
                      child: Icon(Icons.videogame_asset, color: AppColors.orange)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    if (p.priceFrom != null)
                      Text('يبدأ من ${p.priceFrom!.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.orange)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(Icons.chevron_left, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centered({required IconData icon, required String text, Widget? action}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: AppColors.orange),
        const SizedBox(height: 14),
        Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(text, textAlign: TextAlign.center),
        )),
        if (action != null) ...[
          const SizedBox(height: 18),
          Center(child: action),
        ],
      ],
    );
  }
}

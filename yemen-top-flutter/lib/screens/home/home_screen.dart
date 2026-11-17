import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/offer.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import '../../widgets/cart_button.dart';
import '../catalog/products_screen.dart';
import '../catalog/product_detail_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _catalog = CatalogService();
  bool _loading = true;
  String? _error;
  List<Category> _categories = [];
  List<Offer> _offers = [];
  List<Product> _featured = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _catalog.categories(),
        _catalog.offers(),
        _catalog.products(),
      ]);
      _categories = results[0] as List<Category>;
      _offers = results[1] as List<Offer>;
      final all = results[2] as List<Product>;
      _featured = all.where((p) => p.isFeatured).toList();
      if (_featured.isEmpty) _featured = all.take(6).toList();
    } catch (_) {
      _error = 'تعذّر تحميل البيانات. تحقّق من الاتصال.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('يمن توب'),
        leading: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
        actions: const [CartButton()],
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  color: AppColors.orange,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _hero(),
                      const SizedBox(height: 22),
                      _sectionTitle('الأقسام'),
                      const SizedBox(height: 12),
                      _categoriesRow(),
                      if (_offers.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('العروض الخاصة 🔥'),
                        const SizedBox(height: 12),
                        _offersRow(),
                      ],
                      const SizedBox(height: 24),
                      _sectionTitle('منتجات مميّزة'),
                      const SizedBox(height: 12),
                      _featuredGrid(),
                    ],
                  ),
                ),
    );
  }

  Widget _hero() => GradientBox(
        gradient: AppColors.walletGradient,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اشحن ألعابك بأمان وسرعة',
                style: AppTheme.display.copyWith(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('بطاقات وشحن مباشر بأسعار بالريال اليمني.',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy3),
              child: const Text('تصفّح المتجر'),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String t) => Text(t, style: AppTheme.display.copyWith(fontSize: 18));

  Widget _categoriesRow() => SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final c = _categories[i];
            return InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductsScreen(categorySlug: c.slug, title: c.name))),
              child: Container(
                width: 92,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(gradient: AppColors.orangeGradient, borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.category_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _offersRow() => SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _offers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final o = _offers[i];
            return Container(
              width: 280,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  o.imageUrl != null
                      ? CachedNetworkImage(imageUrl: o.imageUrl!, fit: BoxFit.cover)
                      : Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (o.discountPercentage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.good, borderRadius: BorderRadius.circular(20)),
                            child: Text('خصم ${o.discountPercentage!.toInt()}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        const SizedBox(height: 8),
                        Text(o.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: AppTheme.display.copyWith(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _featuredGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _featured.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.74,
        ),
        itemBuilder: (_, i) => ProductCard(
          product: _featured[i],
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: _featured[i].slug))),
        ),
      );
}

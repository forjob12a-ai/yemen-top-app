import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? categorySlug;
  final String? title;
  const ProductsScreen({super.key, this.categorySlug, this.title});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _catalog = CatalogService();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Category> _categories = [];
  List<Product> _products = [];
  String? _activeSlug;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _activeSlug = widget.categorySlug;
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_categories.isEmpty) _categories = await _catalog.categories();
      _products = await _catalog.products(categorySlug: _activeSlug, search: _search);
    } catch (_) {
      _error = 'تعذّر تحميل المنتجات.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'المتجر')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) { _search = v.trim(); _load(); },
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: Icon(Icons.search, color: AppColors.muted),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.muted),
                        onPressed: () { _searchCtrl.clear(); _search = ''; _load(); })
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('الكل', null),
                ..._categories.map((c) => _chip(c.name, c.slug)),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _products.isEmpty
                        ? const EmptyView(icon: Icons.search_off, title: 'لا توجد نتائج', subtitle: 'جرّب كلمة بحث أخرى أو قسماً آخر.')
                        : RefreshIndicator(
                            color: AppColors.orange,
                            onRefresh: _load,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _products.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.74,
                              ),
                              itemBuilder: (_, i) => ProductCard(
                                product: _products[i],
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => ProductDetailScreen(slug: _products[i].slug))),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? slug) {
    final active = _activeSlug == slug;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) { setState(() => _activeSlug = slug); _load(); },
        backgroundColor: AppColors.card,
        selectedColor: AppColors.orange,
        labelStyle: TextStyle(
            color: active ? Colors.white : AppColors.muted, fontWeight: FontWeight.w700, fontSize: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), side: BorderSide(color: AppColors.line)),
      ),
    );
  }
}

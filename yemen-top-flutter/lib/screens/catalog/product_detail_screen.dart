import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../models/package.dart';
import '../../services/catalog_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/cart_button.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _catalog = CatalogService();
  final _playerCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  Product? _product;
  Package? _selected;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _playerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _product = await _catalog.product(widget.slug);
      final inStock = _product!.packages.where((p) => p.inStock).toList();
      _selected = inStock.isNotEmpty ? inStock.first : null;
    } catch (_) {
      _error = 'تعذّر تحميل المنتج.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addToCart() {
    final p = _product!;
    if (_selected == null) {
      _snack('اختر باقة أولاً', AppColors.bad);
      return;
    }
    if (p.requiresPlayerId && _playerCtrl.text.trim().isEmpty) {
      _snack('أدخل ${p.playerIdLabel ?? 'معرف اللاعب'}', AppColors.bad);
      return;
    }
    context.read<CartProvider>().add(p, _selected!,
        qty: _qty, playerId: p.requiresPlayerId ? _playerCtrl.text.trim() : null);
    _snack('تمت الإضافة إلى السلة 🛒', AppColors.good);
  }

  void _snack(String m, Color c) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج'), actions: const [CartButton()]),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _buildBody(),
      bottomNavigationBar: (_loading || _error != null || _product == null) ? null : _bottomBar(),
    );
  }

  Widget _buildBody() {
    final p = _product!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.royalGradient),
              child: p.imageUrl != null
                  ? CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.sports_esports, color: Colors.white70, size: 60)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (p.category != null)
          Text(p.category!.name, style: const TextStyle(color: AppColors.royal, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(p.name, style: AppTheme.display.copyWith(fontSize: 22)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _tag(Icons.check_circle_outline, p.deliveryLabel),
          _tag(Icons.shield_outlined, 'دفع آمن'),
          if (p.requiresPlayerId) _tag(Icons.person_outline, 'يتطلب معرف اللاعب'),
        ]),
        if (p.description != null) ...[
          const SizedBox(height: 14),
          Text(p.description!, style: const TextStyle(color: AppColors.muted, height: 1.7)),
        ],
        const SizedBox(height: 20),
        if (p.requiresPlayerId) ...[
          Text(p.playerIdLabel ?? 'معرف اللاعب (ID)', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _playerCtrl,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(hintText: 'أدخل المعرّف كما يظهر داخل اللعبة'),
          ),
          const SizedBox(height: 20),
        ],
        Text('اختر الباقة', style: AppTheme.display.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        ...p.packages.map(_packageTile),
      ],
    );
  }

  Widget _tag(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: AppColors.good),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ]),
      );

  Widget _packageTile(Package pkg) {
    final selected = _selected?.id == pkg.id;
    final out = !pkg.inStock;
    return Opacity(
      opacity: out ? 0.5 : 1,
      child: GestureDetector(
        onTap: out ? null : () => setState(() => _selected = pkg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.orange.withValues(alpha: 0.1) : AppColors.card,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? AppColors.orange : AppColors.line, width: selected ? 1.8 : 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pkg.name, style: AppTheme.display.copyWith(fontSize: 15.5)),
                    if (out) const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text('غير متوفّر حالياً', style: TextStyle(color: AppColors.bad, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(money(pkg.price), style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 16)),
                  if (pkg.hasDiscount && pkg.originalPrice != null)
                    Text(money(pkg.originalPrice!),
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11.5, decoration: TextDecoration.lineThrough)),
                ],
              ),
              if (pkg.hasDiscount) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.good, borderRadius: BorderRadius.circular(20)),
                  child: Text('-${pkg.discountPercent}%',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final price = _selected?.price ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // عدّاد الكمية
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
              child: Row(
                children: [
                  IconButton(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 99)), icon: const Icon(Icons.remove)),
                  Text('$_qty', style: AppTheme.display.copyWith(fontSize: 16)),
                  IconButton(onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, 99)), icon: const Icon(Icons.add)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: Text('أضف للسلة · ${money(price * _qty)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../services/catalog_service.dart';
import 'common.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _catalog = CatalogService();
  late bool _fav = widget.isFavorite;
  bool _busy = false;

  @override
  void didUpdateWidget(ProductCard old) {
    super.didUpdateWidget(old);
    if (old.isFavorite != widget.isFavorite) _fav = widget.isFavorite;
  }

  Future<void> _toggle() async {
    if (_busy) return;
    if (!ApiClient.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل الدخول لإضافة المفضّلة')),
      );
      return;
    }
    setState(() { _busy = true; _fav = !_fav; }); // تحديث فوري متفائل
    try {
      final status = await _catalog.toggleFavorite(widget.product.slug);
      final nowFav = status == 'added';
      if (mounted) setState(() => _fav = nowFav);
      widget.onFavoriteChanged?.call(nowFav);
    } catch (_) {
      if (mounted) setState(() => _fav = !_fav); // تراجع عند الخطأ
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductArt(imageUrl: p.imageUrl),
                  if (p.isFeatured)
                    Positioned(
                      top: 10, right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text('مميّز',
                            style: TextStyle(color: AppColors.onAccent, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  Positioned(
                    top: 8, left: 8,
                    child: Material(
                      color: Colors.black26,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _toggle,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _fav ? Icons.favorite : Icons.favorite_border,
                            color: _fav ? AppColors.orange : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.category != null)
                    Text(p.category!.name,
                        style: const TextStyle(color: AppColors.royal, fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(p.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: AppTheme.display.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('يبدأ من', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                            Text(p.priceFrom != null ? money(p.priceFrom!) : '—',
                                style: AppTheme.display.copyWith(color: AppColors.gold, fontSize: 15)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text('اطلب',
                            style: TextStyle(color: AppColors.onAccent, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// صورة المنتج كما في الموقع: الصورة كاملة فوق نسخة مموّهة منها تملأ الإطار،
/// فلا تُقص الصور المربعة ولا القديمة بنسبة 3:2. بلا صورة: خلفية زرقاء وأيقونة.
class ProductArt extends StatelessWidget {
  final String? imageUrl;
  final double iconSize;
  const ProductArt({super.key, this.imageUrl, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null) {
      return Container(
        decoration: const BoxDecoration(gradient: AppColors.royalGradient),
        child: Center(child: Icon(Icons.sports_esports, color: Colors.white70, size: iconSize)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: AppColors.navy3),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: 0.12)),
        CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
      ],
    );
  }
}

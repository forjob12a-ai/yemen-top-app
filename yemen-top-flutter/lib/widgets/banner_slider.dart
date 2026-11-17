import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/app_banner.dart';
import '../../services/catalog_service.dart';

/// سلايدر البانرات في الصفحة الرئيسية.
/// يجيب البانرات من الـ API؛ ولو ما فيه بانرات يعرض شرائح تجريبية بتدرّجات
/// (نفس منطق الموقع). تحرّك تلقائي كل 4 ثوانٍ + سحب يدوي + نقاط مؤشّر.
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});
  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

/// شريحة تجريبية تظهر فقط عند غياب البانرات الحقيقية.
class _DemoSlide {
  final String title;
  final String subtitle;
  final Gradient gradient;
  const _DemoSlide(this.title, this.subtitle, this.gradient);
}

class _BannerSliderState extends State<BannerSlider> {
  final _catalog = CatalogService();
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  List<AppBanner> _banners = [];
  bool _loading = true;

  static final List<_DemoSlide> _demo = [
    _DemoSlide('اشحن ببجي موبايل', 'شحن فوري وآمن بأسعار بالريال اليمني',
        AppColors.orangeGradient),
    _DemoSlide('فري فاير', 'جواهر وعروض حصرية بأفضل الأسعار',
        AppColors.royalGradient),
    _DemoSlide('بطاقات بلايستيشن', 'PlayStation · Steam · Google Play',
        AppColors.walletGradient),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final b = await _catalog.banners();
      if (mounted) setState(() { _banners = b; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
    _startAuto();
  }

  void _startAuto() {
    _timer?.cancel();
    final count = _slideCount;
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % count;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  int get _slideCount => _banners.isNotEmpty ? _banners.length : _demo.length;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: MediaQuery.of(context).size.width * 0.92 * 9 / 16,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
            child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }

    final count = _slideCount;
    final slideWidth = MediaQuery.of(context).size.width * 0.92;
    final height = slideWidth * 9 / 16;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _banners.isNotEmpty
                  ? _realSlide(_banners[i])
                  : _demoSlide(_demo[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _dots(count),
      ],
    );
  }

  Widget _dots(int count) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == _page;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? AppColors.orange : AppColors.line,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );

  Widget _realSlide(AppBanner b) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (b.imageUrl != null)
              CachedNetworkImage(
                imageUrl: b.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.navy),
                errorWidget: (_, __, ___) => Container(
                  decoration:
                      BoxDecoration(gradient: AppColors.orangeGradient),
                ),
              )
            else
              Container(
                  decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient)),
            if (b.title != null || b.subtitle != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75)
                    ],
                  ),
                ),
              ),
            if (b.title != null || b.subtitle != null)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (b.title != null)
                      Text(b.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.display.copyWith(
                              color: Colors.white, fontSize: 19)),
                    if (b.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(b.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _demoSlide(_DemoSlide s) => Container(
        decoration: BoxDecoration(
          gradient: s.gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.title,
                style: AppTheme.display
                    .copyWith(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 8),
            Text(s.subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      );
}
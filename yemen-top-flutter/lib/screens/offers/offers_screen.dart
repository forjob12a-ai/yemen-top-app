// شاشة العروض — تصميم جسر المعلومات (تحاكي صفحة العروض في الموقع)
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/offer.dart';
import '../../services/catalog_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _catalog = CatalogService();
  late Future<List<Offer>> _future;

  @override
  void initState() {
    super.initState();
    _future = _catalog.offers();
  }

  Future<void> _reload() async {
    setState(() => _future = _catalog.offers());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Offer>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.wifi_off, size: 56, color: AppColors.orange),
                  const SizedBox(height: 12),
                  const Center(child: Text('تعذّر جلب العروض — اسحب للأسفل للمحاولة مجدداً')),
                ],
              );
            }
            final offers = snap.data ?? [];
            if (offers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.local_offer_outlined, size: 56, color: AppColors.orange),
                  const SizedBox(height: 12),
                  const Center(child: Text('لا توجد عروض حالياً — ترقّبونا 🔥')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = offers[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (o.imageUrl != null && o.imageUrl!.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            o.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: AppColors.orange.withValues(alpha: 0.13),
                              child: Icon(Icons.local_offer, size: 48, color: AppColors.orange),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(o.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                ),
                                if (o.discountPercentage != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('خصم ${o.discountPercentage!.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                                  ),
                              ],
                            ),
                            if (o.description != null && o.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(o.description!,
                                  style: TextStyle(fontSize: 13, color: AppColors.text.withValues(alpha: 0.7))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
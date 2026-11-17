import 'category.dart';
import 'package.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? imageUrl;
  final String deliveryType;
  final String deliveryLabel;
  final bool requiresPlayerId;
  final String? playerIdLabel;
  final bool isFeatured;
  final double? priceFrom;
  final Category? category;
  final List<Package> packages;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    this.imageUrl,
    this.deliveryType = 'code',
    this.deliveryLabel = '',
    this.requiresPlayerId = false,
    this.playerIdLabel,
    this.isFeatured = false,
    this.priceFrom,
    this.category,
    this.packages = const [],
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        shortDescription: j['short_description'],
        description: j['description'],
        imageUrl: j['image_url'],
        deliveryType: j['delivery_type'] ?? 'code',
        deliveryLabel: j['delivery_label'] ?? '',
        requiresPlayerId: j['requires_player_id'] ?? false,
        playerIdLabel: j['player_id_label'],
        isFeatured: j['is_featured'] ?? false,
        priceFrom: j['price_from'] != null ? double.tryParse(j['price_from'].toString()) : null,
        category: j['category'] != null && j['category'] is Map
            ? Category.fromJson(j['category'])
            : null,
        packages: j['packages'] != null
            ? (j['packages'] as List).map((p) => Package.fromJson(p)).toList()
            : const [],
      );
}

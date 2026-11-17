class Package {
  final int id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final bool hasDiscount;
  final int discountPercent;
  final bool inStock;
  final String currency;
  Package({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.hasDiscount = false,
    this.discountPercent = 0,
    this.inStock = true,
    this.currency = 'YER',
  });
  factory Package.fromJson(Map<String, dynamic> j) => Package(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        price: double.tryParse((j['price'] ?? 0).toString()) ?? 0,
        originalPrice: j['original_price'] != null ? double.tryParse(j['original_price'].toString()) : null,
        hasDiscount: j['has_discount'] ?? false,
        discountPercent: j['discount_percent'] ?? 0,
        inStock: j['in_stock'] ?? true,
        currency: j['currency'] ?? 'YER',
      );
}

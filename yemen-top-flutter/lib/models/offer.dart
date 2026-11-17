class Offer {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final double? discountPercentage;
  final String? productSlug;
  final String? link;

  Offer({required this.id, required this.title, this.description, this.imageUrl,
    this.discountPercentage, this.productSlug, this.link});

  factory Offer.fromJson(Map<String, dynamic> j) => Offer(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'],
        imageUrl: j['image_url'],
        discountPercentage: j['discount_percentage'] != null ? (j['discount_percentage']).toDouble() : null,
        productSlug: j['product_slug'],
        link: j['link'],
      );
}

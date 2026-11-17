class Category {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;

  Category({required this.id, required this.name, required this.slug, this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'],
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        imageUrl: j['image_url'],
      );
}

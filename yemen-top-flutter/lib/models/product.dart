import 'category.dart';
import 'order_field.dart';
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

  /// حقول الطلب لكل باقة (package_fields في صفحة المنتج): رقم الباقة => الحقول
  final Map<int, List<OrderFieldDef>> packageFields;

  /// بيانات الشحن من آخر طلب للعميل لكل باقة (saved): رقم الباقة => {مفتاح: قيمة}
  final Map<int, Map<String, String>> savedFields;

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
    this.packageFields = const {},
    this.savedFields = const {},
  });

  /// الخادم أرسل حقول الطلب (صفحة المنتج): الفحص والإرسال بها بدل معرف اللاعب القديم
  bool get hasFieldSets => packageFields.isNotEmpty;

  List<OrderFieldDef> fieldsFor(int packageId) => packageFields[packageId] ?? const [];

  Map<String, String> savedFor(int packageId) => savedFields[packageId] ?? const {};

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
        packageFields: _fieldSets(j['package_fields']),
        savedFields: _savedSets(j['package_fields']),
      );

  static Map<int, List<OrderFieldDef>> _fieldSets(dynamic raw) {
    if (raw is! List) return const {};
    final out = <int, List<OrderFieldDef>>{};
    for (final s in raw.whereType<Map>()) {
      final id = int.tryParse('${s['package_id']}');
      if (id == null) continue;
      out[id] = s['fields'] is List
          ? (s['fields'] as List)
              .whereType<Map>()
              .map((f) => OrderFieldDef.fromJson(Map<String, dynamic>.from(f)))
              .toList()
          : const [];
    }
    return out;
  }

  /// saved كائن {مفتاح: قيمة}؛ القائمة الفارغة (خادم قديم) تُعامل كلا شيء
  static Map<int, Map<String, String>> _savedSets(dynamic raw) {
    if (raw is! List) return const {};
    final out = <int, Map<String, String>>{};
    for (final s in raw.whereType<Map>()) {
      final id = int.tryParse('${s['package_id']}');
      final saved = s['saved'];
      if (id == null || saved is! Map || saved.isEmpty) continue;
      out[id] = saved.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return out;
  }
}

import '../models/category.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../models/app_banner.dart';
import 'api_client.dart';

class CatalogService {
  final _api = ApiClient.instance;

  Future<List<Category>> categories() async {
    final res = await _api.get('categories');
    return (res['data'] as List).map((c) => Category.fromJson(c)).toList();
  }

  Future<List<Product>> products({String? categorySlug, String? search}) async {
    // quantity=1: التطبيق يدعم باقات الكمية (الكوينز)، فتظهر له مثل الموقع
    final res = await _api.get('products', query: {
      'quantity': 1,
      if (categorySlug != null) 'category': categorySlug,
      if (search != null && search.isNotEmpty) 'q': search,
    });
    return (res['data'] as List).map((p) => Product.fromJson(p)).toList();
  }

  Future<Product> product(String slug) async {
    final res = await _api.get('products/$slug', query: {'quantity': 1});
    return Product.fromJson(res['data'] ?? res);
  }

  /// سعر باقة الكمية لعدد معيّن من الخادم (محرك التسعير نفسه الذي يسعّر الطلب)؛
  /// عدد غير صالح يرجع ApiException برسالة الخادم
  Future<double> quote(int packageId, int units) async {
    final res = await _api.get('packages/$packageId/quote', query: {'units': units});
    return double.tryParse('${res['price']}') ?? 0;
  }

  Future<List<Offer>> offers() async {
    final res = await _api.get('offers');
    return (res['data'] as List).map((o) => Offer.fromJson(o)).toList();
  }

  Future<List<AppBanner>> banners() async {
    final res = await _api.get('banners');
    return (res['data'] as List).map((b) => AppBanner.fromJson(b)).toList();
  }
  // ===== المفضّلة (محمية بتوكن) =====
  Future<List<Product>> favorites() async {
    final res = await _api.get('favorites');
    return (res['data'] as List).map((p) => Product.fromJson(p)).toList();
  }
  Future<List<int>> favoriteIds() async {
    final res = await _api.get('favorites/ids');
    return (res['data'] as List).map((e) => e as int).toList();
  }
  Future<String> toggleFavorite(String slug) async {
    final res = await _api.post('favorites/$slug/toggle');
    return (res['status'] ?? '').toString();
  }
}

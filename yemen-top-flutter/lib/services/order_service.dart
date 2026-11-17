import '../models/order.dart';
import '../providers/cart_provider.dart';
import 'api_client.dart';

/// معاينة كود الخصم من الخادم قبل تأكيد الطلب (POST /api/coupons/check)
class CouponPreview {
  final String code;
  final double subtotal;
  final double discount;
  final double total;

  const CouponPreview({required this.code, required this.subtotal, required this.discount, required this.total});

  factory CouponPreview.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
    return CouponPreview(
      code: (j['coupon_code'] ?? '').toString(),
      subtotal: n(j['subtotal']),
      discount: n(j['discount']),
      total: n(j['total']),
    );
  }
}

class OrderService {
  final _api = ApiClient.instance;

  Future<List<Order>> myOrders() async {
    final res = await _api.get('orders');
    return (res['data'] as List).map((o) => Order.fromJson(o)).toList();
  }

  Future<Order> show(int id) async {
    final res = await _api.get('orders/$id');
    return Order.fromJson(res['data'] ?? res);
  }

  /// إتمام الشراء من عناصر السلة
  /// الخصم والإجمالي لعناصر السلة بالكود قبل إنشاء الطلب؛ لا يُنشئ طلباً ولا يحتسب استخداماً.
  /// كود غير صالح يرجع ApiException برسالة الخادم تحت coupon_code
  Future<CouponPreview> couponCheck(List<CartItem> items, String code) async {
    final res = await _api.post('coupons/check', {
      'coupon_code': code,
      'items': items
          .map((i) => {
                'package_id': i.packageId,
                'qty': i.isQuantity ? 1 : i.qty,
                if (i.units != null) 'units': i.units,
              })
          .toList(),
    });
    return CouponPreview.fromJson(Map<String, dynamic>.from(res as Map));
  }

  /// couponCode: كود الخصم (اختياري)؛ يُفحص ويُحسب الخصم في الخادم، والخطأ يعود تحت coupon_code
  Future<Order> checkout(List<CartItem> items, {String? note, String? couponCode}) async {
    final res = await _api.post('orders', {
      'items': items
          .map((i) => {
                'package_id': i.packageId,
                'qty': i.isQuantity ? 1 : i.qty,
                if (i.units != null) 'units': i.units,
                // حقول الطلب كما في الموقع؛ player_id القديم فقط لمنتج بلا حقول مربوطة
                if (i.fields.isNotEmpty) 'fields': i.fields,
                if (i.fields.isEmpty && i.playerId != null) 'player_id': i.playerId,
              })
          .toList(),
      if (note != null && note.isNotEmpty) 'note': note,
      if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
    });
    return Order.fromJson(res['data'] ?? res);
  }
}

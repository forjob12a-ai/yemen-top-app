import '../models/order.dart';
import '../providers/cart_provider.dart';
import 'api_client.dart';

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
  Future<Order> checkout(List<CartItem> items, {String? note}) async {
    final res = await _api.post('orders', {
      'items': items
          .map((i) => {
                'package_id': i.packageId,
                'qty': i.qty,
                // حقول الطلب كما في الموقع؛ player_id القديم فقط لمنتج بلا حقول مربوطة
                if (i.fields.isNotEmpty) 'fields': i.fields,
                if (i.fields.isEmpty && i.playerId != null) 'player_id': i.playerId,
              })
          .toList(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return Order.fromJson(res['data'] ?? res);
  }
}

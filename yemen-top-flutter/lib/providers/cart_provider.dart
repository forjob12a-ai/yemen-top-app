import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/package.dart';

class CartItem {
  final int packageId;
  final int productId;
  final String productName;
  final String packageName;
  final double unitPrice;
  final String? imageUrl;
  final String? playerId;
  final String? playerIdLabel;
  int qty;

  CartItem({
    required this.packageId,
    required this.productId,
    required this.productName,
    required this.packageName,
    required this.unitPrice,
    this.imageUrl,
    this.playerId,
    this.playerIdLabel,
    this.qty = 1,
  });

  double get total => unitPrice * qty;
  String get key => '$packageId-${playerId ?? ''}';
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold(0, (s, i) => s + i.qty);
  double get subtotal => _items.fold(0.0, (s, i) => s + i.total);

  void add(Product product, Package package, {int qty = 1, String? playerId}) {
    final key = '${package.id}-${playerId ?? ''}';
    final existing = _items.where((i) => i.key == key).toList();
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      _items.add(CartItem(
        packageId: package.id,
        productId: product.id,
        productName: product.name,
        packageName: package.name,
        unitPrice: package.price,
        imageUrl: product.imageUrl,
        playerId: playerId,
        playerIdLabel: product.playerIdLabel,
        qty: qty,
      ));
    }
    notifyListeners();
  }

  void updateQty(CartItem item, int qty) {
    if (qty <= 0) {
      _items.remove(item);
    } else {
      item.qty = qty.clamp(1, 99);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

import 'order_item.dart';

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentLabel;
  final double subtotal;
  final double discount;
  final double total;
  final String currency;
  final bool isPayable;
  final int itemsCount;
  final List<OrderItem> items;
  final String? createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.paymentLabel,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.currency = 'YER',
    this.isPayable = false,
    this.itemsCount = 0,
    this.items = const [],
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        orderNumber: j['order_number'] ?? '',
        status: j['status'] ?? 'pending',
        statusLabel: j['status_label'] ?? '',
        paymentStatus: j['payment_status'] ?? 'unpaid',
        paymentLabel: j['payment_label'] ?? '',
        subtotal: double.tryParse((j['subtotal'] ?? 0).toString()) ?? 0,
        discount: double.tryParse((j['discount'] ?? 0).toString()) ?? 0,
        total: double.tryParse((j['total'] ?? 0).toString()) ?? 0,
        currency: j['currency'] ?? 'YER',
        isPayable: j['is_payable'] ?? false,
        itemsCount: j['items_count'] ?? 0,
        items: j['items'] != null
            ? (j['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
            : const [],
        createdAt: j['created_at'],
      );
}

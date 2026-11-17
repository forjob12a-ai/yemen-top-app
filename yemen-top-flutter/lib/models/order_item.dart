class OrderItem {
  final int id;
  final String productName;
  final String packageName;
  final String? playerId;
  final int quantity;
  final double unitPrice;
  final double total;
  final String status;
  final String statusLabel;
  final String? deliveredData;

  OrderItem({
    required this.id,
    required this.productName,
    required this.packageName,
    this.playerId,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.status,
    required this.statusLabel,
    this.deliveredData,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: j['id'],
        productName: j['product_name'] ?? '',
        packageName: j['package_name'] ?? '',
        playerId: j['player_id'],
        quantity: j['quantity'] ?? 1,
        unitPrice: (j['unit_price'] ?? 0).toDouble(),
        total: (j['total'] ?? 0).toDouble(),
        status: j['status'] ?? 'pending',
        statusLabel: j['status_label'] ?? '',
        deliveredData: j['delivered_data'],
      );
}

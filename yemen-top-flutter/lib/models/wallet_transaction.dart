class WalletTransaction {
  final int id;
  final String type;
  final String typeLabel;
  final double amount;
  final bool isCredit;
  final double balanceAfter;
  final String? description;
  final String? createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.amount,
    required this.isCredit,
    required this.balanceAfter,
    this.description,
    this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> j) => WalletTransaction(
        id: j['id'],
        type: j['type'] ?? '',
        typeLabel: j['type_label'] ?? '',
        amount: double.tryParse((j['amount'] ?? 0).toString()) ?? 0,
        isCredit: j['is_credit'] ?? false,
        balanceAfter: double.tryParse((j['balance_after'] ?? 0).toString()) ?? 0,
        description: j['description'],
        createdAt: j['created_at'],
      );
}

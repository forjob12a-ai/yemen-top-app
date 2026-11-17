class PaymentMethod {
  final int id;
  final String name;
  final String code;
  final String type;
  final String? instructions;
  final String? accountName;
  final String? accountNumber;
  final bool requiresReceipt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.instructions,
    this.accountName,
    this.accountNumber,
    this.requiresReceipt = true,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: j['id'],
        name: j['name'] ?? '',
        code: j['code'] ?? '',
        type: j['type'] ?? 'manual',
        instructions: j['instructions'],
        accountName: j['account_name'],
        accountNumber: j['account_number'],
        requiresReceipt: j['requires_receipt'] ?? true,
      );
}

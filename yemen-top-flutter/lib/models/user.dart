class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final double walletBalance;

  User({required this.id, required this.name, required this.phone, this.email, this.walletBalance = 0});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'],
        walletBalance: double.tryParse((j['wallet_balance'] ?? 0).toString()) ?? 0,
      );
}

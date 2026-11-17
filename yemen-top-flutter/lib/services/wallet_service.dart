import '../models/wallet_transaction.dart';
import 'api_client.dart';

class WalletData {
  final double balance;
  final List<WalletTransaction> transactions;
  WalletData(this.balance, this.transactions);
}

class WalletService {
  final _api = ApiClient.instance;

  Future<WalletData> wallet() async {
    final res = await _api.get('wallet');
    final txList = (res['transactions']?['data'] ?? []) as List;
    return WalletData(
      (res['balance'] ?? 0).toDouble(),
      txList.map((t) => WalletTransaction.fromJson(t)).toList(),
    );
  }

  Future<void> topup({
    required double amount,
    required int methodId,
    required String transactionRef,
    String? senderName,
    String? receiptPath,
  }) async {
    await _api.multipart(
      'wallet/topup',
      {
        'amount': amount.toString(),
        'payment_method_id': methodId.toString(),
        'transaction_ref': transactionRef,
        if (senderName != null) 'sender_name': senderName,
      },
      filePath: receiptPath,
    );
  }
}

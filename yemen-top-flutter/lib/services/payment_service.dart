import '../models/payment_method.dart';
import 'api_client.dart';

class PaymentService {
  final _api = ApiClient.instance;

  Future<List<PaymentMethod>> methods() async {
    final res = await _api.get('payment-methods');
    return (res['data'] as List).map((m) => PaymentMethod.fromJson(m)).toList();
  }

  Future<void> payWithWallet(int orderId) async {
    await _api.post('orders/$orderId/pay/wallet');
  }

  Future<void> submitManual({
    required int orderId,
    required int methodId,
    required String transactionRef,
    String? senderName,
    String? receiptPath,
  }) async {
    await _api.multipart(
      'orders/$orderId/pay/manual',
      {
        'payment_method_id': methodId.toString(),
        'transaction_ref': transactionRef,
        if (senderName != null) 'sender_name': senderName,
      },
      filePath: receiptPath,
    );
  }
}

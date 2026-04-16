import '../datasources/voucher_remote.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final VoucherRemote remote;

  VoucherRepository(this.remote);

  Future<Map<String, dynamic>?> validateVoucher(String code) {
    return remote.getVoucher(code);
  }

  Future<List<VoucherModel>> fetchAllVouchers() async {
    final res = await remote.getAllVouchers();

    return res
        .map((e) => VoucherModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> getUserUsageCount({
    required String voucherId,
    required String userId,
  }) {
    return remote.getUserUsageCount(
      voucherId: voucherId,
      userId: userId,
    );
  }

  Future<Map<String, int>> getUserUsageCountMapByVoucherId(String userId) {
    return remote.getUserUsageCountMapByVoucherId(userId);
  }

  Future<void> createVoucherUsage({
    required String voucherId,
    required String userId,
    required String orderId,
  }) {
    return remote.createVoucherUsage(
      voucherId: voucherId,
      userId: userId,
      orderId: orderId,
    );
  }

  Future<void> incrementUsedCount(String voucherId) {
    return remote.incrementUsedCount(voucherId);
  }
}
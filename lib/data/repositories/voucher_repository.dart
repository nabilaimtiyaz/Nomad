import '../datasources/voucher_remote.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final VoucherRemote remote;

  VoucherRepository(this.remote);

  Future<Map<String, dynamic>?> validateVoucher(String code) {
    return remote.getVoucher(code);
  }

  Future<List<VoucherModel>> fetchAllVouchers() async {
    final res = await remote.client
        .from('vouchers')
        .select();

    return (res as List)
        .map((e) => VoucherModel.fromMap(e))
        .toList();
  }
}
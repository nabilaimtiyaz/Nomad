import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../data/datasources/voucher_remote.dart';
import '../../data/models/voucher_model.dart';
import '../../data/repositories/voucher_repository.dart';
import '../cart/cart_controller.dart';

class VoucherController extends GetxController {
  final AppStateController _appState = Get.find<AppStateController>();
  final CartController _cart = Get.find<CartController>();

  final VoucherRepository _repository = VoucherRepository(VoucherRemote());

  final vouchers = <VoucherModel>[].obs;
  final isLoading = false.obs;

  final appliedVoucher = Rxn<VoucherModel>();
  final discountAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadVouchers();
  }

  Future<void> loadVouchers() async {
    try {
      isLoading.value = true;
      final rawList = await _repository.fetchAllVouchers();
      vouchers.value = rawList;
    } catch (e) {
      Get.log('loadVouchers error: $e');
      vouchers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> applyVoucher(String code) async {
    final normalized = code.trim().toUpperCase();

    if (normalized.isEmpty) {
      return 'Kode voucher tidak boleh kosong';
    }

    if (_appState.checkoutPointsToUse > 0) {
      return 'Tidak bisa pakai voucher dan poin bersamaan';
    }

    try {
      final data = await _repository.validateVoucher(normalized);

      if (data == null) {
        return 'Voucher tidak ditemukan';
      }

      final voucher = VoucherModel.fromMap(data);

      final error = voucher.validate(
        _cart.subtotal,
        _appState.getUserVoucherUsageCount(voucher.code),
      );

      if (error != null) {
        return error;
      }

      final discount = voucher.calculateDiscount(_cart.subtotal);

      appliedVoucher.value = voucher;
      discountAmount.value = discount;

      return null;
    } on PostgrestException catch (e) {
      Get.log('applyVoucher PostgrestException: ${e.message}');
      return _mapVoucherDbError(e);
    } catch (e) {
      Get.log('applyVoucher unknown error: $e');
      return 'Gagal memproses voucher. Coba lagi.';
    }
  }

  void clearAppliedVoucher() {
    appliedVoucher.value = null;
    discountAmount.value = 0;
  }

  List<VoucherModel> get activeVouchers =>
      vouchers.where((v) => v.isValid).toList();

  List<VoucherModel> get expiredVouchers =>
      vouchers.where((v) => !v.isValid).toList();

  bool isUsedByCurrentUser(VoucherModel voucher) {
    return _appState.getUserVoucherUsageCount(voucher.code) >=
        voucher.usagePerUser;
  }

  String _mapVoucherDbError(PostgrestException e) {
    if (e.code == '42703') {
      return 'Konfigurasi tabel voucher di database belum sesuai.';
    }

    return 'Gagal mengambil data voucher dari database.';
  }
}
import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/voucher_remote.dart';
import '../../data/models/voucher_model.dart';
import '../../data/repositories/voucher_repository.dart';
import '../cart/cart_controller.dart';

class VoucherController extends GetxController {
  final AppStateController _appState = Get.find<AppStateController>();
  final CartController _cart = Get.find<CartController>();

  final VoucherRepository _repository =
      VoucherRepository(VoucherRemote());

  final vouchers = <VoucherModel>[].obs;
  final isLoading = false.obs;

  final appliedVoucher = Rxn<VoucherModel>();
  final discountAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadVouchers();
  }

  /// ======================
  /// LOAD VOUCHERS FROM DB
  /// ======================
  Future<void> loadVouchers() async {
    isLoading.value = true;

    final rawList = await _repository.fetchAllVouchers();

    vouchers.value = rawList;

    isLoading.value = false;
  }

  /// ======================
  /// APPLY VOUCHER
  /// ======================
  Future<void> applyVoucher(String code) async {
    final data = await _repository.validateVoucher(code);

    if (data == null) {
      Get.snackbar("Error", "Voucher tidak ditemukan");
      return;
    }

    final voucher = VoucherModel.fromMap(data);

    final error = voucher.validate(
      _cart.subtotal,
      _appState.getUserVoucherUsageCount(voucher.code),
    );

    if (error != null) {
      Get.snackbar("Error", error);
      return;
    }

    final discount = voucher.calculateDiscount(_cart.subtotal);

    appliedVoucher.value = voucher;
    discountAmount.value = discount;
  }

  /// ======================
  /// FILTER ACTIVE
  /// ======================
  List<VoucherModel> get activeVouchers =>
      vouchers.where((v) => v.isValid).toList();

  /// ======================
  /// FILTER EXPIRED
  /// ======================
  List<VoucherModel> get expiredVouchers =>
      vouchers.where((v) => !v.isValid).toList();

  /// ======================
  /// CEK USER SUDAH PAKAI
  /// ======================
  bool isUsedByCurrentUser(VoucherModel voucher) {
    return _appState.getUserVoucherUsageCount(voucher.code) >=
        voucher.usagePerUser;
  }
}
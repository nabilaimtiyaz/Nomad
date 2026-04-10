import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/order_remote.dart';
import '../../data/datasources/voucher_remote.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/voucher_repository.dart';
import '../cart/cart_controller.dart';

class OrderController extends GetxController {
  final cart = Get.find<CartController>();
  final appState = Get.find<AppStateController>();

  final orderRepo = OrderRepository(OrderRemote());
  final voucherRepo = VoucherRepository(VoucherRemote());

  final isLoading = false.obs;

  final voucherCode = ''.obs;
  final discountAmount = 0.obs;

  /// ======================
  /// APPLY VOUCHER (FIX LOGIC)
  /// ======================
  Future<void> applyVoucher(String code) async {
    final data = await voucherRepo.validateVoucher(code);

    if (data == null) {
      Get.snackbar("Error", "Voucher tidak ditemukan");
      return;
    }

    final minOrder = data['min_order_value'] ?? 0;
    final discount = data['discount_value'] ?? 0;
    final maxDiscount = data['max_discount'] ?? discount;

    if (cart.subtotal < minOrder) {
      Get.snackbar("Error", "Minimal belanja belum terpenuhi");
      return;
    }

    int finalDiscount = discount;

    if (maxDiscount != null) {
      finalDiscount = finalDiscount.clamp(0, maxDiscount) as int;
    }

    voucherCode.value = code;
    discountAmount.value = finalDiscount;
  }

  /// ======================
  /// CHECKOUT (FIX TOTAL)
  /// ======================
  Future<void> checkout() async {
    if (cart.cartItems.isEmpty) {
      Get.snackbar("Error", "Keranjang masih kosong");
      return;
    }

    try {
      isLoading.value = true;

      final queue = await orderRepo.generateQueueNumber();
      final branch = appState.selectedBranch!;

      final subtotal = cart.subtotal;
      final discount = discountAmount.value;
      final serviceFee = 0; // sesuai rule kamu

      final grandTotal = subtotal - discount + serviceFee;

      final order = OrderModel(
        id: '',
        userId: appState.user.id,
        queueNumber: queue,
        branchId: branch.id,
        branchName: branch.name,
        items: cart.items,
        paymentMethod: 'QRIS',
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        subtotal: subtotal,
        discountAmount: discount,
        serviceFee: serviceFee,
        grandTotal: grandTotal,
        pointsEarned: appState.calculateEarnedPoints(subtotal),
        pointsUsed: 0,
        orderType: 'dine_in',
        voucherCode: voucherCode.value,
      );

      final saved = await orderRepo.createOrder(order);

      appState.addOrder(saved);
      cart.clearCart();

      Get.toNamed(AppRoutes.orderStatus, arguments: saved);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

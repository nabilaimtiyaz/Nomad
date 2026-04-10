import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/routes/app_routes.dart';
import '../../data/datasources/order_remote.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../cart/cart_controller.dart';
import '../../core/app_state.dart';

class OrderController extends GetxController {
  final cart = Get.find<CartController>();
  final appState = Get.find<AppStateController>();

  final orderRepo = OrderRepository(OrderRemote());

  final SupabaseClient client = Supabase.instance.client;

  final isLoading = false.obs;

  final orders = <OrderModel>[].obs;

  /// 🔥 ORDER ACTIVE (UNTUK STATUS SCREEN)
  final currentOrder = Rxn<OrderModel>();

  RealtimeChannel? _channel;

  /// ======================
  /// FETCH ORDERS
  /// ======================
  Future<void> fetchOrders() async {
    final userId = appState.user.id;
    final result = await orderRepo.getOrders(userId);
    orders.assignAll(result);
  }

  /// ======================
  /// LISTEN REALTIME STATUS
  /// ======================
  void listenOrder(String orderId) {
    _channel?.unsubscribe();

    _channel = client.channel('orders-$orderId');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            final data = payload.newRecord;

            final updatedStatus = _parseStatus(data['status']);

            if (currentOrder.value != null) {
              currentOrder.value = currentOrder.value!.copyWith(
                status: updatedStatus,
              );
            }
          },
        )
        .subscribe();
  }

  OrderStatus _parseStatus(String? value) {
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'ready':
        return OrderStatus.ready;
      case 'done':
        return OrderStatus.done;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// ======================
  /// CHECKOUT
  /// ======================
  Future<void> checkout() async {
    if (cart.isEmpty) {
      Get.snackbar("Error", "Keranjang kosong");
      return;
    }

    try {
      isLoading.value = true;

      final queue = await orderRepo.generateQueueNumber();
      final branch = appState.selectedBranch!;

      final subtotal = cart.subtotal;
      final grandTotal = subtotal;

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
        discountAmount: 0,
        serviceFee: 0,
        grandTotal: grandTotal,
        pointsEarned: appState.calculateEarnedPoints(subtotal),
      );

      final saved = await orderRepo.createOrder(order);

      /// 🔥 SET CURRENT ORDER
      currentOrder.value = saved;

      /// 🔥 START LISTEN
      listenOrder(saved.id);

      cart.clearCart();

      Get.toNamed(AppRoutes.orderStatus, arguments: saved);
    } finally {
      isLoading.value = false;
    }
  }

  void goHome() {
    _channel?.unsubscribe();
    Get.offAllNamed(AppRoutes.home);
  }
}

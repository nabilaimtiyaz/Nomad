import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../data/datasources/order_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../cart/cart_controller.dart';

class OrderController extends GetxController {
  final cart = Get.find<CartController>();
  final appState = Get.find<AppStateController>();

  final orderRepo = OrderRepository(OrderRemote());
  final SupabaseClient client = Supabase.instance.client;

  bool isLoading = false;
  List<OrderModel> orders = [];
  OrderModel? currentOrder;

  bool isCheckoutMode = false;
  String orderType = 'takeaway';
  String paymentMethod = 'NomadPay';

  RealtimeChannel? _channel;

  @override
  void onReady() {
    super.onReady();

    if (appState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchOrders();
      });
    }
  }

  Future<void> fetchOrders() async {
    try {
      final userId = appState.user.id;
      if (userId.isEmpty) return;

      isLoading = true;
      update();

      final result = await orderRepo.getOrders(userId);
      orders = result;
      update();
    } finally {
      isLoading = false;
      update();
    }
  }

  void goToCheckout() {
    if (cart.isEmpty) {
      Get.snackbar('Keranjang kosong', 'Tambahkan menu terlebih dahulu.');
      return;
    }

    isCheckoutMode = true;
    currentOrder = null;
    orderType = 'takeaway';
    paymentMethod = 'NomadPay';
    update();

    Get.toNamed(AppRoutes.orderStatus);
  }

  void openExistingOrder(OrderModel order) {
    currentOrder = order;
    isCheckoutMode = false;
    update();

    if (order.status.isActive) {
      listenOrder(order.id);
    }
  }

  void setOrderType(String value) {
    orderType = value;
    update();
  }

  void setPaymentMethod(String value) {
    paymentMethod = value;
    update();
  }

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

            if (currentOrder != null) {
              currentOrder = currentOrder!.copyWith(status: updatedStatus);
            }

            final index = orders.indexWhere((e) => e.id == orderId);
            if (index >= 0) {
              orders[index] = orders[index].copyWith(status: updatedStatus);
            }

            update();
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

  Future<void> confirmOrder() async {
    if (cart.isEmpty) {
      Get.snackbar('Keranjang kosong', 'Tambahkan menu terlebih dahulu.');
      return;
    }

    if (!appState.isLoggedIn) {
      Get.snackbar('Belum login', 'Silakan login terlebih dahulu.');
      return;
    }

    if (appState.user.id.isEmpty) {
      Get.snackbar(
        'User tidak valid',
        'ID user pada tabel users tidak ditemukan.',
      );
      return;
    }

    if (appState.selectedBranch == null) {
      Get.snackbar('Cabang belum dipilih', 'Pilih cabang terlebih dahulu.');
      return;
    }

    try {
      isLoading = true;
      update();

      final queue = await orderRepo.generateQueueNumber();
      final branch = appState.selectedBranch!;
      final subtotal = cart.subtotal;

      final order = OrderModel(
        id: '',
        userId: appState.user.id,
        queueNumber: queue,
        branchId: branch.id,
        branchName: branch.name,
        items: List<CartItem>.from(cart.cartItems),
        paymentMethod: paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        subtotal: subtotal,
        discountAmount: 0,
        serviceFee: 0,
        grandTotal: subtotal,
        pointsEarned: appState.calculateEarnedPoints(subtotal),
        pointsUsed: 0,
        voucherCode: null,
        orderType: orderType,
        notes: null,
      );

      final saved = await orderRepo.createOrder(order);

      currentOrder = saved;
      isCheckoutMode = false;

      listenOrder(saved.id);

      cart.clearCart();
      await fetchOrders();
      update();
    } on PostgrestException catch (e) {
      Get.snackbar('Gagal checkout', e.message);
    } catch (e) {
      Get.snackbar('Gagal checkout', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void goHome() {
    _channel?.unsubscribe();
    isCheckoutMode = false;
    update();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }
}
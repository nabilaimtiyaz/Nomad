import 'package:get/get.dart';

import '../data/dummy_data.dart';
import '../data/models/branch_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/order_model.dart';
import '../data/models/user_model.dart';
import '../controllers/cart/cart_controller.dart';

class AppStateController extends GetxController {
  UserModel _user = DummyData.dummyUser;
  UserModel get user => _user;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Branch? _selectedBranch =
      DummyData.branches.isNotEmpty ? DummyData.branches.first : null;
  Branch? get selectedBranch => _selectedBranch;

  /// ======================
  /// 🔥 CART (DEPRECATED)
  /// ======================
  /// NOTE:
  /// Cart sekarang pakai CartController (GetX)
  /// Ini hanya fallback agar tidak error di file lama
  final CartController _cartController = Get.find<CartController>();

  List<CartItem> get cartItems => _cartController.items;

  int get cartTotalItems => _cartController.totalQty;

  int get cartTotalPrice => _cartController.subtotal;

  /// ======================
  /// ORDERS
  /// ======================
  final List<OrderModel> _orders = <OrderModel>[];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  final Map<String, int> _voucherUsageByCode = <String, int>{};

  void setBranch(Branch branch) {
    _selectedBranch = branch;
    update();
  }

  void setAuthenticatedUser(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    update();
  }

  void updateProfileLocal({required String name, required String phone}) {
    _user = _user.copyWith(name: name, phone: phone);
    update();
  }

  void logoutLocal() {
    _isLoggedIn = false;
    _user = DummyData.dummyUser;
    _orders.clear();
    _voucherUsageByCode.clear();

    /// clear cart dari controller
    _cartController.clearCart();

    update();
  }

  void updateProfile({required String name, required String phone}) {
    updateProfileLocal(name: name, phone: phone);
  }

  void logout() {
    logoutLocal();
  }

  /// ======================
  /// 🔥 CART (DEPRECATED API)
  /// ======================
  void addCartItem(MenuItem item, int qty, String notes) {
    _cartController.addItem(item, qty, notes);
    update();
  }

  void updateCartItemQty(String entryId, int delta) {
    final current = _cartController.items
        .firstWhereOrNull((e) => e.entryId == entryId);

    if (current == null) return;

    _cartController.updateQty(entryId, current.qty + delta);
    update();
  }

  void restoreCartItem(CartItem item) {
    _cartController.addItem(item.menuItem, item.qty, item.notes);
    update();
  }

  void clearCart() {
    _cartController.clearCart();
    update();
  }

  /// ======================
  /// ORDERS
  /// ======================
  void addOrder(OrderModel order) {
    _orders.insert(0, order);

    _earnPoints(order.pointsEarned);

    if (order.pointsUsed > 0) {
      _deductPoints(order.pointsUsed);
    }

    if (order.voucherCode != null && order.voucherCode!.trim().isNotEmpty) {
      markVoucherUsed(order.voucherCode!);
    }

    _cartController.clearCart();

    update();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(status: newStatus);
    update();
  }

  OrderModel? findOrder(String id) {
    return _orders.where((order) => order.id == id).firstOrNull;
  }

  /// ======================
  /// VOUCHER
  /// ======================
  int getUserVoucherUsageCount(String code) {
    return _voucherUsageByCode[code.trim().toUpperCase()] ?? 0;
  }

  void markVoucherUsed(String code) {
    final key = code.trim().toUpperCase();
    _voucherUsageByCode[key] = (_voucherUsageByCode[key] ?? 0) + 1;
    update();
  }

  /// ======================
  /// LOYALTY
  /// ======================
  void _earnPoints(int points) {
    if (points <= 0) return;

    final newTotalEarned = _user.totalEarnedPoints + points;
    final newBalance = _user.loyaltyPoints + points;

    _user = _user.copyWith(
      loyaltyPoints: newBalance,
      totalEarnedPoints: newTotalEarned,
      membershipTier: UserModel.getTier(newTotalEarned),
    );
  }

  void _deductPoints(int points) {
    if (points <= 0) return;

    final updatedBalance = (_user.loyaltyPoints - points).clamp(0, 1 << 31);
    _user = _user.copyWith(loyaltyPoints: updatedBalance);
  }

  bool redeemPoints(int points) {
    if (_user.loyaltyPoints < points) return false;
    _deductPoints(points);
    update();
    return true;
  }

  double get pointMultiplier {
    switch (_user.membershipTier) {
      case 'platinum':
        return 2.0;
      case 'gold':
        return 1.5;
      case 'silver':
        return 1.2;
      default:
        return 1.0;
    }
  }

  int calculateEarnedPoints(int grandTotal) {
    return ((grandTotal / 1000) * pointMultiplier).floor();
  }
}
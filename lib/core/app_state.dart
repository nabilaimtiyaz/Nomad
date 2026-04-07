// lib/core/app_state.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/dummy_data.dart';
import '../data/models/branch_model.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/order_model.dart';
import '../data/models/user_model.dart';

class AppStateNotifier extends GetxController {
  static const int coinValueInRupiah = 10;
  static const int earnCoinPerRupiah = 1000;
  static const double maxCoinDiscountPercent = 0.15;

  UserModel _user = DummyData.dummyUser;
  bool _isLoggedIn = false;
  Branch? _selectedBranch;

  final List<OrderModel> _orders = <OrderModel>[];
  final Map<String, CartItem> _cart = <String, CartItem>{};
  final Set<String> _usedVoucherCodes = <String>{};

  UserModel get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  Branch? get selectedBranch => _selectedBranch;
  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<CartItem> get cartItems => _cart.values.toList(growable: false);
  Set<String> get usedVoucherCodes => Set.unmodifiable(_usedVoucherCodes);

  int get cartCount => _cart.values.fold<int>(0, (sum, item) => sum + item.qty);
  int get cartTotal =>
      _cart.values.fold<int>(0, (sum, item) => sum + item.subtotal);

  Map<String, CartItem> get cartPreviewByMenu {
    final Map<String, CartItem> preview = <String, CartItem>{};

    for (final item in _cart.values) {
      final current = preview[item.menuItem.id];

      if (current == null) {
        preview[item.menuItem.id] = item.copyWith(entryId: item.menuItem.id);
        continue;
      }

      preview[item.menuItem.id] = current.copyWith(qty: current.qty + item.qty);
    }

    return preview;
  }

  CartItem? previewItemForMenu(String menuId) => cartPreviewByMenu[menuId];

  int qtyForMenu(String menuId) {
    return _cart.values
        .where((item) => item.menuItem.id == menuId)
        .fold<int>(0, (sum, item) => sum + item.qty);
  }

  OrderModel? findOrder(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  bool isVoucherUsed(String code) {
    return _usedVoucherCodes.contains(code.trim().toUpperCase());
  }

  String? findVoucherAvailabilityError(String code) {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode.isEmpty) {
      return 'Masukkan kode voucher';
    }

    if (isVoucherUsed(normalizedCode)) {
      return 'Voucher sudah habis dipakai';
    }

    return null;
  }

  int get maxCoinValueBalance => _user.loyaltyPoints * coinValueInRupiah;

  int calculateCoinDiscount(
    int subtotal, {
    int voucherDiscount = 0,
  }) {
    if (subtotal <= 0 || _user.loyaltyPoints <= 0) return 0;

    final maxByBalance = maxCoinValueBalance;
    final maxByPercent = (subtotal * maxCoinDiscountPercent).floor();
    final maxAfterVoucher = math.max(0, subtotal - voucherDiscount);

    return math.min(
      maxByBalance,
      math.min(maxByPercent, maxAfterVoucher),
    );
  }

  int calculateCoinsUsedFromDiscount(int coinDiscount) {
    if (coinDiscount <= 0) return 0;
    return coinDiscount ~/ coinValueInRupiah;
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
    if (grandTotal <= 0) return 0;
    return ((grandTotal / earnCoinPerRupiah) * pointMultiplier).floor();
  }

  void login({String? name, String? email, String? phone}) {
    _user = UserModel(
      id: 'user_1',
      name: name ?? DummyData.dummyUser.name,
      email: email ?? DummyData.dummyUser.email,
      phone: phone ?? DummyData.dummyUser.phone,
      loyaltyPoints: DummyData.dummyUser.loyaltyPoints,
      totalEarnedPoints: DummyData.dummyUser.totalEarnedPoints,
      membershipTier: DummyData.dummyUser.membershipTier,
    );
    _isLoggedIn = true;

    Branch? defaultBranch;
    for (final branch in DummyData.branches) {
      if (branch.isOpen) {
        defaultBranch = branch;
        break;
      }
    }

    _selectedBranch = defaultBranch ??
        (DummyData.branches.isNotEmpty ? DummyData.branches.first : null);

    _notify();
  }

  void logout() {
    _isLoggedIn = false;
    _selectedBranch = null;
    _orders.clear();
    _cart.clear();
    _usedVoucherCodes.clear();
    _notify();
  }

  void selectBranch(Branch branch, {bool clearCart = false}) {
    if (_selectedBranch?.id == branch.id) return;

    _selectedBranch = branch;

    if (clearCart) {
      _cart.clear();
    }

    _notify();
  }

  void addSimpleItem(MenuItem item) {
    if (!item.isAvailable) return;

    final key = CartItem.entryKey(item.id, '');
    final current = _cart[key];

    if (current == null) {
      _cart[key] = CartItem(entryId: key, menuItem: item, qty: 1, notes: '');
    } else {
      _cart[key] = current.copyWith(qty: current.qty + 1);
    }

    _notify();
  }

  void changeMenuQty(String menuId, int delta) {
    if (delta == 0) return;

    final key = CartItem.entryKey(menuId, '');
    final current = _cart[key];

    if (current == null) {
      if (delta <= 0) return;

      MenuItem? item;
      for (final menu in DummyData.menuItems) {
        if (menu.id == menuId) {
          item = menu;
          break;
        }
      }

      if (item == null || !item.isAvailable) return;

      _cart[key] = CartItem(
        entryId: key,
        menuItem: item,
        qty: delta,
        notes: '',
      );
      _notify();
      return;
    }

    final nextQty = current.qty + delta;

    if (nextQty <= 0) {
      _cart.remove(key);
    } else {
      _cart[key] = current.copyWith(qty: nextQty);
    }

    _notify();
  }

  void upsertDetailedItem(MenuItem item, int qty, String notes) {
    if (!item.isAvailable) return;

    final normalizedNotes = notes.trim();
    final key = CartItem.entryKey(item.id, normalizedNotes);

    if (qty <= 0) {
      _cart.remove(key);
      _notify();
      return;
    }

    _cart[key] = CartItem(
      entryId: key,
      menuItem: item,
      qty: qty,
      notes: normalizedNotes,
    );

    _notify();
  }

  void changeCartEntryQty(String entryId, int delta) {
    if (delta == 0) return;

    final current = _cart[entryId];
    if (current == null) return;

    final nextQty = current.qty + delta;

    if (nextQty <= 0) {
      _cart.remove(entryId);
    } else {
      _cart[entryId] = current.copyWith(qty: nextQty);
    }

    _notify();
  }

  void removeCartEntry(String entryId) {
    final removed = _cart.remove(entryId);
    if (removed == null) return;

    _notify();
  }

  void restoreCartEntry(CartItem item) {
    _cart[item.entryId] = item;
    _notify();
  }

  void clearCart() {
    if (_cart.isEmpty) return;

    _cart.clear();
    _notify();
  }

  void replaceCartFromOrder(OrderModel order) {
    Branch? matchedBranch;
    for (final branch in DummyData.branches) {
      if (branch.id == order.branchId) {
        matchedBranch = branch;
        break;
      }
    }

    _selectedBranch = matchedBranch ?? _selectedBranch;

    _cart
      ..clear()
      ..addEntries(order.items.map((item) => MapEntry(item.entryId, item)));

    _notify();
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);

    final voucherCode = order.voucherCode?.trim().toUpperCase();
    if (voucherCode != null && voucherCode.isNotEmpty) {
      _usedVoucherCodes.add(voucherCode);
    }

    final usedCoins = math.max(0, order.pointsUsed);
    final earnedCoins = math.max(0, order.pointsEarned);

    final newBalance =
        math.max(0, _user.loyaltyPoints - usedCoins) + earnedCoins;
    final newTotalEarned = _user.totalEarnedPoints + earnedCoins;

    _user = _user.copyWith(
      loyaltyPoints: newBalance,
      totalEarnedPoints: newTotalEarned,
      membershipTier: UserModel.getTier(newTotalEarned),
    );

    _notify();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(status: newStatus);
    _notify();
  }

  void updateProfile({required String name, required String phone}) {
    _user = _user.copyWith(name: name, phone: phone);
    _notify();
  }

  void _notify() {
    update();
  }
}

class AppStateProvider extends InheritedWidget {
  const AppStateProvider({
    super.key,
    required super.child,
    required AppStateNotifier notifier,
  });

  static AppStateNotifier of(BuildContext context) {
    return Get.find<AppStateNotifier>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
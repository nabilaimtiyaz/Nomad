import 'package:get/get.dart';
import '../../data/models/menu_item_model.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;

  /// ======================
  /// GETTERS
  /// ======================
  List<CartItem> get items => cartItems;

  int get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalQty {
    return cartItems.fold(0, (sum, item) => sum + item.qty);
  }

  bool get isEmpty => cartItems.isEmpty;

  /// ======================
  /// ADD ITEM
  /// ======================
  void addItem(MenuItem item, int qty, String notes) {
    final key = CartItem.entryKey(item.id, notes);

    final index = cartItems.indexWhere((e) => e.entryId == key);

    if (index >= 0) {
      final existing = cartItems[index];
      cartItems[index] = existing.copyWith(qty: existing.qty + qty);
    } else {
      cartItems.add(CartItem.detailed(item, qty, notes));
    }
  }

  void addSimple(MenuItem item) {
    addItem(item, 1, '');
  }

  void removeItem(String entryId) {
    cartItems.removeWhere((e) => e.entryId == entryId);
  }

  void updateQty(String entryId, int newQty) {
    final index = cartItems.indexWhere((e) => e.entryId == entryId);
    if (index < 0) return;

    if (newQty <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index] = cartItems[index].copyWith(qty: newQty);
    }
  }

  int qtyForMenu(String menuId) {
    int total = 0;
    for (final item in cartItems) {
      if (item.menuItem.id == menuId) {
        total += item.qty;
      }
    }
    return total;
  }

  void clearCart() {
    cartItems.clear();
  }
}

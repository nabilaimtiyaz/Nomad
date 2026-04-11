import 'package:get/get.dart';

import '../../controllers/cart/cart_controller.dart';
import '../../data/models/menu_item_model.dart';

class MenuDetailController extends GetxController {
  final MenuItem item;
  final void Function(int qty, String notes)? onAdd;

  MenuDetailController({
    required this.item,
    int initialQty = 1,
    this.onAdd,
  }) : qty = (initialQty > 0 ? initialQty : 1).obs;

  final RxInt qty;

  int get totalPrice => item.price * qty.value;

  void increment() {
    qty.value++;
  }

  void decrement() {
    if (qty.value > 1) {
      qty.value--;
    }
  }

  void addToCart() {
    if (onAdd != null) {
      onAdd!(qty.value, '');
      return;
    }

    final cart = Get.find<CartController>();
    cart.addItem(item, qty.value, '');
    Get.back();
  }
}
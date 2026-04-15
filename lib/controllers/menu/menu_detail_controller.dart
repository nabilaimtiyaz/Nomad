import 'package:get/get.dart';

import '../../data/models/menu_item_model.dart';
import '../cart/cart_controller.dart';

class MenuDetailController extends GetxController {
  final MenuItem item;
  final void Function(int qty, String notes)? onAdd;
  final int initialQty;

  MenuDetailController({
    required this.item,
    this.onAdd,
    this.initialQty = 1,
  });

  int qty = 1;
  late DrinkCustomization drinkCustomization;
  late FoodCustomization foodCustomization;

  @override
  void onInit() {
    super.onInit();
    qty = initialQty > 0 ? initialQty : 1;

    /// default normal semua
    drinkCustomization = DrinkCustomization.defaults();
    foodCustomization = FoodCustomization.defaults();
  }

  bool get isDrink => item.isDrink;
  bool get isFoodCustomizable => item.isFood;
  bool get hasCustomization => isDrink || isFoodCustomizable;

  void increment() {
    qty++;
    update();
  }

  void decrement() {
    if (qty > 1) {
      qty--;
      update();
    }
  }

  void setTemperature(String value) {
    if (!isDrink) return;

    if (value == 'hot') {
      drinkCustomization = drinkCustomization.copyWith(
        temperature: 'hot',
        iceLevel: null,
      );
    } else {
      drinkCustomization = drinkCustomization.copyWith(
        temperature: 'ice',
        iceLevel: 'normal',
      );
    }

    update();
  }

  void setIceLevel(String value) {
    if (!isDrink) return;
    if (drinkCustomization.temperature != 'ice') return;

    drinkCustomization = drinkCustomization.copyWith(
      temperature: drinkCustomization.temperature,
      iceLevel: value,
      sugarLevel: drinkCustomization.sugarLevel,
    );
    update();
  }

  void setSugarLevel(String value) {
    if (!isDrink) return;

    drinkCustomization = drinkCustomization.copyWith(
      temperature: drinkCustomization.temperature,
      iceLevel: drinkCustomization.iceLevel,
      sugarLevel: value,
    );
    update();
  }

  void setSpicy(bool value) {
    if (!isFoodCustomizable) return;

    foodCustomization = foodCustomization.copyWith(isSpicy: value);
    update();
  }

  void setAddEgg(bool value) {
    if (!isFoodCustomizable) return;

    foodCustomization = foodCustomization.copyWith(addEgg: value);
    update();
  }

  int get unitPrice {
    if (isFoodCustomizable && foodCustomization.addEgg) {
      return item.price + 5000;
    }
    return item.price;
  }

  int get totalPrice => unitPrice * qty;

  String get customizationKey {
    if (isDrink) {
      final temp = drinkCustomization.temperature;
      final ice = drinkCustomization.iceLevel ?? 'none';
      final sugar = drinkCustomization.sugarLevel;
      return 'temp=$temp|ice=$ice|sugar=$sugar';
    }

    if (isFoodCustomizable) {
      final spicy = foodCustomization.isSpicy ? 'yes' : 'no';
      final egg = foodCustomization.addEgg ? 'yes' : 'no';
      return 'spicy=$spicy|egg=$egg';
    }

    return 'default';
  }

  String get notes {
    if (isDrink) {
      final tempLabel =
          drinkCustomization.temperature == 'ice' ? 'Ice' : 'Hot';
      final sugarLabel = _labelFromLevel(drinkCustomization.sugarLevel);

      if (drinkCustomization.temperature == 'ice') {
        final iceLabel =
            _labelFromLevel(drinkCustomization.iceLevel ?? 'normal');
        return 'Temperature: $tempLabel | Ice: $iceLabel | Sugar: $sugarLabel';
      }

      return 'Temperature: $tempLabel | Sugar: $sugarLabel';
    }

    if (isFoodCustomizable) {
      final spicyLabel = foodCustomization.isSpicy ? 'Ya' : 'Tidak';
      final eggLabel = foodCustomization.addEgg ? 'Ya' : 'Tidak';
      return 'Spicy: $spicyLabel | Egg: $eggLabel';
    }

    return '';
  }

  String _labelFromLevel(String value) {
    switch (value) {
      case 'less':
        return 'Less';
      case 'more':
        return 'More';
      default:
        return 'Normal';
    }
  }

  void addToCart() {
    if (onAdd != null) {
      onAdd!(qty, notes);
      Get.back();
      return;
    }

    final cart = Get.find<CartController>();
    cart.addItem(
      item,
      qty,
      notes,
      unitPrice: unitPrice,
      customizationKey: customizationKey,
    );
    Get.back();
  }
}
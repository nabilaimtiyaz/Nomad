import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/menu_item_model.dart';

class MenuDetailController extends GetxController {
  final MenuItem item;
  final int initialQty;
  final String initialNotes;
  final bool isDrink;

  MenuDetailController({
    required this.item,
    required this.initialQty,
    this.initialNotes = '',
    this.isDrink = false,
  });

  final qty = 1.obs;
  final notesCtrl = TextEditingController();
  final customization = const DrinkCustomization().obs;
  final selectedSugar = 'Normal'.obs;
  final selectedAddOns = <String>[].obs;

  final List<String> sugarLevels = ['No Sugar', 'Less Sugar', 'Normal'];
  final List<Map<String, dynamic>> addOnsData = const [
    {'name': 'Pearl', 'price': 4000},
    {'name': 'Coconut Jelly', 'price': 4000},
    {'name': 'Espresso Shot', 'price': 5000},
  ];


  @override
  void onInit() {
    super.onInit();
    qty.value = initialQty > 0 ? initialQty : 1;
    notesCtrl.text = initialNotes;
  }

  @override
  void onClose() {
    notesCtrl.dispose();
    super.onClose();
  }

  void increment() => qty.value++;

  void decrement() {
    if (qty.value > 1) {
      qty.value--;
    }
  }

  void setTemperature(String value) {
    customization.value = customization.value.copyWith(
      temperature: value,
      ice: value == 'Ice' ? 'Normal Ice' : '',
    );
  }

  void setSize(String value) {
    customization.value = customization.value.copyWith(size: value);
  }

  void setSugar(String value) {
    selectedSugar.value = value;
    customization.value = customization.value.copyWith(sugar: value);
  }

  void setIce(String value) {
    customization.value = customization.value.copyWith(ice: value);
  }

  void toggleAddOn(String name) {
    if (selectedAddOns.contains(name)) {
      selectedAddOns.remove(name);
    } else {
      selectedAddOns.add(name);
    }
  }

  int get totalPrice {
    final drinkExtraPrice = isDrink ? customization.value.extraPrice : 0;
    var addOnTotal = 0;

    for (final addOn in addOnsData) {
      if (selectedAddOns.contains(addOn['name'])) {
        addOnTotal += addOn['price'] as int;
      }
    }

    return (item.price + drinkExtraPrice + addOnTotal) * qty.value;
  }

  String generateFinalNotes() {
    final userNotes = notesCtrl.text.trim();
    final parts = <String>[];

    if (isDrink) {
      parts.add(customization.value.toSummary());
    }

    if (selectedAddOns.isNotEmpty) {
      parts.add('Add: ${selectedAddOns.join(', ')}');
    }

    if (userNotes.isNotEmpty) {
      parts.add('Notes: $userNotes');
    }

    return parts.join('\n');
  }
}

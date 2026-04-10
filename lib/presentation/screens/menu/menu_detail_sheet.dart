import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../core/utils/formatters.dart';

class MenuDetailSheet extends StatefulWidget {
  final MenuItem item;

  const MenuDetailSheet({super.key, required this.item});

  @override
  State<MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<MenuDetailSheet> {
  int qty = 1;
  final notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.item.name),
          Text(Formatters.currency(widget.item.price)),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (qty > 1) setState(() => qty--);
                },
                icon: const Icon(Icons.remove),
              ),
              Text("$qty"),
              IconButton(
                onPressed: () => setState(() => qty++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          TextField(
            controller: notesCtrl,
            decoration: const InputDecoration(hintText: "Notes"),
          ),

          ElevatedButton(
            onPressed: () {
              cart.addItem(widget.item, qty, notesCtrl.text);
              Get.back();
            },
            child: const Text("Tambah ke Cart"),
          )
        ],
      ),
    );
  }
}
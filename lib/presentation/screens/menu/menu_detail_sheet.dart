import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';

class MenuDetailSheet extends StatefulWidget {
  final MenuItem item;
  final int currentQty;
  final String currentNotes;
  final void Function(int qty, String notes)? onAdd;

  const MenuDetailSheet({
    super.key,
    required this.item,
    this.currentQty = 0,
    this.currentNotes = '',
    this.onAdd,
  });

  @override
  State<MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<MenuDetailSheet> {
  late int qty;
  late final TextEditingController notesCtrl;

  @override
  void initState() {
    super.initState();
    qty = widget.currentQty > 0 ? widget.currentQty : 1;
    notesCtrl = TextEditingController(text: widget.currentNotes);
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.currency(widget.item.price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.item.description.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.item.description,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (qty > 1) {
                      setState(() => qty--);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$qty',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => qty++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                hintText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final notes = notesCtrl.text.trim();

                  if (widget.onAdd != null) {
                    widget.onAdd!(qty, notes);
                  } else {
                    cart.addItem(widget.item, qty, notes);
                    Get.back();
                  }
                },
                child: const Text('Tambah ke Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
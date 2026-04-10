import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../core/utils/formatters.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return const Center(child: Text("Keranjang kosong"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (_, i) {
                  final item = cart.cartItems[i];

                  return ListTile(
                    title: Text(item.menuItem.name),
                    subtitle: Text(item.notes),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => cart.updateQty(
                              item.entryId, item.qty - 1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text("${item.qty}"),
                        IconButton(
                          onPressed: () => cart.updateQty(
                              item.entryId, item.qty + 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Total: ${Formatters.currency(cart.totalPrice)}",
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Checkout"),
                  )
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
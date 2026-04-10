import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Cart")),
      body: Obx(() {
        if (cart.cartItems.isEmpty) {
          return const Center(
            child: Text(
              "Keranjang kosong",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.notes.isNotEmpty) Text(item.notes),
                        Text(Formatters.currency(item.subtotal)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () =>
                              cart.updateQty(item.entryId, item.qty - 1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text("${item.qty}"),
                        IconButton(
                          onPressed: () =>
                              cart.updateQty(item.entryId, item.qty + 1),
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
                    "Total: ${Formatters.currency(cart.subtotal)}",
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => ElevatedButton(
                      onPressed: orderCtrl.isLoading.value
                          ? null
                          : () => orderCtrl.checkout(),
                      child: Text(
                        orderCtrl.isLoading.value
                            ? "Memproses..."
                            : "Checkout",
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
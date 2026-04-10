import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/cart/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import 'menu_detail_sheet.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuController>();
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Menu")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.menus.isEmpty) {
          return const Center(child: Text("Menu kosong"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.menus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final item = controller.menus[i];
            final qty = cart.qtyForMenu(item.id);

            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => MenuDetailSheet(item: item),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                    Text(item.name),
                    Text(Formatters.currency(item.price)),
                    qty > 0
                        ? Text("$qty x")
                        : IconButton(
                            onPressed: () => cart.addItem(item, 1, ''),
                            icon: const Icon(Icons.add),
                          )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/cart/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart'; // Pastikan import Category model

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuController>();
    final cart = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(controller: controller),
          const SizedBox(height: 10), // Jarak ganti top bar
          Expanded(
            child: Row(
              children: [
                _CategorySidebar(controller: controller),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.menus.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.coffee_outlined, size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            Text("Menu tidak ditemukan", style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.menus.length,
                      itemBuilder: (_, i) {
                        final item = controller.menus[i];

                        return GetBuilder<CartController>(
                          builder: (cartLogic) {
                            final qty = cartLogic.qtyForMenu(item.id);
                            return _MenuItemCard(
                              item: item,
                              qty: qty,
                              cart: cartLogic,
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MenuController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 200,
            decoration: const BoxDecoration(gradient: AppColors.gradientHeader),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Text(
                      "NOMAD COFFEE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Pick your daily brew",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Search beverages or snacks...",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 160);
    path.quadraticBezierTo(0, 200, 40, 200);
    path.lineTo(size.width - 40, 200);
    path.quadraticBezierTo(size.width, 200, size.width, 160);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CategorySidebar extends StatelessWidget {
  final MenuController controller;
  const _CategorySidebar({required this.controller});

  IconData _getIconData(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'local_cafe': return Icons.local_cafe;
      case 'emoji_food_beverage': return Icons.emoji_food_beverage;
      case 'fastfood': return Icons.fastfood;
      case 'dinner_dining': return Icons.dinner_dining;
      case 'local_drink': return Icons.local_drink;
      case 'menu_book': return Icons.menu_book;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(left: 10),
      child: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: SizedBox());
        }

        // Tambahkan tombol ALL di paling atas secara dinamis
        final allCategory = Category(id: 'all', name: 'ALL', icon: 'menu_book');
        final displayCategories = [allCategory, ...controller.categories];

        return ListView.builder(
          itemCount: displayCategories.length,
          itemBuilder: (_, i) {
            final category = displayCategories[i];
            final isSelected = controller.selectedType.value == category.id;

            return GestureDetector(
              onTap: () => controller.selectedType.value = category.id,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFB4F3E6) : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(category.icon),
                        color: isSelected ? AppColors.tealMedium : Colors.grey[400],
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isSelected ? AppColors.textPrimary : Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
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

class _MenuItemCard extends StatelessWidget {
  final dynamic item;
  final int qty;
  final CartController cart;

  const _MenuItemCard({required this.item, required this.qty, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.network(
                    item.imageUrl ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.currency(item.price),
                        style: AppTextStyles.price.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: GestureDetector(
              onTap: () => cart.addItem(item, 1, ''),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF006D5B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
          if (qty > 0)
            Positioned(
              right: 20,
              top: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$qty",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
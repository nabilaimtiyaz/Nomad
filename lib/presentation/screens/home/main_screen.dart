import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/home/main_controller.dart';
import 'home_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainCtrl = Get.find<MainController>();

    final screens = [
      const HomeScreen(),
      const MenuScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    const tabs = [
      ('Home', Icons.home_outlined, Icons.home_rounded),
      ('Menu', Icons.restaurant_menu_rounded, Icons.restaurant_menu_rounded),
      ('History', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
      ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return GetBuilder<MainController>(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.background,
        body: screens[mainCtrl.tabIndex],
        floatingActionButton: Obx(() {
          final cart = Get.find<CartController>();
          final showFab =
              (mainCtrl.tabIndex == 0 || mainCtrl.tabIndex == 1) &&
              !cart.isEmpty;

          if (!showFab) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.cart),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              '${cart.totalQty} Item  •  ${Formatters.currency(cart.subtotal)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: _buildBottomNav(mainCtrl, tabs),
      ),
    );
  }

  Widget _buildBottomNav(MainController ctrl, List tabs) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = ctrl.tabIndex == i;
              final (label, iconOff, iconOn) =
                  tabs[i] as (String, IconData, IconData);

              return Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.changeTab(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? iconOn : iconOff,
                        size: 22,
                        color: active
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

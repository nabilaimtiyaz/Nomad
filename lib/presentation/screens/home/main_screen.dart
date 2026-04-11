import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/home/main_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainCtrl = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : Get.put(MainController(), permanent: true);

    final screens = const [
      HomeScreen(),
      MenuScreen(),
      OrderHistoryScreen(),
      ProfileScreen(),
    ];

    const tabs = [
      ('Home', Icons.home_outlined, Icons.home_rounded),
      ('Menu', Icons.restaurant_menu_rounded, Icons.restaurant_menu_rounded),
      ('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
      ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return GetBuilder<MainController>(
      init: mainCtrl,
      builder: (mainCtrl) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: screens[mainCtrl.tabIndex],
          floatingActionButton: GetBuilder<CartController>(
            builder: (cart) {
              final shouldShow =
                  (mainCtrl.tabIndex == 0 || mainCtrl.tabIndex == 1) &&
                  cart.cartItems.isNotEmpty;

              if (!shouldShow) return const SizedBox.shrink();

              return _FloatingCartBadge(
                itemCount: cart.totalQty,
                totalLabel: Formatters.currency(cart.subtotal),
                onTap: () => Get.toNamed(AppRoutes.cart),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomNav(mainCtrl, tabs),
        );
      },
    );
  }

  Widget _buildBottomNav(
    MainController ctrl,
    List<(String, IconData, IconData)> tabs,
  ) {
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
              final (label, iconOff, iconOn) = tabs[i];

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

class _FloatingCartBadge extends StatelessWidget {
  final int itemCount;
  final String totalLabel;
  final VoidCallback onTap;

  const _FloatingCartBadge({
    required this.itemCount,
    required this.totalLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minWidth: 178),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lihat Cart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading3.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount item • $totalLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

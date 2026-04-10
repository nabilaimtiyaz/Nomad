import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../data/models/order_model.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  static const _steps = [
    (OrderStatus.pending, Icons.hourglass_bottom_rounded, 'WAITING'),
    (OrderStatus.confirmed, Icons.restaurant_rounded, 'PROCESSING'),
    (OrderStatus.ready, Icons.notifications_rounded, 'READY'),
    (OrderStatus.done, Icons.celebration_rounded, 'DONE'),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ctrl.goHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Header
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_rounded,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Nomad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryDark,
                    child: Text(
                      Get.find<AppStateController>().user.name.isNotEmpty
                          ? Get.find<AppStateController>().user.name[0]
                                .toUpperCase()
                          : 'N',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // Queue card
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientQueue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'ORDER IDENTIFICATION',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              ctrl.order.queueNumber,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Est. Pickup',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                                Text(
                                  '10:45',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'AM',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stepper — reaktif terhadap currentStatus
                        Obx(() => _buildStepper(ctrl.currentStatus.value)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...ctrl.order.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 64,
                              height: 64,
                              color: AppColors.surfaceGrey,
                              child: item.menuItem.imageUrl.startsWith('http')
                                  ? Image.network(
                                      item.menuItem.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.coffee_rounded,
                                        size: 28,
                                        color: AppColors.divider,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.coffee_rounded,
                                      size: 28,
                                      color: AppColors.divider,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.menuItem.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      Formatters.currency(item.menuItem.price),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.notes.isNotEmpty)
                                  Text(
                                    item.notes,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(color: AppColors.divider, height: 20),
                  _sumRow('Subtotal', Formatters.currency(ctrl.order.subtotal)),
                  const SizedBox(height: 6),
                  _sumRow('Tax', Formatters.currency(ctrl.order.serviceFee)),
                  const Divider(color: AppColors.divider, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        Formatters.currency(ctrl.order.grandTotal),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Brew Rewards card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.teal.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.stars_rounded,
                                size: 16,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Brew Rewards',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You've earned ${ctrl.order.pointsEarned} points with this order. "
                          "Only 8 points left until your next complimentary brew!",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.teal,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (ctrl.order.pointsEarned / 20).clamp(
                              0.0,
                              1.0,
                            ),
                            minHeight: 6,
                            backgroundColor: AppColors.teal.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${ctrl.order.pointsEarned} / 20 POINTS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              'LEVEL: NOMAD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pickup Location
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PICKUP LOCATION',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 1,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ctrl.order.branchName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: ctrl.goHome,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Need Help with this Order?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(OrderStatus status) {
    final stepIdx = _steps.indexWhere((s) => s.$1 == status);
    final activeIdx = stepIdx < 0 ? 0 : stepIdx;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = i ~/ 2 < activeIdx;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? AppColors.primary : Colors.white24,
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < activeIdx;
        final curr = idx == activeIdx;
        final (_, icon, label) = _steps[idx];

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.primary
                    : (curr ? Colors.white : Colors.white24),
                border: Border.all(
                  color: (done || curr) ? AppColors.primary : Colors.white24,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: done
                    ? Colors.white
                    : (curr ? AppColors.primary : Colors.white38),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: (done || curr) ? Colors.white : Colors.white38,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sumRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

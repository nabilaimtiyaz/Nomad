import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
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
    /// ✅ AMBIL DARI ARGUMENT
    final OrderModel order = Get.arguments;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),

          /// ======================
          /// QUEUE NUMBER
          /// ======================
          Text(
            order.queueNumber,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// ======================
          /// STEPPER
          /// ======================
          _buildStepper(order.status),

          const SizedBox(height: 20),

          /// ======================
          /// ORDER ITEMS
          /// ======================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...order.items.map(
                  (item) => ListTile(
                    title: Text(item.menuItem.name),
                    subtitle: item.notes.isNotEmpty
                        ? Text(item.notes)
                        : null,
                    trailing: Text(
                      Formatters.currency(item.menuItem.price),
                    ),
                  ),
                ),

                const Divider(),

                _row("Subtotal", Formatters.currency(order.subtotal)),
                _row("Discount", Formatters.currency(order.discountAmount)),
                _row("Service Fee", Formatters.currency(order.serviceFee)),

                const Divider(),

                _row(
                  "Total",
                  Formatters.currency(order.grandTotal),
                  bold: true,
                ),

                const SizedBox(height: 20),

                _row("Pickup Location", order.branchName),
              ],
            ),
          ),

          /// ======================
          /// BUTTON
          /// ======================
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: const Text("Back to Home"),
            ),
          ),
        ],
      ),
    );
  }

  /// ======================
  /// STEPPER
  /// ======================
  Widget _buildStepper(OrderStatus status) {
    final index = _steps.indexWhere((s) => s.$1 == status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _steps.map((step) {
        final isActive = _steps.indexOf(step) <= index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor:
                    isActive ? AppColors.primary : Colors.grey,
                child: Icon(
                  step.$2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(step.$3),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
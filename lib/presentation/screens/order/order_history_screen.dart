import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/order/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderController>();

    return Obx(() {
      final orders = controller.orders;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? _buildEmpty(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    const Text(
                      'ORDER HISTORY',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...orders.map(
                      (order) => _HistoryCard(
                        order: order,
                        onViewStatus: order.status.isActive
                            ? () => Get.toNamed(
                                AppRoutes.orderStatus,
                                arguments: order,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

Widget _buildEmpty(BuildContext context) => const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.divider),
      SizedBox(height: 14),
      Text(
        'Belum ada pesanan',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      SizedBox(height: 6),
      Text(
        'Mulai pesan dan nikmati pengalaman Nomad!',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    ],
  ),
);

class _HistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onViewStatus;

  const _HistoryCard({required this.order, this.onViewStatus});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.done:
        return AppColors.teal;
      case OrderStatus.cancelled:
        return AppColors.primary;
      case OrderStatus.pending:
      case OrderStatus.confirmed:
      case OrderStatus.ready:
        return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.confirmed:
        return 'Diproses';
      case OrderStatus.ready:
        return 'Siap Ambil';
      case OrderStatus.done:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemNames = order.items.map((e) => e.menuItem.name).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: order.status.isActive
            ? [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: AppColors.surfaceGrey,
              child:
                  order.items.isNotEmpty &&
                      order.items.first.menuItem.imageUrl.startsWith('http')
                  ? Image.network(
                      order.items.first.menuItem.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.coffee_rounded,
                        size: 48,
                        color: AppColors.divider,
                      ),
                    )
                  : const Icon(
                      Icons.coffee_rounded,
                      size: 48,
                      color: AppColors.divider,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ENTRY #${order.id.split('-').last}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.queueNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  itemNames.isNotEmpty ? itemNames : 'Pesanan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.branchName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${order.items.length} item • ${Formatters.currency(order.grandTotal)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onViewStatus != null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewStatus,
                      child: const Text('Lihat Status'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

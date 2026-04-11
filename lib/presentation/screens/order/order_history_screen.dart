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
    final OrderController controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(), permanent: true);

    return GetBuilder<OrderController>(
      init: controller,
      builder: (controller) {
        final orders = controller.orders;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                ? const _EmptyState()
                : _OrderHistoryContent(orders: orders),
          ),
        );
      },
    );
  }
}

class _OrderHistoryContent extends StatefulWidget {
  final List<OrderModel> orders;

  const _OrderHistoryContent({required this.orders});

  @override
  State<_OrderHistoryContent> createState() => _OrderHistoryContentState();
}

class _OrderHistoryContentState extends State<_OrderHistoryContent> {
  int selectedTab = 0;

  List<OrderModel> get filteredOrders {
    switch (selectedTab) {
      case 1:
        return widget.orders.where((o) => o.status.isActive).toList();
      case 2:
        return widget.orders.where((o) => !o.status.isActive).toList();
      default:
        return widget.orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const Text(
          'The Nomad Brew',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _FilterChip(
                label: 'All Orders',
                selected: selectedTab == 0,
                onTap: () => setState(() => selectedTab = 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterChip(
                label: 'In Progress',
                selected: selectedTab == 1,
                onTap: () => setState(() => selectedTab = 1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FilterChip(
                label: 'Completed',
                selected: selectedTab == 2,
                onTap: () => setState(() => selectedTab = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (filteredOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                'Tidak ada pesanan pada kategori ini',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ...filteredOrders.map((order) => _HistoryCard(order: order)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceGrey,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
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
            'Mulai pesan dan nikmati Nomad!',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OrderModel order;

  const _HistoryCard({required this.order});

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
        return 'MENUNGGU';
      case OrderStatus.confirmed:
        return 'DIPROSES';
      case OrderStatus.ready:
        return 'SIAP';
      case OrderStatus.done:
        return 'SELESAI';
      case OrderStatus.cancelled:
        return 'DIBATALKAN';
    }
  }

  String get _itemSummary {
    if (order.items.isEmpty) return 'Tidak ada item';
    return order.items.map((e) => '${e.qty}x ${e.menuItem.name}').join('\n');
  }

  String get _dateText {
    final d = order.createdAt;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy • $hh:$min';
  }

  void _openOrderDetail() {
    Get.toNamed(AppRoutes.orderStatus, arguments: order);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openOrderDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: order.items.isNotEmpty
                      ? _OrderImage(
                          imageUrl: order.items.first.menuItem.imageUrl,
                        )
                      : const Icon(
                          Icons.local_cafe_rounded,
                          color: AppColors.textHint,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.branchName.isNotEmpty
                        ? order.branchName
                        : 'Nomad Branch',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
            const SizedBox(height: 8),
            Text(
              _dateText,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _itemSummary,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'TOTAL PAYMENT',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.currency(order.grandTotal),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  final String imageUrl;

  const _OrderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const Icon(Icons.local_cafe_rounded, color: AppColors.textHint);
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image_outlined, color: AppColors.textHint),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image_outlined, color: AppColors.textHint),
    );
  }
}

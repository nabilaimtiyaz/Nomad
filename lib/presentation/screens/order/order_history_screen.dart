import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStateNotifier>(
      builder: (appState) {
        final orders = appState.orders;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Riwayat Pesanan'),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: orders.isEmpty
              ? const Center(child: Text('Belum ada riwayat pesanan'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _HistoryCard(order: order);
                  },
                ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final totalQty = order.items.fold<int>(0, (sum, item) => sum + item.qty);
    final firstItemName = order.items.isNotEmpty
        ? order.items.first.menuItem.name
        : 'Pesanan';
    final extraCount = totalQty > 1 ? totalQty - 1 : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _OrderImage(order: order),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Perubahan: judul utama sekarang nama menu, bukan nama cabang
                    Text(
                      firstItemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.branchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatOrderDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: order.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.currency(order.grandTotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _OrderItemRow(
            name: firstItemName,
            qty: order.items.isNotEmpty ? order.items.first.qty : 0,
            price: order.items.isNotEmpty ? order.items.first.subtotal : 0,
          ),
          if (extraCount > 1) ...[
            const SizedBox(height: 6),
            Text(
              '+${extraCount - 1} item lainnya',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showOrderDetails(context, order);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$month $day, $year •\n$hour:$minute';
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.branchName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.qty}x ${item.menuItem.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Formatters.currency(item.subtotal),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Subtotal',
                  value: Formatters.currency(order.subtotal),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Tax & Service',
                  value: Formatters.currency(order.serviceFee),
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  label: 'Discount',
                  value: '- ${Formatters.currency(order.discountAmount)}',
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'Grand Total',
                  value: Formatters.currency(order.grandTotal),
                  isStrong: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final hasItems = order.items.isNotEmpty;
    final imageUrl = hasItems ? order.items.first.menuItem.imageUrl : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 58,
        height: 58,
        color: AppColors.surfaceGrey,
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.coffee_rounded,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              )
            : const Icon(
                Icons.coffee_rounded,
                color: AppColors.textSecondary,
                size: 26,
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: config.foreground,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  _StatusStyle _statusConfig(OrderStatus status) {
    final raw = status.toString().split('.').last.toLowerCase();

    if (raw == 'success' || raw == 'completed' || raw == 'done') {
      return const _StatusStyle(
        label: '• DONE',
        background: Color(0xFFD8F5E8),
        foreground: Color(0xFF119B63),
      );
    }

    if (raw == 'cancelled' || raw == 'canceled') {
      return const _StatusStyle(
        label: '• CANCELLED',
        background: Color(0xFFFDE1E1),
        foreground: Color(0xFFD64545),
      );
    }

    if (raw == 'processing' || raw == 'process') {
      return const _StatusStyle(
        label: '• PROCESS',
        background: Color(0xFFE7F1FF),
        foreground: Color(0xFF2B6EDC),
      );
    }

    return const _StatusStyle(
      label: '• PENDING',
      background: Color(0xFFFFF0D9),
      foreground: Color(0xFFD48A00),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.name,
    required this.qty,
    required this.price,
  });

  final String name;
  final int qty;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$qty x $name',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          Formatters.currency(price),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isStrong ? 15 : 13,
            fontWeight: isStrong ? FontWeight.w800 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isStrong ? 15 : 13,
            fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
            color: isStrong ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

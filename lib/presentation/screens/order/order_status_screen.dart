import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    super.initState();
    _simulate();
  }

  Future<void> _simulate() async {
    final appState = AppStateProvider.of(context);
    final order = appState.findOrder(widget.orderId);
    if (order == null) return;

    if (order.status == OrderStatus.pending) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      appState.updateOrderStatus(widget.orderId, OrderStatus.confirmed);
    }

    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;

    final latest = appState.findOrder(widget.orderId);
    if (latest != null && latest.status == OrderStatus.confirmed) {
      appState.updateOrderStatus(widget.orderId, OrderStatus.ready);
    }
  }

  static const _steps = [
    (OrderStatus.pending, Icons.hourglass_bottom_rounded, 'WAITING'),
    (OrderStatus.confirmed, Icons.restaurant_rounded, 'PROCESSING'),
    (OrderStatus.ready, Icons.notifications_rounded, 'READY'),
    (OrderStatus.done, Icons.celebration_rounded, 'DONE'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final order = appState.findOrder(widget.orderId);
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(child: Text('Pesanan tidak ditemukan')),
          );
        }

        final stepIndex = _steps.indexWhere((step) => step.$1 == order.status);
        final activeIndex = stepIndex < 0 ? 0 : stepIndex;

        return PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
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
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/80?img=5',
                        ),
                        backgroundColor: AppColors.surfaceGrey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    children: [
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
                                  order.queueNumber,
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
                            Row(
                              children: List.generate(_steps.length, (index) {
                                final step = _steps[index];
                                final isReached = index <= activeIndex;
                                return Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isReached
                                                    ? Colors.white
                                                    : Colors.white24,
                                              ),
                                              child: Icon(
                                                step.$2,
                                                size: 18,
                                                color: isReached
                                                    ? AppColors.primary
                                                    : Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              step.$3,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (index < _steps.length - 1)
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            margin: const EdgeInsets.only(
                                              bottom: 24,
                                            ),
                                            color: index < activeIndex
                                                ? Colors.white
                                                : Colors.white24,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
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
                      ...order.items.map(
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
                                  child:
                                      item.menuItem.imageUrl.startsWith('http')
                                      ? Image.network(
                                          item.menuItem.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
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
                                          Formatters.currency(
                                            item.menuItem.price,
                                          ),
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
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.qty}×',
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
                      _SumRow(
                        label: 'Subtotal',
                        value: Formatters.currency(order.subtotal),
                      ),
                      const SizedBox(height: 6),
                      _SumRow(
                        label: 'Tax',
                        value: Formatters.currency(order.serviceFee),
                      ),
                      if (order.discountAmount > 0) ...[
                        const SizedBox(height: 6),
                        _SumRow(
                          label: 'Discount',
                          value:
                              '- ${Formatters.currency(order.discountAmount)}',
                        ),
                      ],
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
                            Formatters.currency(order.grandTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              "You've earned ${order.pointsEarned} points with this order. Keep collecting to unlock your next complimentary brew!",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.teal,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

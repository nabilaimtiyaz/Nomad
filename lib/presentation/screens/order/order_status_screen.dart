import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  static const _steps = [
    (OrderStatus.pending, Icons.hourglass_bottom_rounded, 'WAITING'),
    (OrderStatus.confirmed, Icons.restaurant_rounded, 'PROCESSING'),
    (OrderStatus.ready, Icons.notifications_rounded, 'READY'),
    (OrderStatus.done, Icons.celebration_rounded, 'DONE'),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<OrderController>();
      final args = Get.arguments;

      if (args is OrderModel) {
        controller.openExistingOrder(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController(), permanent: true);

    final cart = Get.find<CartController>();
    final appState = Get.find<AppStateController>();

    return GetBuilder<OrderController>(
      init: controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: controller.isCheckoutMode
                ? _CheckoutMode(
                    controller: controller,
                    cart: cart,
                    branchName:
                        appState.selectedBranch?.name ?? 'Cabang belum dipilih',
                    branchAddress: appState.selectedBranch?.address ?? '-',
                  )
                : controller.currentOrder == null
                ? const Center(
                    child: Text(
                      'Belum ada data pesanan',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : _StatusMode(
                    order: controller.currentOrder!,
                    steps: _steps,
                    onBackHome: controller.goHome,
                  ),
          ),
        );
      },
    );
  }
}

class _CheckoutMode extends StatelessWidget {
  final OrderController controller;
  final CartController cart;
  final String branchName;
  final String branchAddress;

  const _CheckoutMode({
    required this.controller,
    required this.cart,
    required this.branchName,
    required this.branchAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Expanded(
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              _CardBox(
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        label: 'Dine In',
                        selected: controller.orderType == 'dine_in',
                        onTap: () => controller.setOrderType('dine_in'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SegmentButton(
                        label: 'Takeaway',
                        selected: controller.orderType == 'takeaway',
                        onTap: () => controller.setOrderType('takeaway'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CardBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pickup Store',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(branchName, style: AppTextStyles.heading3),
                          const SizedBox(height: 4),
                          Text(branchAddress, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...cart.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.menuItem.name} x${item.qty}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CardBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Apply Promo Code',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Apply',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CardBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.paymentMethod,
                        items: const [
                          DropdownMenuItem(
                            value: 'NomadPay',
                            child: Text('NomadPay'),
                          ),
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setPaymentMethod(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              _priceRow('Subtotal', Formatters.currency(cart.subtotal)),
              const SizedBox(height: 8),
              _priceRow(
                'Total Amount',
                Formatters.currency(cart.subtotal),
                bold: true,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : controller.confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    controller.isLoading
                        ? 'Mengonfirmasi...'
                        : 'Konfirmasi & Pesan',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusMode extends StatelessWidget {
  final OrderModel order;
  final List<(OrderStatus, IconData, String)> steps;
  final VoidCallback onBackHome;

  const _StatusMode({
    required this.order,
    required this.steps,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexWhere((e) => e.$1 == order.status);

    return Column(
      children: [
        const SizedBox(height: 18),
        const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientQueue,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text(
                'Queue Number',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.queueNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildStepper(order.status, steps, currentIndex),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _CardBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...order.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.menuItem.name} x${item.qty}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.divider),
                    _priceRow('Subtotal', Formatters.currency(order.subtotal)),
                    const SizedBox(height: 8),
                    _priceRow(
                      'Total',
                      Formatters.currency(order.grandTotal),
                      bold: true,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _infoRow('Pickup', order.branchName),
                    _infoRow('Payment', order.paymentMethod),
                    _infoRow(
                      'Order Type',
                      order.orderType == 'dine_in' ? 'Dine In' : 'Takeaway',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onBackHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Back to Home', style: AppTextStyles.button),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(
    OrderStatus status,
    List<(OrderStatus, IconData, String)> steps,
    int currentIndex,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index <= currentIndex;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surfaceGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.$2,
                          color: isActive ? Colors.white : AppColors.textHint,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.$3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    color: index < currentIndex
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu konfirmasi';
      case OrderStatus.confirmed:
        return 'Pesanan sedang diproses';
      case OrderStatus.ready:
        return 'Pesanan siap diambil';
      case OrderStatus.done:
        return 'Pesanan selesai';
      case OrderStatus.cancelled:
        return 'Pesanan dibatalkan';
    }
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;

  const _CardBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
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
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _priceRow(
  String label,
  String value, {
  bool bold = false,
  Color? color,
}) {
  final textColor = color ?? AppColors.textPrimary;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: bold ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: bold ? 18 : 14,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: textColor,
        ),
      ),
    ],
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../controllers/voucher/voucher_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
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

    final VoucherController voucherController =
        Get.isRegistered<VoucherController>()
            ? Get.find<VoucherController>()
            : Get.put(VoucherController());

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
                    voucherController: voucherController,
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
  final VoucherController voucherController;
  final CartController cart;
  final String branchName;
  final String branchAddress;

  const _CheckoutMode({
    required this.controller,
    required this.voucherController,
    required this.cart,
    required this.branchName,
    required this.branchAddress,
  });

  Future<void> _showVoucherDialog(BuildContext context) async {
    if (controller.pointsToUse > 0) {
      _showError('Poin dan voucher tidak bisa digunakan bersamaan');
      return;
    }

    final textController = TextEditingController(
      text: voucherController.appliedVoucher.value?.code ?? '',
    );

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Pakai Voucher',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: textController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Masukkan kode voucher',
            isDense: true,
            filled: true,
            fillColor: AppColors.surfaceGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final message = await voucherController.applyVoucher(
                textController.text,
              );

              controller.refreshCheckout();

              if (message != null) {
                _showError(message);
                return;
              }

              Get.back();
              _showSuccess('Voucher berhasil dipakai');
            },
            child: const Text('Pakai'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPointsDialog(BuildContext context) async {
    final appState = Get.find<AppStateController>();

    if (!appState.isLoggedIn) {
      _showError('Kamu harus login dulu untuk menggunakan poin');
      return;
    }

    if (voucherController.appliedVoucher.value != null) {
      _showError('Hapus voucher dulu sebelum menggunakan poin');
      return;
    }

    if (controller.maxPointsUsable <= 0) {
      _showError('Poin belum tersedia atau subtotal belum memenuhi');
      return;
    }

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Gunakan Poin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poin tersedia: ${Formatters.commas(appState.user.loyaltyPoints)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Maksimal poin yang bisa dipakai: ${Formatters.commas(controller.maxPointsUsable)}',
            ),
            const SizedBox(height: 12),
            const Text(
              'Poin dipakai sebagai alat bayar, bukan diskon tambahan.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (controller.pointsToUse > 0)
            TextButton(
              onPressed: () {
                controller.clearPoints();
                Get.back();
                _showSuccess('Poin dibatalkan');
              },
              child: const Text('Hapus Poin'),
            ),
          TextButton(onPressed: Get.back, child: const Text('Batal')),
          TextButton(
            onPressed: () {
              controller.applyMaxPoints();
              Get.back();
              _showSuccess('Poin berhasil diterapkan');
            },
            child: const Text('Gunakan Maksimal'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCheckout() async {
    final result = await controller.confirmOrder();

    if (result is OrderModel) {
      await _showPaymentSuccessDialog(result);
      return;
    }

    if (result is String && result.isNotEmpty) {
      _showError(result);
    }
  }

  Future<void> _showPaymentSuccessDialog(OrderModel order) async {
    await Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: _PaymentSuccessDialog(
          order: order,
          onTrackOrder: Get.back,
          onBackHome: () {
            Get.back();
            controller.goHome();
          },
        ),
      ),
    );
  }

  static void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.cardBorder,
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.error_outline, color: AppColors.error),
      duration: const Duration(seconds: 3),
    );
  }

  static void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.cardBorder,
      borderWidth: 1,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appliedVoucher = voucherController.appliedVoucher.value;
    final appState = Get.find<AppStateController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
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
                    fontSize: 20,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              _SectionCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: AppTextStyles.heading2),
                    const SizedBox(height: 16),
                    ...cart.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CheckoutItemTile(item: item),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                padding: const EdgeInsets.all(14),
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
              _SectionCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.10),
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
                            style: AppTextStyles.captionBold,
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
              _SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: InkWell(
                  onTap: () => _showVoucherDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          appliedVoucher == null
                              ? 'Apply Promo Code'
                              : appliedVoucher.code,
                          style: TextStyle(
                            color: appliedVoucher == null
                                ? AppColors.textPrimary
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (appliedVoucher != null)
                        IconButton(
                          onPressed: () {
                            voucherController.clearAppliedVoucher();
                            controller.refreshCheckout();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        const Text(
                          'Apply',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: InkWell(
                  onTap: () => _showPointsDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          size: 18,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.pointsToUse > 0
                                  ? '${Formatters.commas(controller.pointsToUse)} poin digunakan'
                                  : 'Gunakan Poin',
                              style: TextStyle(
                                color: controller.pointsToUse > 0
                                    ? AppColors.teal
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appState.isLoggedIn
                                  ? 'Poin tersedia: ${Formatters.commas(appState.user.loyaltyPoints)}'
                                  : 'Login dulu untuk menggunakan poin',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.pointsToUse > 0)
                        IconButton(
                          onPressed: () {
                            controller.clearPoints();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        const Text(
                          'Use',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.paymentMethod,
                        borderRadius: BorderRadius.circular(16),
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
              _priceRow(
                'Subtotal',
                Formatters.currency(controller.subtotalPreview),
              ),
              if (controller.voucherDiscountPreview > 0) ...[
                const SizedBox(height: 8),
                _priceRow(
                  'Diskon Voucher',
                  '- ${Formatters.currency(controller.voucherDiscountPreview)}',
                  color: AppColors.success,
                ),
              ],
              if (controller.pointsToUse > 0) ...[
                const SizedBox(height: 8),
                _priceRow(
                  'Poin Digunakan',
                  '- ${Formatters.currency(controller.pointsToUse)}',
                  color: AppColors.teal,
                ),
              ],
              const SizedBox(height: 10),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),
              _priceRow(
                'Total Amount',
                Formatters.currency(controller.grandTotalPreview),
                bold: true,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                (controller.pointsToUse > 0 ||
                        controller.voucherDiscountPreview > 0)
                    ? 'Transaksi ini tidak mendapatkan poin baru.'
                    : 'Estimasi poin didapat: ${Formatters.commas(Get.find<AppStateController>().calculateEarnedPoints(controller.subtotalPreview))}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _submitCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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

class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ItemImage(imageUrl: item.menuItem.imageUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qty ${item.qty}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Formatters.currency(item.subtotal),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String imageUrl;

  const _ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.trim().isEmpty
          ? const Icon(Icons.image_outlined, color: AppColors.textHint)
          : imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    color: AppColors.textHint,
                  ),
                )
              : Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
    );
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTrackOrder;
  final VoidCallback onBackHome;

  const _PaymentSuccessDialog({
    required this.order,
    required this.onTrackOrder,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final earnedText = order.pointsEarned > 0
        ? 'Kamu mendapatkan +${order.pointsEarned} koin!'
        : 'Transaksi ini tidak menghasilkan poin baru.';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 116,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 18,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white.withOpacity(0.14),
                    size: 24,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: const Offset(0, 34),
                    child: Container(
                      width: 76,
                      height: 76,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pembayaran Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesananmu sedang kami siapkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2ECEB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.tealMedium,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.tealLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: AppColors.teal,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REWARD LOYALITAS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              earnedText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.teal,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onTrackOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Pantau Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onBackHome,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ],
      ),
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
              _SectionCard(
                padding: const EdgeInsets.all(16),
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
                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 8),
                      _priceRow(
                        'Diskon',
                        '- ${Formatters.currency(order.discountAmount)}',
                        color: AppColors.success,
                      ),
                    ],
                    if (order.pointsUsed > 0) ...[
                      const SizedBox(height: 8),
                      _priceRow(
                        'Poin Digunakan',
                        '- ${Formatters.currency(order.pointsUsed)}',
                        color: AppColors.teal,
                      ),
                    ],
                    if ((order.voucherCode ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _priceRow('Voucher', order.voucherCode!),
                    ],
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

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
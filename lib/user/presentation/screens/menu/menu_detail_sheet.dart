import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart/cart_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../controllers/order/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class MenuDetailSheet extends StatelessWidget {
  final MenuDetailController controller;

  const MenuDetailSheet({super.key, required this.controller});

  Future<void> _handleRedeemFlow(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      _RedeemConfirmDialog(controller: controller),
      barrierDismissible: true,
    );

    if (confirmed != true) return;

    final error = await controller.redeemWithPoints();
    if (error != null) {
      Get.snackbar('Gagal', error, snackPosition: SnackPosition.TOP);
      return;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.back();

    await Get.dialog(
      _RedeemSuccessDialog(
        itemName: controller.item.name,
        pointsUsed: controller.totalRedeemPoints,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuDetailController>(
      init: controller,
      global: false,
      builder: (controller) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF6F1EB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DCD3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MenuImageSection(imageUrl: controller.item.imageUrl),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.item.name,
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  controller.isRedeemMode
                                      ? '${Formatters.commas(controller.redeemUnitPoints)} poin'
                                      : Formatters.currency(
                                          controller.unitPrice,
                                        ),
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.priceLarge.copyWith(
                                    color: controller.isRedeemMode
                                        ? AppColors.teal
                                        : AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(
                              controller.item.description.trim().isNotEmpty
                                  ? controller.item.description.trim()
                                  : 'Expertly brewed dan dibuat fresh dengan rasa khas Nomad.',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12.5,
                                height: 1.45,
                                color: const Color(0xFF8F8A84),
                              ),
                            ),
                          ),
                          if (controller.isRedeemMode) ...[
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF0E9E2),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                18,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Reward ini hanya berlaku untuk 1 item per penukaran. Setelah dikonfirmasi, item akan masuk ke keranjang dengan harga Rp0.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.45,
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF0E9E2),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.isDrink) ...[
                                    const _SectionHeader(title: 'TEMPERATURE'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ChoiceCard(
                                            label: 'Ice',
                                            selected:
                                                controller
                                                    .drinkCustomization
                                                    .temperature ==
                                                'ice',
                                            onTap: () => controller
                                                .setTemperature('ice'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _ChoiceCard(
                                            label: 'Hot',
                                            selected:
                                                controller
                                                    .drinkCustomization
                                                    .temperature ==
                                                'hot',
                                            onTap: () => controller
                                                .setTemperature('hot'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    if (controller
                                            .drinkCustomization
                                            .temperature ==
                                        'ice') ...[
                                      const _SectionHeader(title: 'ICE LEVEL'),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _ChoiceCard(
                                                  label: 'Less Ice',
                                                  selected:
                                                      controller
                                                          .drinkCustomization
                                                          .iceLevel ==
                                                      'less',
                                                  onTap: () => controller
                                                      .setIceLevel('less'),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _ChoiceCard(
                                                  label: 'Normal Ice',
                                                  selected:
                                                      controller
                                                          .drinkCustomization
                                                          .iceLevel ==
                                                      'normal',
                                                  onTap: () => controller
                                                      .setIceLevel('normal'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _ChoiceCard(
                                                  label: 'More Ice',
                                                  selected:
                                                      controller
                                                          .drinkCustomization
                                                          .iceLevel ==
                                                      'more',
                                                  onTap: () => controller
                                                      .setIceLevel('more'),
                                                ),
                                              ),
                                              const Expanded(child: SizedBox()),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                    ],
                                    const _SectionHeader(title: 'SUGAR LEVEL'),
                                    const SizedBox(height: 10),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Normal Sugar',
                                                selected:
                                                    controller
                                                        .drinkCustomization
                                                        .sugarLevel ==
                                                    'normal',
                                                onTap: () => controller
                                                    .setSugarLevel('normal'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'Less Sugar',
                                                selected:
                                                    controller
                                                        .drinkCustomization
                                                        .sugarLevel ==
                                                    'less',
                                                onTap: () => controller
                                                    .setSugarLevel('less'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ChoiceCard(
                                                label: 'More Sugar',
                                                selected:
                                                    controller
                                                        .drinkCustomization
                                                        .sugarLevel ==
                                                    'more',
                                                onTap: () => controller
                                                    .setSugarLevel('more'),
                                              ),
                                            ),
                                            const Expanded(child: SizedBox()),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  if (controller.isFoodCustomizable) ...[
                                    const _SectionHeader(title: 'LEVEL PEDAS'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ChoiceCard(
                                            label: 'Tidak Pedas',
                                            selected: !controller
                                                .foodCustomization
                                                .isSpicy,
                                            onTap: () =>
                                                controller.setSpicy(false),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _ChoiceCard(
                                            label: 'Pedas',
                                            selected: controller
                                                .foodCustomization
                                                .isSpicy,
                                            onTap: () =>
                                                controller.setSpicy(true),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    const _SectionHeader(title: 'ADD-ON'),
                                    const SizedBox(height: 10),
                                    _AddOnCard(
                                      label: 'Tambah Egg',
                                      priceLabel:
                                          '+ ${Formatters.currency(5000)}',
                                      selected:
                                          controller.foodCustomization.addEgg,
                                      onTap: () => controller.setAddEgg(
                                        !controller.foodCustomization.addEgg,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: const Color(0xFFF6F1EB),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                  child: controller.isRedeemMode
                      ? SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => _handleRedeemFlow(context),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'TUKARKAN • ${Formatters.commas(controller.totalRedeemPoints)} poin',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            _QtyStepper(
                              qty: controller.qty,
                              onDecrease: controller.decrement,
                              onIncrease: controller.increment,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: controller.addToCart,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'TAMBAH • ${Formatters.currency(controller.totalPrice)}',
                                      style: AppTextStyles.button.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
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
      },
    );
  }
}

class _RedeemConfirmDialog extends StatelessWidget {
  final MenuDetailController controller;

  const _RedeemConfirmDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Konfirmasi Penukaran',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _dialogRow('Jumlah', '1 item'),
          _dialogRow(
            'Poin dipakai',
            '${Formatters.commas(controller.totalRedeemPoints)} poin',
          ),
          const SizedBox(height: 12),
          const Text(
            'Setelah dikonfirmasi, item akan masuk ke keranjang dengan harga Rp0 dan poin akan langsung dipotong.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Konfirmasi Tukar'),
        ),
      ],
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
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
      ),
    );
  }
}

class _RedeemSuccessDialog extends StatelessWidget {
  final String itemName;
  final int pointsUsed;

  const _RedeemSuccessDialog({
    required this.itemName,
    required this.pointsUsed,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.teal,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Penukaran Berhasil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$itemName berhasil ditukar dengan ${Formatters.commas(pointsUsed)} poin.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Item sudah masuk ke keranjang dan siap dilanjutkan ke checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (cart.isEmpty) return;
                  Get.find<OrderController>().goToCheckout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Lanjut ke Checkout'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Nanti Saja'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuImageSection extends StatelessWidget {
  final String imageUrl;

  const _MenuImageSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0EA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0E9E2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imageUrl.trim().isEmpty) {
      return _placeholder();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF4F0EA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 42,
        color: AppColors.textHint,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF6D6761),
        letterSpacing: 0.7,
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : const Color(0xFFE7DED5);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFD6CDC4),
                    width: 1.6,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOnCard extends StatelessWidget {
  final String label;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;

  const _AddOnCard({
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE7DED5),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                priceLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFD6CDC4),
                    width: 1.6,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyStepper({
    required this.qty,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DED5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '$qty',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F2EC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

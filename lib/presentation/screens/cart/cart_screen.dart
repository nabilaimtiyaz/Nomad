// lib/presentation/screens/cart/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/voucher_model.dart';
import '../order/order_history_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartItem? _lastRemoved;

  void _removeItem(AppStateNotifier appState, CartItem item) {
    _lastRemoved = item;
    appState.removeCartEntry(item.entryId);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.menuItem.name} dihapus'),
          duration: const Duration(seconds: 1),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.gold,
            onPressed: () {
              final removed = _lastRemoved;
              if (removed == null) return;
              appState.restoreCartEntry(removed);
              _lastRemoved = null;
            },
          ),
        ),
      );
  }

  void _showOrderSuccess(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.tealLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pesanan berhasil dibuat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ID: ${order.id}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _SuccessRow(label: 'Cabang', value: order.branchName),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: 'Items',
                        value:
                            '${order.items.fold<int>(0, (sum, item) => sum + item.qty)} item',
                      ),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: 'Pembayaran',
                        value: order.paymentMethod,
                      ),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: 'Diskon Koin',
                        value: Formatters.currency(
                          order.pointsUsed * AppStateNotifier.coinValueInRupiah,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: 'Koin Didapat',
                        value: '${order.pointsEarned} koin',
                      ),
                      const SizedBox(height: 10),
                      _SuccessRow(
                        label: 'Total',
                        value: Formatters.currency(order.grandTotal),
                        isStrong: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Nanti Saja'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Lihat Riwayat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCheckout(AppStateNotifier appState) {
    final branch = appState.selectedBranch;
    if (branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih cabang terlebih dahulu')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _CheckoutSheet(
        appState: appState,
        branch: branch,
        onConfirm: (order) {
          Navigator.pop(context);
          appState.clearCart();
          _showOrderSuccess(order);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStateNotifier>(
      builder: (appState) {
        final items = appState.cartItems;
        final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);
        final total = subtotal;
        final totalQty = items.fold<int>(0, (sum, item) => sum + item.qty);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: items.isEmpty
              ? _EmptyCart(onBrowseMenu: () => Navigator.pop(context))
              : Column(
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
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Selection',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '$totalQty ITEMS IN CART',
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                title: const Text('Kosongkan Keranjang?'),
                                content: const Text(
                                  'Semua item akan dihapus dari keranjang.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      appState.clearCart();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_sweep_outlined,
                              size: 22,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        children: [
                          ...items.map(
                            (item) => Dismissible(
                              key: ValueKey(item.entryId),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _removeItem(appState, item),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              child: _CartCard(
                                item: item,
                                onQty: (delta) => appState.changeCartEntryQty(
                                  item.entryId,
                                  delta,
                                ),
                                onRemove: () => _removeItem(appState, item),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _CartHighlightCard(
                            branchName:
                                appState.selectedBranch?.name ??
                                'Belum dipilih',
                            totalQty: totalQty,
                            total: total,
                            coinBalance: appState.user.loyaltyPoints,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _openCheckout(appState),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: appState.selectedBranch == null
                                ? AppColors.divider
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              appState.selectedBranch == null
                                  ? 'Pilih Cabang Dulu'
                                  : 'Checkout  •  ${Formatters.currency(total)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: appState.selectedBranch == null
                                    ? AppColors.textSecondary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CartCard extends StatelessWidget {
  const _CartCard({
    required this.item,
    required this.onQty,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQty;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 76,
              height: 76,
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
                Text(
                  item.menuItem.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(item.menuItem.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.notes,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () => onQty(-1),
                    ),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.qty}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QtyButton(icon: Icons.add_rounded, onTap: () => onQty(1)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _CartHighlightCard extends StatelessWidget {
  const _CartHighlightCard({
    required this.branchName,
    required this.totalQty,
    required this.total,
    required this.coinBalance,
  });

  final String branchName;
  final int totalQty;
  final int total;
  final int coinBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'READY TO CHECK OUT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesananmu sudah siap diproses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalQty item • Ambil di $branchName',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniInfoChip(
                  icon: Icons.local_offer_outlined,
                  label: '$coinBalance koin siap dipakai',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _MiniInfoChip(
                  icon: Icons.verified_outlined,
                  label: 'Diskon otomatis saat checkout',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tanpa service fee. Total akhir akan dikonfirmasi sekali lagi.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  Formatters.currency(total),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  const _MiniInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowseMenu});

  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: AppColors.divider,
            ),
            const SizedBox(height: 14),
            const Text(
              'Keranjangmu masih kosong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pilih racikan favoritmu dulu untuk melanjutkan checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBrowseMenu,
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({
    required this.appState,
    required this.branch,
    required this.onConfirm,
  });

  final AppStateNotifier appState;
  final Branch branch;
  final ValueChanged<OrderModel> onConfirm;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final TextEditingController _voucherCtrl = TextEditingController();

  VoucherModel? _appliedVoucher;
  String? _voucherError;
  String _payment = 'QRIS';
  String _orderType = 'dine_in';
  bool _isSubmitting = false;

  int get _subtotal => widget.appState.cartItems.fold<int>(
    0,
    (sum, item) => sum + item.subtotal,
  );

  int get _voucherDiscount =>
      _appliedVoucher?.calculateDiscount(_subtotal) ?? 0;

  int get _coinDiscount => widget.appState.calculateCoinDiscount(
    _subtotal,
    voucherDiscount: _voucherDiscount,
  );

  int get _coinsUsed =>
      widget.appState.calculateCoinsUsedFromDiscount(_coinDiscount);

  int get _grandTotal =>
      (_subtotal - _voucherDiscount - _coinDiscount).clamp(0, 1 << 31);

  int get _earnedCoins => widget.appState.calculateEarnedPoints(_grandTotal);

  int get _coinBalanceAfterOrder =>
      (widget.appState.user.loyaltyPoints - _coinsUsed + _earnedCoins).clamp(
        0,
        1 << 31,
      );

  String get _paymentDescription {
    switch (_payment) {
      case 'QRIS':
        return 'Pembayaran digital cepat dengan scan QR code.';
      case 'Cash':
        return 'Bayar langsung saat pengambilan pesanan.';
      case 'Debit':
        return 'Pembayaran kartu diproses saat transaksi dilakukan.';
      default:
        return 'Pilih metode pembayaran.';
    }
  }

  @override
  void dispose() {
    _voucherCtrl.dispose();
    super.dispose();
  }

  VoucherModel? _findVoucherByCode(String code) {
    for (final item in DummyVouchers.getAll()) {
      if (item.code.toUpperCase() == code) {
        return item;
      }
    }
    return null;
  }

  String? _validateVoucherInput({
    required String rawCode,
    required bool requireAppliedState,
  }) {
    final code = rawCode.trim().toUpperCase();

    if (code.isEmpty) {
      if (requireAppliedState) return null;
      return 'Masukkan kode voucher';
    }

    final availabilityError = widget.appState.findVoucherAvailabilityError(
      code,
    );
    if (availabilityError != null) {
      return availabilityError;
    }

    final voucher = _findVoucherByCode(code);
    if (voucher == null) {
      return 'Voucher tidak tersedia';
    }

    final error = voucher.validate(_subtotal, 0);
    if (error != null) {
      return error;
    }

    if (requireAppliedState &&
        (_appliedVoucher == null ||
            _appliedVoucher!.code.toUpperCase() != code)) {
      return 'Tekan Apply untuk menggunakan voucher ini';
    }

    return null;
  }

  Future<void> _applyVoucher() async {
    final rawCode = _voucherCtrl.text;
    final validationError = _validateVoucherInput(
      rawCode: rawCode,
      requireAppliedState: false,
    );

    if (validationError != null) {
      setState(() {
        _appliedVoucher = null;
        _voucherError = validationError;
      });
      return;
    }

    final voucher = _findVoucherByCode(rawCode.trim().toUpperCase());
    if (voucher == null) {
      setState(() {
        _appliedVoucher = null;
        _voucherError = 'Voucher tidak tersedia';
      });
      return;
    }

    setState(() {
      _appliedVoucher = voucher;
      _voucherError = null;
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Voucher ${voucher.code} berhasil digunakan'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;

    if (widget.appState.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong, tambahkan item terlebih dahulu'),
        ),
      );
      return;
    }

    if (widget.branch.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cabang belum valid, pilih cabang lagi')),
      );
      return;
    }

    final voucherValidationError = _validateVoucherInput(
      rawCode: _voucherCtrl.text,
      requireAppliedState: true,
    );

    if (voucherValidationError != null) {
      setState(() {
        _voucherError = voucherValidationError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final orderId = 'NMD-${DateTime.now().millisecondsSinceEpoch}';
    final normalizedVoucherCode = _appliedVoucher?.code.trim().toUpperCase();

    final order = OrderModel(
      id: orderId,
      queueNumber:
          'A-${(widget.appState.orders.length + 1).toString().padLeft(3, '0')}',
      branchId: widget.branch.id,
      branchName: widget.branch.name,
      items: widget.appState.cartItems,
      paymentMethod: _payment,
      createdAt: DateTime.now(),
      subtotal: _subtotal,
      discountAmount: _voucherDiscount + _coinDiscount,
      serviceFee: 0,
      grandTotal: _grandTotal,
      pointsEarned: _earnedCoins,
      pointsUsed: _coinsUsed,
      voucherCode: normalizedVoucherCode,
      orderType: _orderType,
    );

    widget.appState.addOrder(order);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    widget.onConfirm(order);
  }

  Future<void> _openFinalConfirmation() async {
    FocusScope.of(context).unfocus();

    final voucherValidationError = _validateVoucherInput(
      rawCode: _voucherCtrl.text,
      requireAppliedState: true,
    );

    if (voucherValidationError != null) {
      setState(() {
        _voucherError = voucherValidationError;
      });
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Konfirmasi Pesanan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Periksa kembali detail pesanan sebelum melanjutkan pembayaran.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _ReviewRow(label: 'Cabang', value: widget.branch.name),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Items',
                        value:
                            '${widget.appState.cartItems.fold<int>(0, (sum, item) => sum + item.qty)} item',
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Pembayaran',
                        value: _payment,
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Keterangan',
                        value: _paymentDescription,
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Voucher',
                        value: _appliedVoucher?.code ?? 'Tidak digunakan',
                        valueColor: _appliedVoucher == null
                            ? AppColors.textSecondary
                            : AppColors.teal,
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Koin Digunakan',
                        value: _coinsUsed > 0
                            ? '$_coinsUsed koin'
                            : 'Tidak digunakan',
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Diskon Koin',
                        value: '- ${Formatters.currency(_coinDiscount)}',
                        valueColor: _coinDiscount > 0
                            ? AppColors.teal
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Koin Didapat',
                        value: '$_earnedCoins koin',
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Saldo Koin Setelah Order',
                        value: '$_coinBalanceAfterOrder koin',
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Subtotal',
                        value: Formatters.currency(_subtotal),
                      ),
                      const SizedBox(height: 10),
                      _ReviewRow(
                        label: 'Diskon Voucher',
                        value: '- ${Formatters.currency(_voucherDiscount)}',
                        valueColor: _voucherDiscount > 0
                            ? AppColors.teal
                            : AppColors.textPrimary,
                      ),
                      const Divider(height: 24, color: AppColors.divider),
                      _ReviewRow(
                        label: 'Grand Total',
                        value: Formatters.currency(_grandTotal),
                        isStrong: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Periksa Lagi'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                Navigator.pop(dialogContext);
                                await _placeOrder();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _payment == 'Cash'
                              ? 'Konfirmasi Cash Order'
                              : 'Bayar dengan $_payment',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.user;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.branch.name,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _PaymentOptionCard(
                  title: 'QRIS',
                  subtitle: 'Bayar cepat dengan scan QR code.',
                  icon: Icons.qr_code_2_rounded,
                  selected: _payment == 'QRIS',
                  onTap: () => setState(() => _payment = 'QRIS'),
                ),
                const SizedBox(height: 10),
                _PaymentOptionCard(
                  title: 'Cash',
                  subtitle: 'Pembayaran dilakukan saat pengambilan.',
                  icon: Icons.payments_outlined,
                  selected: _payment == 'Cash',
                  onTap: () => setState(() => _payment = 'Cash'),
                ),
                const SizedBox(height: 10),
                _PaymentOptionCard(
                  title: 'Debit',
                  subtitle: 'Pembayaran kartu diproses saat transaksi.',
                  icon: Icons.credit_card_rounded,
                  selected: _payment == 'Debit',
                  onTap: () => setState(() => _payment = 'Debit'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _paymentDescription,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ORDER TYPE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: const ['dine_in', 'takeaway'].map((type) => type).map((
                type,
              ) {
                final active = _orderType == type;
                return ChoiceChip(
                  label: Text(type == 'dine_in' ? 'Dine In' : 'Take Away'),
                  selected: active,
                  onSelected: (_) => setState(() => _orderType = type),
                  selectedColor: AppColors.tealLight,
                  labelStyle: TextStyle(
                    color: active ? AppColors.teal : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              'LOYALTY COINS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.loyaltyPoints} koin tersedia',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Koin otomatis dikonversi menjadi diskon saat checkout.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CoinInfoRow(
                    label: 'Diskon otomatis',
                    value: '- ${Formatters.currency(_coinDiscount)}',
                  ),
                  const SizedBox(height: 8),
                  _CoinInfoRow(
                    label: 'Koin terpakai',
                    value: '$_coinsUsed koin',
                  ),
                  const SizedBox(height: 8),
                  _CoinInfoRow(
                    label: 'Koin didapat',
                    value: '$_earnedCoins koin',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'VOUCHER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherCtrl,
                    onChanged: (_) {
                      setState(() {
                        _voucherError = null;
                        _appliedVoucher = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode voucher',
                      errorText: _voucherError,
                      filled: true,
                      fillColor: AppColors.surfaceGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _applyVoucher,
                  child: const Text('Apply'),
                ),
              ],
            ),
            if (_appliedVoucher != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() {
                        _appliedVoucher = null;
                        _voucherError = null;
                        _voucherCtrl.clear();
                      }),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_appliedVoucher!.code} aktif • diskon ${Formatters.currency(_voucherDiscount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 18,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Setelah pembayaran berhasil, saldo koinmu menjadi $_coinBalanceAfterOrder koin.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.teal,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _openFinalConfirmation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isSubmitting
                      ? 'Memproses...'
                      : 'PLACE ORDER • ${Formatters.currency(_grandTotal)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.cardBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.teal.withOpacity(0.14)
                    : AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? AppColors.teal : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.teal : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? AppColors.teal : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinInfoRow extends StatelessWidget {
  const _CoinInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.isStrong = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isStrong;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isStrong ? 15 : 13,
              fontWeight: isStrong ? FontWeight.w800 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isStrong ? 15 : 13,
              fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({
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
            fontSize: isStrong ? 14 : 13,
            fontWeight: isStrong ? FontWeight.w800 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isStrong ? 14 : 13,
              fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
              color: isStrong ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

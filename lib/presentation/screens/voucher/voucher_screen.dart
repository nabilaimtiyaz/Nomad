import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/voucher_model.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final all = DummyVouchers.getAll();
    final available = all
        .where((v) => v.isValid && !appState.isVoucherUsed(v.code))
        .toList();
    final expired = all.where((v) => !v.isValid).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Voucher Saya', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [

          // ── Tips card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usage Tips', style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text(
                    'Vouchers are automatically applied at checkout for the best savings. You can only use one coupon per transaction.',
                    style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                ],
              )),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Available vouchers ────────────────────────────────────────
          if (available.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('AVAILABLE VOUCHERS', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.primary, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(20)),
                child: Text('${available.length} Available',
                  style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.teal)),
              ),
            ]),
            const SizedBox(height: 12),
            ...available.map((v) => _VoucherCard(voucher: v, isExpired: false)),
          ] else
            _buildEmpty(),

          // ── Expired section ───────────────────────────────────────────
          if (expired.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text('EXPIRED', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ...expired.map((v) => _VoucherCard(voucher: v, isExpired: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey, shape: BoxShape.circle),
        child: const Icon(Icons.discount_outlined,
          size: 32, color: AppColors.textHint),
      ),
      const SizedBox(height: 14),
      const Text('Tidak ada voucher aktif', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text('Voucher kamu akan muncul di sini',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    ])),
  );
}

class _VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final bool isExpired;
  const _VoucherCard({required this.voucher, required this.isExpired});

  String get _discountLabel {
    if (voucher.type == VoucherType.percent) return '${voucher.discountValue}%';
    final v = voucher.discountValue;
    return v >= 1000 ? '${v ~/ 1000}k' : '$v';
  }

  String get _discountSub {
    switch (voucher.type) {
      case VoucherType.percent: return 'OFF';
      case VoucherType.fixed:   return 'DISCOUNT';
      case VoucherType.freeItem: return 'FREE ITEM';
      default: return 'SPECIAL';
    }
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isExpired ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpired ? AppColors.divider : AppColors.cardBorder),
          boxShadow: isExpired ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Banner atas (dark dengan diskon besar) ────────────────────
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: isExpired ? AppColors.darkCard : AppColors.dark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(children: [
              // Dekorasi lingkaran
              Positioned(right: -20, top: -20,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(
                      isExpired ? 0.1 : 0.25)),
                )),
              Positioned(left: -10, bottom: -10,
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04)),
                )),

              // Gambar kopi / ikon sesuai tipe
              Positioned(left: 20, top: 0, bottom: 0,
                child: Center(
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14)),
                    child: Icon(
                      voucher.type == VoucherType.freeItem
                        ? Icons.free_breakfast_rounded
                        : voucher.type == VoucherType.fixed
                          ? Icons.local_offer_rounded
                          : Icons.percent_rounded,
                      size: 24, color: Colors.white70),
                  ),
                )),

              // Nilai diskon
              Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_discountLabel, style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.w900,
                    color: Colors.white, height: 1)),
                  Text(_discountSub, style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5)),
                ],
              )),

              // Badge expired
              if (isExpired)
                Positioned(top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('EXPIRED', style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      color: Colors.white60, letterSpacing: 0.5)),
                  )),
            ]),
          ),

          // ── Info & kode ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(voucher.name, style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(voucher.typeLabel, style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
              if (voucher.minOrderValue > 0) ...[
                const SizedBox(height: 2),
                Text('Min. order Rp ${voucher.minOrderValue ~/ 1000}k',
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Valid until ${_formatDate(voucher.expiryDate)}',
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 12),

              // Kode + tombol salin
              GestureDetector(
                onTap: isExpired ? null : () {
                  Clipboard.setData(ClipboardData(text: voucher.code));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Kode ${voucher.code} disalin!'),
                    backgroundColor: AppColors.teal,
                    duration: const Duration(seconds: 2)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isExpired
                        ? AppColors.divider
                        : AppColors.primary),
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(voucher.code, style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: isExpired
                          ? AppColors.textHint
                          : AppColors.primary,
                        letterSpacing: 1.5)),
                      const SizedBox(width: 20),
                      Text(isExpired ? 'UNAVAILABLE' : 'COPY CODE',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: isExpired
                            ? AppColors.textHint
                            : AppColors.primary,
                          letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

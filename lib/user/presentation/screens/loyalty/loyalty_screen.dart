import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/menu/menu_controller.dart';
import '../../../controllers/menu/menu_detail_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/user_model.dart';
import '../menu/menu_detail_sheet.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = Get.find<MenuController>();

    return GetBuilder<AppStateController>(
      builder: (appState) {
        final isLoggedIn = appState.isLoggedIn;
        final user = isLoggedIn
            ? appState.user
            : const UserModel(
                id: '',
                authId: '',
                name: 'Guest',
                email: '',
                phone: '',
                loyaltyPoints: 0,
                totalEarnedPoints: 0,
                membershipTier: 'silver',
                role: 'user',
              );

        final points = user.loyaltyPoints;
        final tier = user.membershipTier;
        final tierLabel = UserModel.getTierLabel(tier);
        final remainingToGold = (2500 - user.totalEarnedPoints).clamp(0, 2500);
        final remainingToPlatinum = (5000 - user.totalEarnedPoints).clamp(
          0,
          5000,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF8F3EF),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(user: user),
                      const SizedBox(height: 20),
                      _HeroPointsCard(points: points, tierLabel: tierLabel),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      _MembershipProgressCard(
                        tier: tier,
                        totalEarnedPoints: user.totalEarnedPoints,
                        remainingToGold: remainingToGold,
                        remainingToPlatinum: remainingToPlatinum,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Cara Kerja Poin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              title: 'Cara Mendapatkan',
                              subtitle:
                                  'Dapatkan 1 poin untuk setiap pembelanjaan Rp5.000. Berlaku kelipatan dan mengikuti tier membership.',
                              icon: Icons.shopping_bag_outlined,
                              iconColor: AppColors.teal,
                              onTap: _showEarnInfo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              title: 'Cara Menggunakan',
                              subtitle:
                                  'Gunakan 1 poin = Rp1.000 saat checkout, maksimal 10% dari subtotal dan tidak bisa digabung voucher.',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: AppColors.primary,
                              onTap: _showUsePointsInfo,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Menu Rewards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tukarkan poinmu dengan menu favorit secara langsung.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Obx(() {
                        final menus = menuController.menus;

                        if (menuController.isLoading.value) {
                          return const SizedBox(
                            height: 170,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (menus.isEmpty) {
                          return const SizedBox(
                            height: 120,
                            child: Center(
                              child: Text(
                                'Menu belum tersedia',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        final displayMenus = menus
                            .where((menu) => menu.isAvailable)
                            .take(6)
                            .toList();

                        if (displayMenus.isEmpty) {
                          return const SizedBox(
                            height: 120,
                            child: Center(
                              child: Text(
                                'Menu belum tersedia',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: displayMenus.length,
                            itemBuilder: (context, index) {
                              final menu = displayMenus[index];
                              return _MenuRewardCard(menu: menu);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 28),

                      const Text(
                        'Pusat Bantuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _InquiryItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Syarat & Ketentuan Poin',
                        onTap: _showTermsInfo,
                      ),
                      _InquiryItem(
                        icon: Icons.payments_outlined,
                        title: 'Aturan Voucher & Poin',
                        onTap: _showVoucherInfo,
                      ),
                      _InquiryItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Panduan Program Rewards',
                        onTap: _showEarnInfo,
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

  static int _rewardPointsFromPrice(int price) {
    if (price <= 0) return 0;
    return (price / 1000).ceil();
  }

  static void _showEarnInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: const Text(
          'Cara mendapatkan poin:\n\n'
          '• Dapatkan 1 poin untuk setiap pembelanjaan Rp5.000\n'
          '• Berlaku kelipatan sesuai nilai transaksi\n'
          '• Perhitungan poin didasarkan pada jumlah pembayaran akhir\n'
          '• Transaksi yang menggunakan voucher atau poin tidak mendapatkan poin baru\n'
          '• Poin akan masuk setelah transaksi selesai\n\n'
          'Tier membership:\n'
          '• Silver: 1x poin\n'
          '• Gold: 2x poin\n'
          '• Platinum: 3x poin',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }

  static void _showUsePointsInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: const Text(
          'Cara menggunakan poin:\n\n'
          '• 1 poin = Rp1.000 untuk potongan pembayaran saat checkout\n'
          '• Maksimal penggunaan poin adalah 10% dari subtotal transaksi\n'
          '• Poin tidak dapat digunakan bersamaan dengan voucher\n'
          '• Transaksi yang menggunakan poin tidak mendapatkan poin baru\n'
          '• Poin juga dapat ditukar langsung dengan menu reward tertentu\n'
          '• Masa berlaku poin adalah 12 bulan sejak diperoleh',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }

  static void _showTermsInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: const Text(
          'Syarat & ketentuan poin Nomad:\n\n'
          '• Poin berlaku selama 12 bulan sejak diperoleh\n'
          '• Poin tidak dapat diuangkan atau dipindahtangankan\n'
          '• Poin tidak dapat digabung dengan voucher dalam satu transaksi\n'
          '• Jika transaksi dibatalkan, poin yang digunakan akan dikembalikan dan poin yang didapat akan dibatalkan\n'
          '• Nomad berhak menarik poin apabila ditemukan penyalahgunaan program',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }

  static void _showVoucherInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: const Text(
          'Aturan voucher dan poin:\n\n'
          '• Voucher dan poin tidak dapat digunakan bersamaan\n'
          '• Jika menggunakan voucher, transaksi tidak mendapatkan poin baru\n'
          '• Jika menggunakan poin, transaksi tidak mendapatkan poin baru\n'
          '• Voucher digunakan untuk promo, sedangkan poin digunakan untuk reward loyalitas',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final UserModel user;

  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.primary,
          size: 22,
        ),
        const Spacer(),
        const Text(
          'Loyalty',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primary,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroPointsCard extends StatelessWidget {
  final int points;
  final String tierLabel;

  const _HeroPointsCard({required this.points, required this.tierLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomad Points',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.commas(points),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$tierLabel Member',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipProgressCard extends StatelessWidget {
  final String tier;
  final int totalEarnedPoints;
  final int remainingToGold;
  final int remainingToPlatinum;

  const _MembershipProgressCard({
    required this.tier,
    required this.totalEarnedPoints,
    required this.remainingToGold,
    required this.remainingToPlatinum,
  });

  @override
  Widget build(BuildContext context) {
    final int nextTarget = tier == 'gold'
        ? 5000
        : tier == 'platinum'
        ? 5000
        : 2500;

    final int currentBase = tier == 'gold'
        ? 2500
        : tier == 'platinum'
        ? 5000
        : 0;

    final double progress = tier == 'platinum'
        ? 1
        : ((totalEarnedPoints - currentBase) / (nextTarget - currentBase))
              .clamp(0, 1)
              .toDouble();

    final String subtitle = tier == 'platinum'
        ? 'Kamu sudah berada di tier tertinggi.'
        : tier == 'gold'
        ? '$remainingToPlatinum poin lagi menuju Platinum.'
        : '$remainingToGold poin lagi menuju Gold.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membership Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9E0D8),
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            ),
          ),
          const SizedBox(height: 12),
          _StatusPathCard(currentTier: tier),
        ],
      ),
    );
  }
}

class _StatusPathCard extends StatelessWidget {
  final String currentTier;

  const _StatusPathCard({required this.currentTier});

  @override
  Widget build(BuildContext context) {
    final labels = ['BRONZE', 'SILVER', 'GOLD', 'PLATINUM'];

    int currentIndex;
    switch (currentTier) {
      case 'platinum':
        currentIndex = 3;
        break;
      case 'gold':
        currentIndex = 2;
        break;
      case 'silver':
        currentIndex = 1;
        break;
      default:
        currentIndex = 0;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EBE6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final active = lineIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 4,
                    color: active
                        ? AppColors.teal
                        : AppColors.primary.withOpacity(0.12),
                  ),
                );
              }

              final dotIndex = index ~/ 2;
              final active = dotIndex <= currentIndex;

              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.teal : Colors.transparent,
                  border: active
                      ? null
                      : Border.all(
                          color: AppColors.primary.withOpacity(0.25),
                          width: 2,
                        ),
                ),
                child: active
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: labels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: label == 'GOLD'
                            ? AppColors.teal
                            : AppColors.textPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EBE6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InquiryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _InquiryItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EBE6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRewardCard extends StatelessWidget {
  final MenuItem menu;

  const _MenuRewardCard({required this.menu});

  void _openRedeemSheet() {
    final appState = Get.find<AppStateController>();

    if (!appState.canRedeemToday()) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Reward Tidak Tersedia',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Kamu sudah menukar 1 reward hari ini. Silakan coba lagi besok.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tutup')),
          ],
        ),
      );
      return;
    }

    Get.bottomSheet(
      MenuDetailSheet(
        controller: MenuDetailController(item: menu, isRedeemMode: true),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = LoyaltyScreen._rewardPointsFromPrice(menu.price);

    return GestureDetector(
      onTap: _openRedeemSheet,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EBE6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: menu.imageUrl.trim().isEmpty
                  ? Container(
                      height: 72,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : menu.imageUrl.startsWith('http')
                  ? Image.network(
                      menu.imageUrl,
                      height: 72,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 72,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      menu.imageUrl,
                      height: 72,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 72,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              menu.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${Formatters.commas(points)} poin',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

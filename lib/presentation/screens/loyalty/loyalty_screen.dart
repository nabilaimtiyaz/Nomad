import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../controllers/menu/menu_controller.dart';
import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/user_model.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  static const _tiers = [
    ('silver', 'Silver', '1 poin / Rp1.000'),
    ('gold', 'Gold', '2 poin / Rp1.000'),
    ('platinum', 'Platinum', '3 poin / Rp1.000'),
  ];

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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _TopBar(user: user),
                const SizedBox(height: 20),

                /// HEADER POIN TETAP
                _PointsCard(points: points, tier: tierLabel),

                const SizedBox(height: 28),

                /// STATUS PATH
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Status Path',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showBenefitsInfo,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View Benefits',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tier == 'platinum'
                      ? 'Kamu sudah berada di Platinum status'
                      : tier == 'gold'
                      ? '$remainingToPlatinum koin to Platinum status'
                      : '$remainingToGold koin to Gold status',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _StatusPathCard(currentTier: tier),

                const SizedBox(height: 30),

                /// CURATED EARNING
                const Text(
                  'Curated Earning',
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
                        title: 'Earn Daily',
                        subtitle: 'Lihat cara mendapatkan poin loyalty Nomad.',
                        icon: Icons.shopping_bag_outlined,
                        iconColor: AppColors.teal,
                        onTap: _showEarnInfo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        title: 'Instant Value',
                        subtitle:
                            'Gunakan poin saat checkout sebagai alat bayar.',
                        icon: Icons.card_giftcard_rounded,
                        iconColor: AppColors.primary,
                        onTap: _showUsePointsInfo,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                /// MENU BASED REWARDS
                const Text(
                  'Nomad Menu in Points',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final menus = menuController.menus;

                  if (menuController.isLoading.value) {
                    return const SizedBox(
                      height: 140,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (menus.isEmpty) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Menu belum tersedia',
                          style: TextStyle(color: AppColors.textSecondary),
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
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 155,
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

                const SizedBox(height: 30),

                /// INQUIRIES
                const Text(
                  'Inquiries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _InquiryItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Cara Mendapatkan Poin',
                  onTap: _showEarnInfo,
                ),
                _InquiryItem(
                  icon: Icons.payments_outlined,
                  title: 'Cara Menggunakan Poin',
                  onTap: _showUsePointsInfo,
                ),
                _InquiryItem(
                  icon: Icons.discount_outlined,
                  title: 'Aturan Voucher & Poin',
                  onTap: _showVoucherInfo,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showBenefitsInfo() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: const Text(
          'Tier loyalty Nomad:\n\n'
          '• Silver: 1 poin / Rp1.000\n'
          '• Gold: 2 poin / Rp1.000\n'
          '• Platinum: 3 poin / Rp1.000\n\n'
          'Naik tier berdasarkan total poin yang pernah didapatkan.',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
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
          '• Silver: 1 poin / Rp1.000\n'
          '• Gold: 2 poin / Rp1.000\n'
          '• Platinum: 3 poin / Rp1.000\n\n'
          'Poin didapat dari transaksi yang memenuhi syarat loyalty Nomad.\n'
          'Jika menggunakan voucher atau poin, transaksi tidak mendapatkan poin baru.',
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
          '• 1 poin = Rp1\n'
          '• Poin digunakan saat checkout sebagai alat bayar\n'
          '• Berlaku untuk subtotal produk\n'
          '• Tidak berlaku untuk ongkir\n'
          '• Tidak memberi diskon tambahan',
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
          '• Voucher dan poin tidak bisa digunakan bersamaan\n'
          '• Jika pakai voucher, tidak mendapatkan poin baru\n'
          '• Jika pakai poin, tidak mendapatkan poin baru',
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

class _PointsCard extends StatelessWidget {
  final int points;
  final String tier;

  const _PointsCard({required this.points, required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$tier • 1 poin = Rp1',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final points = menu.price;

    return Container(
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
            '${Formatters.commas(points)} pts',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

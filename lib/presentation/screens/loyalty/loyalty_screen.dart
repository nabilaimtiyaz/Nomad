import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/app_state.dart';
import '../../../data/models/user_model.dart';

// LoyaltyScreen — menampilkan poin, tier, dan opsi redeem.
// Perubahan: semua data diambil dari AppState (bukan dummy statis),
// tombol Redeem benar-benar mengurangi saldo poin via appState.redeemPoints()
class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  static const _tiers = [
    (
      'silver',
      'Silver',
      500,
      '★',
      '1.2× Point Multiplier\nBirthday Reward',
      false,
    ),
    (
      'gold',
      'Gold',
      2000,
      '◆',
      '1.5× Point Multiplier\nPriority Reservations\nFree Monthly Drink',
      true,
    ),
    (
      'platinum',
      'Platinum',
      5000,
      '✦',
      '2× Point Multiplier\nConcierge Service\nExclusive Event Access',
      false,
    ),
  ];

  static const _redeems = [
    (
      'Artisan Coffee',
      'Any handcrafted beverage, any size.',
      500,
      Icons.coffee_rounded,
    ),
    (
      'Signature Beans',
      'Choice of single origin or house blend.',
      2000,
      Icons.grain_rounded,
    ),
    (
      'Morning Pastry',
      'Freshly baked in-house daily.',
      350,
      Icons.breakfast_dining,
    ),
    (
      'Nomad Vessel',
      'Limited edition ceramic tumbler.',
      4500,
      Icons.sports_bar_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStateController>(
      builder: (appState) {
        final user = appState.user;
        final pts = user.loyaltyPoints;
        final tier = user.membershipTier;
        const maxPts = 3000;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                title: const Text(
                  'Nomad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: const NetworkImage(
                        'https://i.pravatar.cc/80?img=5',
                      ),
                      backgroundColor: AppColors.surfaceGrey,
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Kartu saldo
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientLoyalty,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.commas(pts),
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'pts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${UserModel.getTierLabel(tier)} Status',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${Formatters.commas(maxPts - pts.clamp(0, maxPts))} pts to Platinum',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (pts / maxPts).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'GOLD',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'PLATINUM',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status Tiers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Tiers',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'View All Perks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    ..._tiers.map((t) {
                      final (id, name, _, icon, benefits, __) = t;
                      final isCurrent = id == tier;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.tealLight
                              : AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.teal
                                : Colors.transparent,
                            width: isCurrent ? 1.5 : 0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.teal.withOpacity(0.15)
                                    : AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isCurrent
                                        ? AppColors.teal
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isCurrent
                                              ? AppColors.teal
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.teal,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'CURRENT',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    benefits,
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.5,
                                      color: isCurrent
                                          ? AppColors.teal
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Redeem section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Redeem',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Your points, your choice.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: _redeems.map((r) {
                        final (name, desc, ptsNeeded, icon) = r;
                        final canRedeem = pts >= ptsNeeded;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          icon,
                                          size: 52,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.dark,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${Formatters.commas(ptsNeeded)} PTS',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      desc,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // Tombol Redeem — aktif/disabled berdasarkan saldo
                                    SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                        onTap: canRedeem
                                            ? () => _confirmRedeem(
                                                context,
                                                appState,
                                                name,
                                                ptsNeeded,
                                              )
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: canRedeem
                                                ? AppColors.primary
                                                : AppColors.divider,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              canRedeem
                                                  ? 'Redeem'
                                                  : 'Poin kurang',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: canRedeem
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
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
                        );
                      }).toList(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // _confirmRedeem — dialog konfirmasi sebelum kurangi poin
  void _confirmRedeem(
    BuildContext context,
    AppStateController appState,
    String rewardName,
    int ptsNeeded,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Redeem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tukar $ptsNeeded poin untuk mendapatkan "$rewardName"?\n\nSaldo poin setelah: ${appState.user.loyaltyPoints - ptsNeeded} poin',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = appState.redeemPoints(ptsNeeded);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '✓ $ptsNeeded poin berhasil ditukar untuk $rewardName!'
                        : 'Saldo poin tidak cukup',
                  ),
                  backgroundColor: success ? AppColors.teal : AppColors.error,
                ),
              );
            },
            child: const Text(
              'Tukar',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_model.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  static const _tiers = [
    ('bronze', 'Bronze', 0, '1×  Poin per transaksi'),
    ('silver', 'Silver', 500, '1.2×  Poin per transaksi'),
    ('gold', 'Gold', 2000, '1.5×  Poinper transaksik'),
    ('platinum', 'Platinum', 5000, '2×  Poin    per transaksis'),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppStateNotifier>(
      builder: (appState) {
        final user = appState.user;
        final coins = user.loyaltyPoints;
        final tier = user.membershipTier;
        final earned = user.totalEarnedPoints;
        final tierIdx = _tiers.indexWhere((t) => t.$1 == tier);
        final nextTier = tierIdx < _tiers.length - 1
            ? _tiers[tierIdx + 1]
            : null;
        final curMin = _tiers[tierIdx].$3;
        final nextMin = nextTier?.$3 ?? curMin;
        final progress = nextTier != null
            ? ((earned - curMin) / (nextMin - curMin)).clamp(0.0, 1.0)
            : 1.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Rewards',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryDark,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Kartu saldo utama ────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientHeader,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'TIER: ${UserModel.getTierLabel(tier).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Your Privileges',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Exclusive access to member benefits.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Saldo poin
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.commas(coins),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Pts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Progress bar
                          if (nextTier != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress to ${nextTier.$2}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${nextMin - earned} pts left',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tier.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  nextTier.$2.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 1.0,
                                minHeight: 7,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Platinum — Tier tertinggi',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Membership Tiers ─────────────────────────────────
                    const Text(
                      'Membership Tiers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ..._tiers.map((t) {
                      final (id, name, minPts, benefit) = t;
                      final isCurrent = id == tier;
                      final isUnlocked = earned >= minPts;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.tealLight
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.teal
                                : AppColors.cardBorder,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.teal.withOpacity(0.15)
                                    : AppColors.surfaceGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isUnlocked
                                    ? Icons.workspace_premium_rounded
                                    : Icons.lock_rounded,
                                size: 20,
                                color: isCurrent
                                    ? AppColors.teal
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14,
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
                                            'ACTIVE',
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
                                    benefit,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: isCurrent
                                          ? AppColors.teal
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              minPts == 0
                                  ? 'Default'
                                  : '${Formatters.commas(minPts)}+',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? AppColors.teal
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

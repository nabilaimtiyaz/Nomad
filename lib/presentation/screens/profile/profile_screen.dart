import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/app_state.dart';
import '../../../data/models/user_model.dart';
import 'edit_profile_screen.dart';
import '../order/order_history_screen.dart';
import '../voucher/voucher_screen.dart';
import '../loyalty/loyalty_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfileScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateProvider.of(context),
      builder: (context, _) {
        final user = AppStateProvider.of(context).user;
        final tier = user.membershipTier;
        final tierLabel = UserModel.getTierLabel(tier);
        final pts = user.loyaltyPoints;
        const nextTierPts = 1500;
        final progress = (pts / nextTierPts).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(children: [

              // ── Header merah dengan avatar ───────────────────────────
              Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientHeader),
                child: SafeArea(
                  bottom: false,
                  child: Column(children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(children: [
                        const Icon(Icons.menu_rounded, size: 22, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text('Nomad', style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryDark,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ]),
                    ),

                    // Avatar + nama
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryDark,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
                          style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(user.name, style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 6),

                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('${tierLabel.toUpperCase()} MEMBER',
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 0.8)),
                      ]),
                    ),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [

                  // ── Balance card ──────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoyaltyScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16, offset: const Offset(0, 4))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('CURRENT BALANCE', style: TextStyle(
                                fontSize: 10, letterSpacing: 1.2,
                                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(Formatters.commas(pts), style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary, height: 1)),
                                const SizedBox(width: 6),
                                const Padding(padding: EdgeInsets.only(bottom: 4),
                                  child: Text('Pts', style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary))),
                              ]),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              const Text('NEXT TIER', style: TextStyle(
                                fontSize: 10, letterSpacing: 1,
                                color: AppColors.teal, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              const Text('Gold Status', style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: AppColors.surfaceGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${Formatters.commas(1000)} Silver', style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                          Text('${Formatters.commas(nextTierPts)} Gold', style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                        ]),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Account Settings label ────────────────────────────
                  const Align(alignment: Alignment.centerLeft,
                    child: Text('ACCOUNT SETTINGS', style: TextStyle(
                      fontSize: 10, letterSpacing: 1.5,
                      color: AppColors.textSecondary, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 12),

                  // ── Menu items ─────────────────────────────────────────
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Personal Information',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Order History',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
                  ),
                  _MenuItem(
                    icon: Icons.payment_rounded,
                    label: 'Payment Methods',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Segera hadir!'))),
                  ),
                  _MenuItem(
                    icon: Icons.local_offer_outlined,
                    label: 'Vouchers & Offers',
                    badge: '2 NEW',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoucherScreen())),
                  ),

                  const SizedBox(height: 28),

                  // ── Logout button ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                          title: const Text('Keluar?',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('Kamu akan keluar dari akun ini.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal',
                                style: TextStyle(color: AppColors.textSecondary))),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onLogout?.call();
                              },
                              child: const Text('LOGOUT',
                                style: TextStyle(
                                  color: AppColors.primary, fontWeight: FontWeight.w800))),
                          ],
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('LOGOUT', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppColors.primary, letterSpacing: 1.2)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(child: Text('NOMAD BREW v4.2.0 • BUILT FOR JOURNEY',
                    style: TextStyle(fontSize: 10,
                      color: AppColors.textHint, letterSpacing: 0.5))),
                  const SizedBox(height: 8),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary))),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20)),
              child: Text(badge!, style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

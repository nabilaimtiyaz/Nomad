import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/app_state.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _requireLogin() {
    Get.defaultDialog(
      title: 'Login Diperlukan',
      middleText: 'Kamu harus login dulu untuk mengakses fitur ini.',
      textConfirm: 'Login',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        Get.toNamed(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        final pts = user.loyaltyPoints;
        final tierLabel = user.membershipTier;
        const nextTierPts = 2500;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientHeader,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.menu_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Nomad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  if (isLoggedIn) {
                                    Get.toNamed(AppRoutes.editProfile);
                                  } else {
                                    _requireLogin();
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryDark,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'N',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.primaryDark,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'N',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${tierLabel.toUpperCase()} MEMBER',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.loyalty),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CURRENT BALANCE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 1,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            Formatters.commas(pts),
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              'Pts',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'NEXT TIER',
                                        style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 1,
                                          color: AppColors.teal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Gold Status',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (pts / nextTierPts).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: AppColors.surfaceGrey,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${Formatters.commas(1000)} SILVER',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${Formatters.commas(nextTierPts)} GOLD',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ACCOUNT SETTINGS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _item(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        sub: isLoggedIn
                            ? '${user.name}  •  ${user.phone}'
                            : 'Login dulu untuk mengakses',
                        onTap: () {
                          if (isLoggedIn) {
                            Get.toNamed(AppRoutes.editProfile);
                          } else {
                            _requireLogin();
                          }
                        },
                      ),
                      _item(
                        icon: Icons.receipt_long_outlined,
                        label: 'Order History',
                        sub: 'Lihat semua pesanan',
                        onTap: () => Get.toNamed(AppRoutes.orderHistory),
                      ),
                      _item(
                        icon: Icons.payment_rounded,
                        label: 'Payment Methods',
                        sub: 'Kelola metode bayar',
                        onTap: () => Get.snackbar(
                          'Info',
                          'Segera hadir!',
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      ),
                      _item(
                        icon: Icons.discount_outlined,
                        label: 'Vouchers & Offers',
                        badge: '2 NEW',
                        onTap: () => Get.toNamed(AppRoutes.voucher),
                      ),
                      _item(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        sub: 'Promo, reminder, update pesanan',
                        onTap: () => Get.snackbar(
                          'Info',
                          'Segera hadir!',
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      ),
                      _item(
                        icon: Icons.help_outline_rounded,
                        label: 'Bantuan & FAQ',
                        onTap: () => Get.snackbar(
                          'Info',
                          'Segera hadir!',
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.defaultDialog(
                            title: 'Keluar?',
                            middleText: 'Kamu akan keluar dari akun ini.',
                            textConfirm: 'LOGOUT',
                            textCancel: 'Batal',
                            confirmTextColor: Colors.white,
                            buttonColor: AppColors.primary,
                            onConfirm: () {
                              Get.back();
                              appState.logout();
                              Get.offAllNamed(AppRoutes.login);
                            },
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'NOMAD BREW v4.2.0 • BUILT FOR JOURNEY',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            letterSpacing: 0.5,
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

  Widget _item({
    required IconData icon,
    required String label,
    String? sub,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
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

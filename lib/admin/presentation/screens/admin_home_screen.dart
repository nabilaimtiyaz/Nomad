import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_home_controller.dart';
import '../../core/routes/admin_routes.dart';

class AdminHomeScreen extends GetView<AdminHomeController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      body: Obx(() {
        final isLoading = controller.isLoading.value;

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              const _DashboardTopBar(),
              const SizedBox(height: 22),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _RevenueHeroCard(
                  revenue: controller.formatRupiah(
                    controller.todayRevenue.value,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        title: 'Total Members',
                        value: controller.totalMembers.value.toString(),
                        icon: Icons.people_outline_rounded,
                        accent: const Color(0xFF0F8B7D),
                        trailingText: '85%',
                        progress: 0.85,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _CompactInfoCard(
                            title: 'Available Menus',
                            value: controller.totalMenusAvailable.value
                                .toString(),
                            icon: Icons.restaurant_menu_rounded,
                            iconBg: const Color(0xFFFCE9EA),
                            iconColor: const Color(0xFFC1121F),
                          ),
                          const SizedBox(height: 12),
                          _CompactInfoCard(
                            title: 'Active Vouchers',
                            value: controller.activeVouchers.value.toString(),
                            icon: Icons.confirmation_number_outlined,
                            iconBg: const Color(0xFFFFF3D6),
                            iconColor: const Color(0xFFC28A00),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                _SectionTitle(title: 'Quick Shortcuts'),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.25,
                  children: [
                    _ShortcutCard(
                      label: 'Orders',
                      icon: Icons.receipt_long_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.orders),
                    ),
                    _ShortcutCard(
                      label: 'Menus',
                      icon: Icons.restaurant_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.menus),
                    ),
                    _ShortcutCard(
                      label: 'Branches',
                      icon: Icons.storefront_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.branches),
                    ),
                    _ShortcutCard(
                      label: 'Vouchers',
                      icon: Icons.confirmation_number_rounded,
                      onTap: () => controller.openMenu(AdminRoutes.vouchers),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _WideShortcutCard(
                  label: 'Members',
                  icon: Icons.people_alt_outlined,
                  onTap: () => controller.openMenu(AdminRoutes.members),
                ),
                const SizedBox(height: 26),

                const _PeakHoursSection(),
                const SizedBox(height: 22),

                _TopMenuSection(
                  pending: controller.pendingOrders.value,
                  processing: controller.processingOrders.value,
                  ready: controller.readyOrders.value,
                  done: controller.doneOrdersToday.value,
                ),
              ],
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD62828),
        elevation: 2,
        onPressed: () => controller.openMenu(AdminRoutes.orders),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _AdminBottomBar(
        onTapDashboard: () {},
        onTapOrders: () => controller.openMenu(AdminRoutes.orders),
        onTapMenus: () => controller.openMenu(AdminRoutes.menus),
        onTapBranches: () => controller.openMenu(AdminRoutes.branches),
        onTapMembers: () => controller.openMenu(AdminRoutes.members),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.menu_rounded, size: 28, color: Colors.black87),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Nomad Coffee',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB1121C),
            ),
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB1121C), width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class _RevenueHeroCard extends StatelessWidget {
  final String revenue;

  const _RevenueHeroCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFFD10012), Color(0xFFB30016)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: 8,
            child: Container(
              width: 110,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: Colors.white24,
                size: 56,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REVENUE HARI INI',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                revenue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF69F0AE),
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '24% increase from yesterday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String trailingText;
  final double progress;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.trailingText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6F4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE3E3E3),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _CompactInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1.2, color: const Color(0xFFE0DAD6))),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFEF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: const Color(0xFFD62828)),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideShortcutCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _WideShortcutCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFEF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: const Color(0xFFD62828)),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeakHoursSection extends StatelessWidget {
  const _PeakHoursSection();

  @override
  Widget build(BuildContext context) {
    const labels = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Peak Hours\nAnalysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECE8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Bar(value: 0.32),
                _Bar(value: 0.48),
                _Bar(value: 0.78),
                _Bar(value: 0.58),
                _Bar(value: 0.92),
                _Bar(value: 0.64),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (e) => Text(
                    e,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9A9A9A),
                      fontWeight: FontWeight.w700,
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

class _Bar extends StatelessWidget {
  final double value;

  const _Bar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 120 * value,
          decoration: BoxDecoration(
            color: const Color(0xFFD62828),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _TopMenuSection extends StatelessWidget {
  final int pending;
  final int processing;
  final int ready;
  final int done;

  const _TopMenuSection({
    required this.pending,
    required this.processing,
    required this.ready,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Nomad Signature Latte', pending, '#1'),
      ('Creamy Cold Brew', processing, '#2'),
      ('Artisan Croissant', ready, '#3'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Menu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=300&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.$2 + done} sold today',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.$3,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD62828),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  final VoidCallback onTapDashboard;
  final VoidCallback onTapOrders;
  final VoidCallback onTapMenus;
  final VoidCallback onTapBranches;
  final VoidCallback onTapMembers;

  const _AdminBottomBar({
    required this.onTapDashboard,
    required this.onTapOrders,
    required this.onTapMenus,
    required this.onTapBranches,
    required this.onTapMembers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0E7E2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            label: 'DASHBOARD',
            icon: Icons.grid_view_rounded,
            active: true,
            onTap: onTapDashboard,
          ),
          _BottomItem(
            label: 'ORDERS',
            icon: Icons.receipt_long_rounded,
            onTap: onTapOrders,
          ),
          _BottomItem(
            label: 'MENUS',
            icon: Icons.restaurant_rounded,
            onTap: onTapMenus,
          ),
          _BottomItem(
            label: 'BRANCHES',
            icon: Icons.storefront_rounded,
            onTap: onTapBranches,
          ),
          _BottomItem(
            label: 'MEMBERS',
            icon: Icons.people_alt_outlined,
            onTap: onTapMembers,
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _BottomItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    if (active) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFD62828),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 21),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black45, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
          
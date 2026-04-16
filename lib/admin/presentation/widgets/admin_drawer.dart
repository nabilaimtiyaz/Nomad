import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/admin_routes.dart';
import '../../../user/core/app_state.dart';
import '../../../user/core/routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Get.find<AppStateController>();
    final currentRoute = Get.currentRoute;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomad Admin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.isLoggedIn ? appState.user.email : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _item(
              title: 'Dashboard',
              route: AdminRoutes.home,
              selected: currentRoute == AdminRoutes.home,
            ),
            _item(
              title: 'Orders',
              route: AdminRoutes.orders,
              selected: currentRoute == AdminRoutes.orders ||
                  currentRoute == AdminRoutes.orderDetail,
            ),
            _item(
              title: 'Menus',
              route: AdminRoutes.menus,
              selected: currentRoute == AdminRoutes.menus ||
                  currentRoute == AdminRoutes.menuForm,
            ),
            _item(
              title: 'Branches',
              route: AdminRoutes.branches,
              selected: currentRoute == AdminRoutes.branches ||
                  currentRoute == AdminRoutes.branchForm,
            ),
            _item(
              title: 'Vouchers',
              route: AdminRoutes.vouchers,
              selected: currentRoute == AdminRoutes.vouchers ||
                  currentRoute == AdminRoutes.voucherForm,
            ),
            _item(
              title: 'Members',
              route: AdminRoutes.members,
              selected: currentRoute == AdminRoutes.members,
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                Get.back();
                appState.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required String title,
    required String route,
    required bool selected,
  }) {
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.black.withOpacity(0.06),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      onTap: () {
        Get.back();
        if (Get.currentRoute != route) {
          Get.offNamed(route);
        }
      },
    );
  }
}
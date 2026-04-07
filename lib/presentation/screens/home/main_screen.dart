import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../loyalty/loyalty_screen.dart';
import '../menu/menu_screen.dart';
import '../order/order_history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  void _onQty(String id, int delta) {
    AppStateProvider.of(context).changeMenuQty(id, delta);
  }

  void _onAdd(MenuItem item) {
    AppStateProvider.of(context).addSimpleItem(item);
  }

  void _onAddDetail(MenuItem item, int qty, String notes) {
    AppStateProvider.of(context).upsertDetailedItem(item, qty, notes);
  }

  void _onBranch(Branch branch) {
    final appState = AppStateProvider.of(context);
    final selected = appState.selectedBranch;
    final hasCart = appState.cartItems.isNotEmpty;

    if (selected != null && selected.id != branch.id && hasCart) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Ganti Cabang?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Mengganti cabang akan mengosongkan keranjangmu saat ini. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                appState.selectBranch(branch, clearCart: true);
              },
              child: const Text('Ganti', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      return;
    }

    appState.selectBranch(branch);
  }

  void _openCart() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  String _fmtPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final screens = [
          HomeScreen(
            selectedBranch: appState.selectedBranch,
            onBranchSelected: _onBranch,
            onNavigateToMenu: () => setState(() => _idx = 1),
            onAddToCart: _onAdd,
            onAddToCartWithDetail: _onAddDetail,
            onQtyChanged: _onQty,
            cart: appState.cartPreviewByMenu,
            onOpenCart: _openCart,
          ),
          MenuScreen(
            selectedBranch: appState.selectedBranch,
            onBranchSelected: _onBranch,
            cart: appState.cartPreviewByMenu,
            onAddToCart: _onAdd,
            onAddToCartWithDetail: _onAddDetail,
            onQtyChanged: _onQty,
            onOpenCart: _openCart,
          ),
          const LoyaltyScreen(),
          const OrderHistoryScreen(),
          ProfileScreen(
            onLogout: () {
              appState.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ];

        const tabs = [
          ('Home', Icons.home_outlined, Icons.home_rounded),
          ('Menu', Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded),
          ('Rewards', Icons.workspace_premium_outlined, Icons.workspace_premium_rounded),
          ('Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
          ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
        ];

        return Scaffold(
          body: IndexedStack(index: _idx, children: screens),
          floatingActionButton: appState.cartCount > 0
              ? FloatingActionButton.extended(
                  onPressed: _openCart,
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                  label: Text(
                    '${appState.cartCount} item  •  Rp ${_fmtPrice(appState.cartTotal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                )
              : null,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final active = _idx == i;
                    final (label, iconOff, iconOn) = tabs[i];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _idx = i),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active ? iconOn : iconOff,
                              size: 22,
                              color: active ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: active ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

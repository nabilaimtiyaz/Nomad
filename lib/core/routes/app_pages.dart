import 'package:get/get.dart';

import '../../controllers/auth/login_controller.dart';
import '../../controllers/auth/register_controller.dart';
import '../../controllers/loyalty/loyalty_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../controllers/splash/splash_controller.dart';
import '../../controllers/voucher/voucher_controller.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/loyalty/loyalty_screen.dart';
import '../../presentation/screens/order/order_history_screen.dart';
import '../../presentation/screens/order/order_status_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/voucher/voucher_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SplashController>()) {
          Get.put(SplashController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LoginController>()) {
          Get.put(LoginController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RegisterController>()) {
          Get.put(RegisterController());
        }
      }),
    ),
    GetPage(name: AppRoutes.home, page: () => const MainScreen()),
    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
    GetPage(name: AppRoutes.orderStatus, page: () => const OrderStatusScreen()),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.loyalty,
      page: () => const LoyaltyScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LoyaltyController>()) {
          Get.put(LoyaltyController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.voucher,
      page: () => const VoucherScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<VoucherController>()) {
          Get.put(VoucherController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryScreen(),
    ),
  ];
}

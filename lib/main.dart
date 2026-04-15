import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/auth/login_controller.dart';
import 'controllers/auth/register_controller.dart';
import 'controllers/cart/cart_controller.dart';
import 'controllers/home/home_controller.dart';
import 'controllers/home/main_controller.dart';
import 'controllers/menu/menu_controller.dart';
import 'controllers/order/order_controller.dart';
import 'core/app_state.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  if (!Get.isRegistered<CartController>()) {
    Get.put<CartController>(CartController(), permanent: true);
  }

  if (!Get.isRegistered<AppStateController>()) {
    Get.put<AppStateController>(AppStateController(), permanent: true);
  }

  if (!Get.isRegistered<LoginController>()) {
    Get.put<LoginController>(LoginController(), permanent: true);
  }

  if (!Get.isRegistered<RegisterController>()) {
    Get.put<RegisterController>(RegisterController(), permanent: true);
  }

  if (!Get.isRegistered<MainController>()) {
    Get.put<MainController>(MainController(), permanent: true);
  }

  if (!Get.isRegistered<HomeController>()) {
    Get.put<HomeController>(HomeController(), permanent: true);
  }

  if (!Get.isRegistered<MenuController>()) {
    Get.put<MenuController>(MenuController(), permanent: true);
  }

  if (!Get.isRegistered<OrderController>()) {
    Get.put<OrderController>(OrderController(), permanent: true);
  }

  runApp(const NomadApp());
}

class NomadApp extends StatelessWidget {
  const NomadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kedai Nomad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}

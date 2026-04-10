import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_state.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_pages.dart';

// 🔥 TAMBAH IMPORT
import 'controllers/auth/login_controller.dart';
import 'controllers/auth/register_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 🔥 FIX: REGISTER CONTROLLER GLOBAL
  Get.put<AppStateController>(AppStateController(), permanent: true);
  Get.put<LoginController>(LoginController(), permanent: true);
  Get.put<RegisterController>(RegisterController(), permanent: true);

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

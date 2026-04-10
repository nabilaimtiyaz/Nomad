import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // kasih jeda kecil biar animasi splash tetap sempat tampil
      await Future.delayed(const Duration(milliseconds: 2600));

      if (isClosed) return;

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null && session.user != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      if (!isClosed) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}

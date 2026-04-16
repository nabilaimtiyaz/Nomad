import 'package:get/get.dart';

import '../controllers/admin_member_controller.dart';

class AdminMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMemberController>(() => AdminMemberController());
  }
}
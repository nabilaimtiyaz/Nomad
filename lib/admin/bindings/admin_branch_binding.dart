import 'package:get/get.dart';

import '../controllers/admin_branch_controller.dart';

class AdminBranchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBranchController>(() => AdminBranchController());
  }
}
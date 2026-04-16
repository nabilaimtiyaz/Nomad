import 'package:get/get.dart';

import '../controllers/admin_voucher_controller.dart';

class AdminVoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminVoucherController>(() => AdminVoucherController());
  }
}
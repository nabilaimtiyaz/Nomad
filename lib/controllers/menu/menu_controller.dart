import 'package:get/get.dart';
import '../../core/app_state.dart';
import '../../data/datasources/menu_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuController extends GetxController {
  final MenuRepository repo = MenuRepository(MenuRemote());
  final appState = Get.find<AppStateController>();

  final menus = <MenuItem>[].obs;
  final isLoading = false.obs;
  final selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedCategoryId, (_) => fetchMenus());
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    final branch = appState.selectedBranch;
    if (branch == null) return;

    try {
      isLoading.value = true;

      final result = await repo.getMenus(
        branchId: branch.id,
        categoryId: selectedCategoryId.value,
      );

      menus.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String id) {
    selectedCategoryId.value = id;
  }
}
import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/menu_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuController extends GetxController {
  final MenuRepository repo = MenuRepository(MenuRemote());
  final AppStateController appState = Get.find<AppStateController>();

  final menus = <MenuItem>[].obs;
  final categories = <Category>[].obs;
  final isLoading = false.obs;
  final selectedCategoryId = 'all'.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedCategoryId, (_) => fetchMenus());
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchCategories();
    await fetchMenus();
  }

  Future<void> fetchCategories() async {
    try {
      final result = await repo.getCategories();
      categories.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> fetchMenus() async {
    final branch = appState.selectedBranch;
    if (branch == null) {
      menus.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repo.getMenus(
        branchId: branch.id,
        categoryId: selectedCategoryId.value,
      );

      menus.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      menus.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String id) {
    selectedCategoryId.value = id;
  }

  Future<void> reloadForBranchChange() async {
    await fetchMenus();
  }
}
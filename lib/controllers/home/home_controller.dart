import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/branch_remote.dart';
import '../../data/datasources/menu_remote.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/branch_repository.dart';
import '../../data/repositories/menu_repository.dart';

class HomeController extends GetxController {
  final BranchRepository branchRepository;
  final MenuRepository menuRepository;

  HomeController({
    BranchRepository? branchRepository,
    MenuRepository? menuRepository,
  })  : branchRepository = branchRepository ?? BranchRepository(BranchRemote()),
        menuRepository = menuRepository ?? MenuRepository(MenuRemote());

  final AppStateController appState = Get.find<AppStateController>();

  final RxBool isLoading = true.obs;
  final RxBool isRefreshingMenus = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Branch> branches = <Branch>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<MenuItem> featuredMenus = <MenuItem>[].obs;

  final Rxn<Branch> selectedBranch = Rxn<Branch>();
  final RxString selectedCategoryId = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedBranches = await branchRepository.getBranches();
      final fetchedCategories = await menuRepository.getCategories();

      branches.assignAll(fetchedBranches);
      categories.assignAll(fetchedCategories);

      if (branches.isNotEmpty) {
        final currentBranchId = appState.selectedBranch?.id;
        final initialBranch = branches.firstWhereOrNull(
              (branch) => branch.id == currentBranchId,
            ) ??
            branches.first;

        selectedBranch.value = initialBranch;
        appState.setBranch(initialBranch);
      } else {
        selectedBranch.value = null;
      }

      await loadFeaturedMenus();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFeaturedMenus() async {
    final branch = selectedBranch.value;
    if (branch == null) {
      featuredMenus.clear();
      return;
    }

    try {
      isRefreshingMenus.value = true;
      errorMessage.value = '';

      final menus = await menuRepository.getFeaturedMenus(
        branchId: branch.id,
        categoryId: selectedCategoryId.value,
        limit: 4,
      );

      featuredMenus.assignAll(menus);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      featuredMenus.clear();
    } finally {
      isRefreshingMenus.value = false;
    }
  }

  Future<void> selectBranch(Branch branch) async {
    if (!branch.isOpen) return;

    selectedBranch.value = branch;
    appState.setBranch(branch);
    await loadFeaturedMenus();
  }

  Future<void> selectCategory(String categoryId) async {
    selectedCategoryId.value = categoryId;
    await loadFeaturedMenus();
  }

  int qtyForMenu(String menuId) {
    int total = 0;
    for (final item in appState.cartItems) {
      if (item.menuItem.id == menuId) {
        total += item.qty;
      }
    }
    return total;
  }

  IconData iconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('coffee') || name.contains('kopi')) {
      return Icons.local_cafe_rounded;
    }
    if (name.contains('tea') || name.contains('teh')) {
      return Icons.emoji_food_beverage_rounded;
    }
    if (name.contains('food') || name.contains('makanan')) {
      return Icons.fastfood_rounded;
    }
    if (name.contains('snack')) {
      return Icons.cookie_rounded;
    }
    if (name.contains('dessert')) {
      return Icons.cake_rounded;
    }
    return Icons.restaurant_menu_rounded;
  }
}
import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/menu_remote.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/menu_repository.dart';

class MenuController extends GetxController {
  final MenuRepository repo = MenuRepository(MenuRemote());
  final AppStateController appState = Get.find<AppStateController>();

  final _allMenus = <MenuItem>[].obs;
  final menus = <MenuItem>[].obs;
  final categories = <Category>[].obs;

  final isLoading = false.obs;
  final selectedType = 'all'.obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;

  String? _lastLoadedBranchId;

  @override
  void onInit() {
    super.onInit();
    everAll([selectedType, searchQuery], (_) => _applyFilters());
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
      errorMessage.value = "Error Kategori: ${e.toString()}";
    }
  }

  Future<void> fetchMenus() async {
    final branch = appState.selectedBranch;
    if (branch == null) {
      errorMessage.value = '';
      menus.clear();
      _allMenus.clear();
      return;
    }

    if (_lastLoadedBranchId == branch.id && _allMenus.isNotEmpty) {
      _applyFilters();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repo.getMenus(branchId: branch.id);

      _lastLoadedBranchId = branch.id;
      _allMenus.assignAll(result);
      _applyFilters();
    } catch (e) {
      errorMessage.value = "Error Ambil Data: ${e.toString()}";
      _allMenus.clear();
      menus.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    try {
      final query = searchQuery.value.toLowerCase();

      final filtered = _allMenus.where((item) {
        final name = item.name.toLowerCase();
        final desc = item.description.toLowerCase();

        final matchesSearch = name.contains(query) || desc.contains(query);

        bool matchesType = true;
        if (selectedType.value != 'all') {
          matchesType = item.categoryId == selectedType.value;
        }

        return matchesSearch && matchesType;
      }).toList();

      menus.assignAll(filtered);
    } catch (e) {
      errorMessage.value = "Error Filter Data: ${e.toString()}";
      menus.clear();
    }
  }

  Future<void> reloadForBranchChange() async {
    _lastLoadedBranchId = null;
    await fetchMenus();
  }
}
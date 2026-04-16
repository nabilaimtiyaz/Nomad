import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMenuController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxString selectedCategory = 'all'.obs;

  final RxList<Map<String, dynamic>> menus = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categoriesData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> branchesData =
      <Map<String, dynamic>>[].obs;

  final List<String> categories = const [
    'all',
    'drink',
    'food',
    'snack',
    'dessert',
  ];

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  final RxBool isAvailable = true.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedBranchId = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    imageUrlCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([fetchCategories(), fetchBranches(), fetchMenus()]);
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name');

      categoriesData.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kategori: $e');
    }
  }

  Future<void> fetchBranches() async {
    try {
      final response = await _supabase.from('branches').select().order('name');

      branchesData.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat branch: $e');
    }
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('menu_items')
          .select('''
          id,
          name,
          price,
          image_url,
          is_available,
          category_id,
          branch_id,
          categories(name),
          branches(name)
        ''')
          .order('created_at', ascending: false);

      final raw = List<Map<String, dynamic>>.from(response);

      for (final item in raw) {
        debugPrint('MENU: ${item['name']}');
        debugPrint('IMAGE_URL: ${item['image_url']}');
      }

      if (selectedCategory.value == 'all') {
        menus.assignAll(raw);
      } else {
        menus.assignAll(
          raw.where((item) {
            final categoryData = item['categories'] as Map<String, dynamic>?;
            final categoryName = (categoryData?['name'] ?? '')
                .toString()
                .toLowerCase();
            return categoryName == selectedCategory.value;
          }).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat menu: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCategory(String category) async {
    selectedCategory.value = category;
    await fetchMenus();
  }

  Future<void> toggleAvailability({
    required String menuId,
    required bool currentValue,
  }) async {
    try {
      await _supabase
          .from('menu_items')
          .update({
            'is_available': !currentValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', menuId);

      await fetchMenus();

      Get.snackbar(
        'Berhasil',
        !currentValue ? 'Menu diaktifkan' : 'Menu dinonaktifkan',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal update menu: $e');
    }
  }

  Future<bool> deleteMenu(String menuId) async {
    try {
      await _supabase.from('menu_items').delete().eq('id', menuId);
      await fetchMenus();
      Get.snackbar('Berhasil', 'Menu berhasil dihapus');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus menu: $e');
      return false;
    }
  }

  void clearForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    imageUrlCtrl.clear();
    isAvailable.value = true;
    selectedCategoryId.value = '';
    selectedBranchId.value = '';
  }

  void fillForm(Map<String, dynamic>? menu) {
    if (menu == null) {
      clearForm();
      return;
    }

    nameCtrl.text = (menu['name'] ?? '').toString();
    priceCtrl.text = (menu['price'] ?? 0).toString();
    imageUrlCtrl.text = (menu['image_url'] ?? '').toString();
    isAvailable.value = menu['is_available'] == true;
    selectedCategoryId.value = (menu['category_id'] ?? '').toString();
    selectedBranchId.value = (menu['branch_id'] ?? '').toString();
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      isUploadingImage.value = true;

      final bytes = await pickedFile.readAsBytes();
      final parts = pickedFile.name.split('.');
      final ext = parts.isNotEmpty ? parts.last.toLowerCase() : 'jpg';

      final fileName =
          'menu_${DateTime.now().millisecondsSinceEpoch}.${ext.isEmpty ? 'jpg' : ext}';
      final filePath = 'menus/$fileName';

      await _supabase.storage
          .from('menu-images')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getContentType(ext),
            ),
          );

      final publicUrl = _supabase.storage
          .from('menu-images')
          .getPublicUrl(filePath);

      imageUrlCtrl.text = publicUrl;
      imageUrlCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: imageUrlCtrl.text.length),
      );

      Get.snackbar('Berhasil', 'Foto menu berhasil diupload');
    } catch (e) {
      Get.snackbar('Error', 'Gagal upload gambar: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> saveMenu({String? menuId}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedCategoryId.value.isEmpty) {
      Get.snackbar('Validasi', 'Kategori wajib dipilih');
      return;
    }

    if (selectedBranchId.value.isEmpty) {
      Get.snackbar('Validasi', 'Branch wajib dipilih');
      return;
    }

    try {
      isSubmitting.value = true;
      if (imageUrlCtrl.text.trim().isEmpty) {
        Get.snackbar('Validasi', 'Foto menu belum diupload');
        return;
      }
      final payload = {
        'name': nameCtrl.text.trim(),
        'price': int.tryParse(priceCtrl.text.trim()) ?? 0,
        'image_url': imageUrlCtrl.text.trim(),
        'category_id': selectedCategoryId.value,
        'branch_id': selectedBranchId.value,
        'is_available': isAvailable.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (menuId == null || menuId.isEmpty) {
        await _supabase.from('menu_items').insert(payload);
      } else {
        await _supabase.from('menu_items').update(payload).eq('id', menuId);
      }

      await fetchMenus();
      Get.back();

      Get.snackbar(
        'Berhasil',
        menuId == null || menuId.isEmpty
            ? 'Menu berhasil ditambahkan'
            : 'Menu berhasil diperbarui',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan menu: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}

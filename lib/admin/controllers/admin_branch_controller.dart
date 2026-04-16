import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBranchController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<Map<String, dynamic>> branches = <Map<String, dynamic>>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final openTimeCtrl = TextEditingController();
  final closeTimeCtrl = TextEditingController();

  final RxBool isOpen = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    openTimeCtrl.dispose();
    closeTimeCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchBranches() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('branches')
          .select()
          .order('created_at', ascending: false);

      branches.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat branch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBranch({
    required String branchId,
    required bool currentValue,
  }) async {
    try {
      await _supabase
          .from('branches')
          .update({'is_open': !currentValue})
          .eq('id', branchId);

      await fetchBranches();

      Get.snackbar(
        'Berhasil',
        !currentValue ? 'Branch dibuka' : 'Branch ditutup',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal update branch: $e');
    }
  }

  void fillForm(Map<String, dynamic>? branch) {
    if (branch == null) {
      clearForm();
      return;
    }

    nameCtrl.text = (branch['name'] ?? '').toString();
    addressCtrl.text = (branch['address'] ?? branch['location'] ?? '')
        .toString();
    openTimeCtrl.text = (branch['open_time'] ?? '').toString();
    closeTimeCtrl.text = (branch['close_time'] ?? '').toString();
    isOpen.value = branch['is_open'] == true;
  }

  void clearForm() {
    nameCtrl.clear();
    addressCtrl.clear();
    openTimeCtrl.clear();
    closeTimeCtrl.clear();
    isOpen.value = true;
  }

  Future<void> saveBranch({String? branchId}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isSubmitting.value = true;

      final payload = {
        'name': nameCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'location': addressCtrl.text.trim(),
        'open_time': openTimeCtrl.text.trim(),
        'close_time': closeTimeCtrl.text.trim(),
        'is_open': isOpen.value,
      };

      if (branchId == null || branchId.isEmpty) {
        await _supabase.from('branches').insert(payload);
      } else {
        await _supabase.from('branches').update(payload).eq('id', branchId);
      }

      await fetchBranches();

      Get.back();

      Get.snackbar(
        'Berhasil',
        branchId == null || branchId.isEmpty
            ? 'Branch berhasil ditambahkan'
            : 'Branch berhasil diperbarui',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan branch: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteBranch(String branchId) async {
    try {
      await _supabase.from('branches').delete().eq('id', branchId);
      await fetchBranches();
      Get.snackbar('Berhasil', 'Branch berhasil dihapus');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus branch: $e');
      return false;
    }
  }
}

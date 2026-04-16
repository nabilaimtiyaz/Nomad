import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVoucherController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<Map<String, dynamic>> vouchers = <Map<String, dynamic>>[].obs;

  final formKey = GlobalKey<FormState>();
  final codeCtrl = TextEditingController();
  final discountValueCtrl = TextEditingController();
  final minTransactionCtrl = TextEditingController();
  final expiryDateCtrl = TextEditingController();

  final RxString discountType = 'fixed'.obs;
  final RxBool isActive = true.obs;

  final List<String> discountTypes = const ['fixed', 'percent'];

  @override
  void onInit() {
    super.onInit();
    fetchVouchers();
  }

  @override
  void onClose() {
    codeCtrl.dispose();
    discountValueCtrl.dispose();
    minTransactionCtrl.dispose();
    expiryDateCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchVouchers() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('vouchers')
          .select()
          .order('expiry_date', ascending: false);

      vouchers.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat voucher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleVoucher({
    required String voucherId,
    required bool currentValue,
  }) async {
    try {
      await _supabase
          .from('vouchers')
          .update({'is_active': !currentValue})
          .eq('id', voucherId);

      await fetchVouchers();

      Get.snackbar(
        'Berhasil',
        !currentValue ? 'Voucher diaktifkan' : 'Voucher dinonaktifkan',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal update voucher: $e');
    }
  }

  String formatDiscount(Map<String, dynamic> voucher) {
    final type = (voucher['type'] ?? '').toString().toLowerCase();
    final value = voucher['discount_value'] ?? 0;

    if (type == 'percent') {
      return '$value%';
    }

    return 'Rp$value';
  }

  void clearForm() {
    codeCtrl.clear();
    discountValueCtrl.clear();
    minTransactionCtrl.clear();
    expiryDateCtrl.clear();
    discountType.value = 'fixed';
    isActive.value = true;
  }

  void fillForm(Map<String, dynamic>? voucher) {
    if (voucher == null) {
      clearForm();
      return;
    }

    codeCtrl.text = (voucher['code'] ?? '').toString();
    discountValueCtrl.text = (voucher['discount_value'] ?? 0).toString();
    minTransactionCtrl.text = (voucher['min_order_value'] ?? 0).toString();
    expiryDateCtrl.text = (voucher['expiry_date'] ?? '').toString();
    discountType.value = (voucher['type'] ?? 'fixed').toString().toLowerCase();
    isActive.value = voucher['is_active'] == true;
  }

  Future<void> saveVoucher({String? voucherId}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isSubmitting.value = true;

      final payload = {
        'code': codeCtrl.text.trim().toUpperCase(),
        'type': discountType.value,
        'discount_value': int.tryParse(discountValueCtrl.text.trim()) ?? 0,
        'min_order_value': int.tryParse(minTransactionCtrl.text.trim()) ?? 0,
        'expiry_date': expiryDateCtrl.text.trim(),
        'is_active': isActive.value,
      };

      if (voucherId == null || voucherId.isEmpty) {
        await _supabase.from('vouchers').insert(payload);
      } else {
        await _supabase.from('vouchers').update(payload).eq('id', voucherId);
      }

      await fetchVouchers();
      Get.back();

      Get.snackbar(
        'Berhasil',
        voucherId == null || voucherId.isEmpty
            ? 'Voucher berhasil ditambahkan'
            : 'Voucher berhasil diperbarui',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan voucher: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteVoucher(String voucherId) async {
    try {
      await _supabase.from('vouchers').delete().eq('id', voucherId);
      await fetchVouchers();
      Get.snackbar('Berhasil', 'Voucher berhasil dihapus');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus voucher: $e');
      return false;
    }
  }
}

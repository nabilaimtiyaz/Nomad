import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_voucher_controller.dart';

class AdminVoucherFormScreen extends GetView<AdminVoucherController> {
  const AdminVoucherFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final voucherId = (args?['id'] ?? '').toString();
    final isEdit = voucherId.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Voucher' : 'Tambah Voucher'),
        centerTitle: true,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kode Voucher',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Kode voucher wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.discountType.value,
                items: controller.discountTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.discountType.value = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Tipe Diskon',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.discountValueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai Diskon',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Nilai diskon wajib diisi';
                }
                if (int.tryParse(value!.trim()) == null) {
                  return 'Nilai diskon harus angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.minTransactionCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Transaksi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Minimum transaksi wajib diisi';
                }
                if (int.tryParse(value!.trim()) == null) {
                  return 'Minimum transaksi harus angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.expiryDateCtrl,
              decoration: const InputDecoration(
                labelText: 'Tanggal Expired',
                hintText: '2026-12-31',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Tanggal expired wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Obx(
              () => SwitchListTile(
                value: controller.isActive.value,
                onChanged: (value) => controller.isActive.value = value,
                title: const Text('Voucher aktif'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.saveVoucher(voucherId: voucherId),
                  child: Text(
                    controller.isSubmitting.value
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Voucher'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

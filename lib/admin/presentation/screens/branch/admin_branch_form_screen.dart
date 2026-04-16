import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_branch_controller.dart';

class AdminBranchFormScreen extends GetView<AdminBranchController> {
  const AdminBranchFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final branchId = (args?['id'] ?? '').toString();
    final isEdit = branchId.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Branch' : 'Tambah Branch'),
        centerTitle: true,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Branch',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Nama branch wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Alamat wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.openTimeCtrl,
              decoration: const InputDecoration(
                labelText: 'Jam Buka',
                hintText: '08:00',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Jam buka wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: controller.closeTimeCtrl,
              decoration: const InputDecoration(
                labelText: 'Jam Tutup',
                hintText: '22:00',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Jam tutup wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Obx(
              () => SwitchListTile(
                value: controller.isOpen.value,
                onChanged: (value) => controller.isOpen.value = value,
                title: const Text('Branch sedang buka'),
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
                      : () => controller.saveBranch(branchId: branchId),
                  child: Text(
                    controller.isSubmitting.value
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Branch'),
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
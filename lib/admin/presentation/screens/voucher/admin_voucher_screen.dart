import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_voucher_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminVoucherScreen extends GetView<AdminVoucherController> {
  const AdminVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text('Admin Vouchers'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(AdminRoutes.voucherForm);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.vouchers.isEmpty) {
          return const Center(child: Text('Belum ada voucher'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.vouchers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final voucher = controller.vouchers[index];

            final voucherId = (voucher['id'] ?? '').toString();
            final code = (voucher['code'] ?? '-').toString();
            final minTransaction = voucher['min_transaction'] ?? 0;
            final expiryDate = (voucher['expiry_date'] ?? '-').toString();
            final isActive = voucher['is_active'] == true;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.discount_outlined,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diskon: ${controller.formatDiscount(voucher)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Min. transaksi: Rp$minTransaction',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expired: $expiryDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                controller.fillForm(voucher);
                                Get.toNamed(
                                  AdminRoutes.voucherForm,
                                  arguments: {'id': voucherId},
                                );
                              },
                              child: const Text('Edit'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Hapus Voucher?',
                                  middleText:
                                      'Voucher ini akan dihapus permanen.',
                                  textConfirm: 'Hapus',
                                  textCancel: 'Batal',
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    final ok = await controller.deleteVoucher(
                                      voucherId,
                                    );
                                    if (ok) {
                                      Get.back(closeOverlays: true);
                                    }
                                  },
                                );
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: isActive,
                    onChanged: (_) {
                      controller.toggleVoucher(
                        voucherId: voucherId,
                        currentValue: isActive,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

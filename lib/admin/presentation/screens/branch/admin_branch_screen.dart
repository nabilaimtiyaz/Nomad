import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_branch_controller.dart';
import '../../../core/routes/admin_routes.dart';
import '../../widgets/admin_drawer.dart';

class AdminBranchScreen extends GetView<AdminBranchController> {
  const AdminBranchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text('Admin Branches'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(AdminRoutes.branchForm);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.branches.isEmpty) {
          return const Center(child: Text('Belum ada branch'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.branches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final branch = controller.branches[index];

            final branchId = (branch['id'] ?? '').toString();
            final name = (branch['name'] ?? '-').toString();
            final address = (branch['address'] ?? branch['location'] ?? '-')
                .toString();
            final openTime = (branch['open_time'] ?? '-').toString();
            final closeTime = (branch['close_time'] ?? '-').toString();
            final isOpen = branch['is_open'] == true;

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
                      color: isOpen
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      color: isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jam: $openTime - $closeTime',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                                color: isOpen
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isOpen ? 'OPEN' : 'CLOSED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isOpen ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                controller.fillForm(branch);
                                Get.toNamed(
                                  AdminRoutes.branchForm,
                                  arguments: {'id': branchId},
                                );
                              },
                              child: const Text('Edit'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Hapus Branch?',
                                  middleText:
                                      'Branch ini akan dihapus permanen.',
                                  textConfirm: 'Hapus',
                                  textCancel: 'Batal',
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    final ok = await controller.deleteBranch(
                                      branchId,
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
                    value: isOpen,
                    onChanged: (_) {
                      controller.toggleBranch(
                        branchId: branchId,
                        currentValue: isOpen,
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

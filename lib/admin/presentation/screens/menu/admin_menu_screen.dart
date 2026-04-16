import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_menu_controller.dart';
import '../../../core/routes/admin_routes.dart';

class AdminMenuScreen extends GetView<AdminMenuController> {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Menu Manager',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.red),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.black87,
              child: Icon(Icons.person, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD1121B),
        onPressed: () {
          controller.clearForm();
          Get.toNamed(AdminRoutes.menuForm);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Obx(() {
            final categories = controller.categories;
            final selectedCategory = controller.selectedCategory.value;

            return SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD1121B),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFD1121B)
                            : Colors.black12,
                      ),
                    ),
                    onSelected: (_) => controller.changeCategory(category),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final menus = controller.menus;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (menus.isEmpty) {
                return _EmptyMenuState(
                  onAddTap: () {
                    controller.clearForm();
                    Get.toNamed(AdminRoutes.menuForm);
                  },
                  onImportTap: () {
                    Get.snackbar(
                      'Info',
                      'Import CSV belum diimplementasikan',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: menus.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = menus[index];

                  final menuId = (item['id'] ?? '').toString();
                  final name = (item['name'] ?? '-').toString();
                  final price = item['price'] ?? 0;
                  final imageUrl = (item['image_url'] ?? '').toString();
                  final isAvailable = item['is_available'] == true;

                  final categoryData =
                      item['categories'] as Map<String, dynamic>?;
                  final categoryName = (categoryData?['name'] ?? '-')
                      .toString();

                  final branchData = item['branches'] as Map<String, dynamic>?;
                  final branchName = (branchData?['name'] ?? '-').toString();

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEAE1DC)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MenuImage(imageUrl: imageUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kategori: $categoryName',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Branch: $branchName',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Harga: Rp$price',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? const Color(0xFFE9F7EC)
                                          : const Color(0xFFFBEAEA),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isAvailable
                                            ? const Color(0xFF2E9B47)
                                            : const Color(0xFFD1121B),
                                      ),
                                    ),
                                  ),
                                  _OutlineSmallButton(
                                    label: 'Edit',
                                    onTap: () {
                                      controller.fillForm(item);
                                      Get.toNamed(
                                        AdminRoutes.menuForm,
                                        arguments: {'id': menuId},
                                      );
                                    },
                                  ),
                                  _OutlineSmallButton(
                                    label: 'Delete',
                                    onTap: () {
                                      Get.defaultDialog(
                                        title: 'Hapus Menu?',
                                        middleText:
                                            'Menu ini akan dihapus permanen.',
                                        textConfirm: 'Hapus',
                                        textCancel: 'Batal',
                                        confirmTextColor: Colors.white,
                                        onConfirm: () async {
                                          final ok = await controller
                                              .deleteMenu(menuId);
                                          if (ok) {
                                            Get.back(closeOverlays: true);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: isAvailable,
                          onChanged: (_) {
                            controller.toggleAvailability(
                              menuId: menuId,
                              currentValue: isAvailable,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  final VoidCallback onAddTap;
  final VoidCallback onImportTap;

  const _EmptyMenuState({required this.onAddTap, required this.onImportTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEEA),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 46,
                    color: Color(0xFFE7CACA),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1121B),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No menu items\nfound',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start by adding your first menu item or importing from a CSV to populate your digital heritage collection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1121B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text(
                  'Add First Menu',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onImportTap,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text(
                  'Import CSV',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  final String imageUrl;

  const _MenuImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final rawValue = imageUrl.trim();
    debugPrint('IMAGE RENDER RAW: $rawValue');

    if (rawValue.isEmpty) {
      return _fallback();
    }

    final isAsset = rawValue.startsWith('assets/');
    final isNetwork =
        rawValue.startsWith('http://') || rawValue.startsWith('https://');

    if (isAsset) {
      return Container(
        width: 74,
        height: 74,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF2ECE8),
        ),
        child: Image.asset(
          rawValue,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('ASSET IMAGE ERROR: $error');
            return _fallback();
          },
        ),
      );
    }

    if (isNetwork) {
      final safeUrl = Uri.encodeFull(rawValue);
      debugPrint('IMAGE RENDER SAFE: $safeUrl');

      return Container(
        width: 74,
        height: 74,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF2ECE8),
        ),
        child: Image.network(
          safeUrl,
          width: 74,
          height: 74,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('NETWORK IMAGE ERROR: $error');
            debugPrint('FAILED URL: $safeUrl');
            return _fallback();
          },
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECE8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.black38),
    );
  }
}

class _OutlineSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineSmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 38),
        side: const BorderSide(color: Color(0xFF7A728A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

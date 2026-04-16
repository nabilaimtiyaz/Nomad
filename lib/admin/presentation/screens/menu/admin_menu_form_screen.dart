import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_menu_controller.dart';

class AdminMenuFormScreen extends GetView<AdminMenuController> {
  const AdminMenuFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final menuId = (args?['id'] ?? '').toString();
    final isEdit = menuId.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD1121B)),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Text(
          isEdit ? 'Edit Menu' : 'Tambah Menu',
          style: const TextStyle(
            color: Color(0xFFD1121B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'NOMAD COFFEE',
                style: TextStyle(
                  color: Color(0xFFD1121B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: controller.isUploadingImage.value
                    ? null
                    : controller.pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _UploadBanner(
                      imageUrl: controller.imageUrlCtrl.text.trim(),
                    ),
                    if (controller.isUploadingImage.value)
                      Container(
                        height: 175,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap banner untuk upload foto menu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B6B61),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),

              const _FieldLabel('NAMA MENU'),
              const SizedBox(height: 8),
              _PrimaryTextField(
                controller: controller.nameCtrl,
                hintText: 'Contoh: Es Kopi Nomad',
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Nama menu wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              const _FieldLabel('HARGA (IDR)'),
              const SizedBox(height: 8),
              _PrimaryTextField(
                controller: controller.priceCtrl,
                hintText: 'Rp 0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  if (int.tryParse(value!.trim()) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              const _FieldLabel('KATEGORI'),
              const SizedBox(height: 8),
              _PrimaryDropdown<String>(
                value: controller.selectedCategoryId.value.isEmpty
                    ? null
                    : controller.selectedCategoryId.value,
                hintText: 'Pilih kategori',
                items: controller.categoriesData
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: (category['id'] ?? '').toString(),
                        child: Text((category['name'] ?? '-').toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCategoryId.value = value;
                  }
                },
              ),
              const SizedBox(height: 22),

              const _FieldLabel('BRANCH'),
              const SizedBox(height: 8),
              _PrimaryDropdown<String>(
                value: controller.selectedBranchId.value.isEmpty
                    ? null
                    : controller.selectedBranchId.value,
                hintText: 'Pilih branch',
                items: controller.branchesData
                    .map(
                      (branch) => DropdownMenuItem<String>(
                        value: (branch['id'] ?? '').toString(),
                        child: Text((branch['name'] ?? '-').toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedBranchId.value = value;
                  }
                },
              ),
              const SizedBox(height: 22),

              const _FieldLabel('IMAGE URL'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.imageUrlCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'URL gambar akan terisi otomatis setelah upload',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB8A8A1),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0EAE7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SwitchListTile(
                  value: controller.isAvailable.value,
                  onChanged: (value) => controller.isAvailable.value = value,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF00796B),
                  title: const Text(
                    'Menu tersedia',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1121B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => controller.saveMenu(menuId: menuId),
                  child: Text(
                    controller.isSubmitting.value
                        ? 'Menyimpan...'
                        : (isEdit ? 'Simpan Perubahan' : 'Tambah Menu'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBanner extends StatelessWidget {
  final String imageUrl;

  const _UploadBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return Container(
      height: 175,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2433), Color(0xFF6F5A8A), Color(0xFF2B2433)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _UploadBannerInner(),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _UploadBannerInner(),
                    ),
            )
          : const _UploadBannerInner(),
    );
  }
}

class _UploadBannerInner extends StatelessWidget {
  const _UploadBannerInner();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 42, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Upload Foto Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9D7262),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _PrimaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _PrimaryTextField({
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB8A8A1), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF0EAE7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _PrimaryDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PrimaryDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF6C625E),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB8A8A1), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF0EAE7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: Colors.white,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/auth_remote.dart';
import '../../data/datasources/profil_remote.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profil_repository.dart';

class ProfileController extends GetxController {
  final AppStateController _appState = Get.find<AppStateController>();
  final ProfilRepository _profilRepository = ProfilRepository(ProfilRemote());
  final AuthRepository _authRepository = AuthRepository(AuthRemote());

  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;

  final isLoading = false.obs;
  final hasChanged = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController(text: _appState.user.name);
    phoneCtrl = TextEditingController(text: _appState.user.phone);
    nameCtrl.addListener(_onChanged);
    phoneCtrl.addListener(_onChanged);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  void _onChanged() {
    hasChanged.value = true;
  }

  String? validateName(String? value) => Validators.name(value);
  String? validatePhone(String? value) => Validators.phone(value);

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final updatedUser = await _profilRepository.updateProfile(
        authId: _appState.user.id,
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
      );

      _appState.setAuthenticatedUser(updatedUser);
      hasChanged.value = false;

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } catch (error) {
      Get.snackbar(
        'Gagal',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _appState.logoutLocal();
    Get.offAllNamed(AppRoutes.login);
  }
}

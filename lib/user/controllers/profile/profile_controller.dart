import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/datasources/profil_remote.dart';
import '../../data/repositories/profil_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repository = ProfileRepository(ProfileRemote());

  final AppStateController appState = Get.find<AppStateController>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final user = appState.user;

      // 🔴 VALIDASI DASAR
      if (name.trim().isEmpty) {
        errorMessage.value = 'Nama tidak boleh kosong';
        return;
      }

      if (phone.trim().isEmpty) {
        errorMessage.value = 'Nomor HP tidak boleh kosong';
        return;
      }

      // 🔥 UPDATE KE DATABASE
      final updatedUser = await _repository.updateProfile(
        userId: user.id,
        name: name.trim(),
        phone: phone.trim(),
      );

      if (updatedUser == null) {
        errorMessage.value = 'Gagal memperbarui profil';
        return;
      }

      // 🔥 UPDATE LOCAL STATE (INI YANG SEBELUMNYA BUG)
      appState.setAuthenticatedUser(updatedUser);

      successMessage.value = 'Profil berhasil diperbarui';
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

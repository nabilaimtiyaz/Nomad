import '../datasources/profil_remote.dart';
import '../models/user_model.dart';

class ProfilRepository {
  final ProfilRemote remote;

  ProfilRepository(this.remote);

  Future<UserModel> updateProfile({
    required String authId,
    required String name,
    required String phone,
  }) {
    return remote.updateProfile(authId: authId, name: name, phone: phone);
  }
}

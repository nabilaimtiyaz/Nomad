import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class ProfilRemote {
  final SupabaseClient client;

  ProfilRemote({SupabaseClient? client}) : client = client ?? SupabaseService.client;

  Future<UserModel> updateProfile({
    required String authId,
    required String name,
    required String phone,
  }) async {
    final data = await client
        .from('users')
        .update({
          'name': name,
          'phone': phone,
        })
        .eq('auth_id', authId)
        .select()
        .single();

    return UserModel.fromMap(Map<String, dynamic>.from(data));
  }
}

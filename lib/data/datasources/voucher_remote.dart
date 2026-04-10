import '../../core/services/supabase_service.dart';

class VoucherRemote {
  final client = SupabaseService.client;

  Future<Map<String, dynamic>?> getVoucher(String code) async {
    final res = await client
        .from('vouchers')
        .select()
        .eq('code', code)
        .eq('is_active', true)
        .maybeSingle();

    return res;
  }
}
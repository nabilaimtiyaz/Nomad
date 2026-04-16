import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMemberController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('users')
          .select('id, name, email, phone, loyalty_points, membership_tier, role')
          .neq('role', 'admin')
          .order('created_at', ascending: false);

      members.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setQuery(String value) {
    query.value = value.trim().toLowerCase();
  }

  List<Map<String, dynamic>> get filteredMembers {
    if (query.value.isEmpty) return members;

    return members.where((member) {
      final name = (member['name'] ?? '').toString().toLowerCase();
      final email = (member['email'] ?? '').toString().toLowerCase();
      final phone = (member['phone'] ?? '').toString().toLowerCase();

      return name.contains(query.value) ||
          email.contains(query.value) ||
          phone.contains(query.value);
    }).toList();
  }

  String tierLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'platinum':
        return 'Platinum';
      case 'gold':
        return 'Gold';
      case 'silver':
        return 'Silver';
      case 'bronze':
        return 'Bronze';
      default:
        return raw;
    }
  }
}
import '../../core/services/supabase_service.dart';
import '../models/menu_item_model.dart';

class MenuRemote {
  Future<List<MenuItem>> getMenus({
    required String branchId,
    String? categoryId,
  }) async {
    dynamic query = SupabaseService.client
        .from('menu_items')
        .select()
        .eq('branch_id', branchId);

    if (categoryId != null &&
        categoryId.isNotEmpty &&
        categoryId != 'all') {
      query = query.eq('category_id', categoryId);
    }

    final response = await query.order('name');

    return (response as List)
        .map((e) => MenuItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrderController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;
  final RxString selectedStatus = 'pending'.obs;
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  final List<String> statuses = const [
    'pending',
    'processing',
    'ready',
    'done',
    'cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      final response = await _supabase
          .from('orders')
          .select('''
            id,
            queue_number,
            status,
            subtotal,
            discount_amount,
            grand_total,
            payment_method,
            order_type,
            created_at,
            users(name, email),
            branches(name)
          ''')
          .eq('status', selectedStatus.value)
          .order('created_at', ascending: false);

      orders.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat order: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeFilter(String status) async {
    selectedStatus.value = status;
    await fetchOrders();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      await fetchOrders();

      Get.snackbar(
        'Berhasil',
        'Status order diubah ke ${formatStatusLabel(newStatus)}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal update status: $e');
    }
  }

  String formatStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'done':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

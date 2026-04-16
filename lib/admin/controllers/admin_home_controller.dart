import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/routes/admin_routes.dart';

class AdminHomeController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxBool isLoading = true.obs;

  final RxInt pendingOrders = 0.obs;
  final RxInt processingOrders = 0.obs;
  final RxInt readyOrders = 0.obs;
  final RxInt doneOrdersToday = 0.obs;
  final RxInt totalMembers = 0.obs;
  final RxInt totalMenusAvailable = 0.obs;
  final RxInt activeVouchers = 0.obs;
  final RxInt todayRevenue = 0.obs;

  final adminMenus = const <AdminMenuItem>[
    AdminMenuItem(
      title: 'Orders',
      subtitle: 'Kelola pesanan masuk',
      route: AdminRoutes.orders,
    ),
    AdminMenuItem(
      title: 'Menus',
      subtitle: 'Kelola menu & availability',
      route: AdminRoutes.menus,
    ),
    AdminMenuItem(
      title: 'Branches',
      subtitle: 'Kelola cabang & jam operasional',
      route: AdminRoutes.branches,
    ),
    AdminMenuItem(
      title: 'Vouchers',
      subtitle: 'Kelola voucher & promo',
      route: AdminRoutes.vouchers,
    ),
    AdminMenuItem(
      title: 'Members',
      subtitle: 'Lihat member & loyalty',
      route: AdminRoutes.members,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final pendingFuture = _supabase
          .from('orders')
          .select('id')
          .eq('status', 'pending');

      final processingFuture = _supabase
          .from('orders')
          .select('id')
          .eq('status', 'processing');

      final readyFuture = _supabase
          .from('orders')
          .select('id')
          .eq('status', 'ready');

      final doneTodayFuture = _supabase
          .from('orders')
          .select('id, grand_total')
          .eq('status', 'done')
          .gte('created_at', startOfDay);

      final membersFuture = _supabase
          .from('users')
          .select('id')
          .neq('role', 'admin');

      final menusFuture = _supabase
          .from('menu_items')
          .select('id')
          .eq('is_available', true);

      final vouchersFuture = _supabase
          .from('vouchers')
          .select('id')
          .eq('is_active', true);

      final results = await Future.wait([
        pendingFuture,
        processingFuture,
        readyFuture,
        doneTodayFuture,
        membersFuture,
        menusFuture,
        vouchersFuture,
      ]);

      final pendingData = List<Map<String, dynamic>>.from(results[0] as List);
      final processingData = List<Map<String, dynamic>>.from(results[1] as List);
      final readyData = List<Map<String, dynamic>>.from(results[2] as List);
      final doneTodayData = List<Map<String, dynamic>>.from(results[3] as List);
      final membersData = List<Map<String, dynamic>>.from(results[4] as List);
      final menusData = List<Map<String, dynamic>>.from(results[5] as List);
      final vouchersData = List<Map<String, dynamic>>.from(results[6] as List);

      pendingOrders.value = pendingData.length;
      processingOrders.value = processingData.length;
      readyOrders.value = readyData.length;
      doneOrdersToday.value = doneTodayData.length;
      totalMembers.value = membersData.length;
      totalMenusAvailable.value = menusData.length;
      activeVouchers.value = vouchersData.length;

      int revenue = 0;
      for (final item in doneTodayData) {
        revenue += ((item['grand_total'] ?? 0) as num).toInt();
      }
      todayRevenue.value = revenue;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openMenu(String route) {
    Get.toNamed(route);
  }

  String formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return 'Rp${buffer.toString().split('').reversed.join()}';
  }
}

class AdminMenuItem {
  final String title;
  final String subtitle;
  final String route;

  const AdminMenuItem({
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
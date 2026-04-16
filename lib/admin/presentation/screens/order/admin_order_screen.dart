import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin_order_controller.dart';

class AdminOrderScreen extends GetView<AdminOrderController> {
  const AdminOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final orders = controller.orders;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ✅ EMPTY STATE
        if (orders.isEmpty) {
          return _emptyState();
        }

        /// ✅ LIST ORDER (tetap pakai style lama)
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            final queue = order['queue_number'] ?? '-';
            final total = order['grand_total'] ?? 0;
            final status = order['status'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queue: $queue',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Total: Rp$total'),
                  const SizedBox(height: 6),
                  Text('Status: ${status.toUpperCase()}'),
                ],
              ),
            );
          },
        );
      }),

      /// ✅ BOTTOM NAV STATUS
      bottomNavigationBar: _bottomStatusBar(),
    );
  }

  // =========================
  // EMPTY STATE UI
  // =========================
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// icon placeholder
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 60,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'No active orders found',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),

            const Text(
              'The kitchen is currently quiet. All orders have been cleared or haven\'t arrived yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => controller.fetchOrders(),
              child: const Text('Refresh Hub'),
            ),

            const SizedBox(height: 30),

            /// stats bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('0', 'LIVE TASKS', Colors.red),
                _statItem('100%', 'COMPLETION', Colors.green),
                _statItem('0m', 'AVG WAIT', Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }

  // =========================
  // BOTTOM STATUS BAR
  // =========================
  Widget _bottomStatusBar() {
    return Obx(() {
      final selected = controller.selectedStatus.value;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusItem('pending', Icons.access_time, selected),
            _statusItem('processing', Icons.local_cafe, selected),
            _statusItem('ready', Icons.notifications, selected),
            _statusItem('done', Icons.check_circle, selected),
          ],
        ),
      );
    });
  }

  Widget _statusItem(String status, IconData icon, String selected) {
    final isActive = selected == status;

    return GestureDetector(
      onTap: () => controller.changeFilter(status),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: isActive ? Colors.red : Colors.black45),
          const SizedBox(height: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.red : Colors.black45,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

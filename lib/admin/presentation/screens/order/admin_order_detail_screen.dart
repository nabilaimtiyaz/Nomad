import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  const AdminOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Map<String, dynamic>.from(Get.arguments ?? {});
    final userData = order['users'] as Map<String, dynamic>? ?? {};
    final branchData = order['branches'] as Map<String, dynamic>? ?? {};

    final queueNumber = (order['queue_number'] ?? '-').toString();
    final orderId = (order['id'] ?? '-').toString();
    final customerName = (userData['name'] ?? 'Tanpa Nama').toString();
    final customerEmail = (userData['email'] ?? '-').toString();
    final branchName = (branchData['name'] ?? '-').toString();
    final status = (order['status'] ?? '-').toString();
    final subtotal = (order['subtotal'] ?? 0).toString();
    final discount = (order['discount_amount'] ?? 0).toString();
    final total = (order['grand_total'] ?? 0).toString();
    final paymentMethod = (order['payment_method'] ?? '-').toString();
    final orderType = (order['order_type'] ?? '-').toString();
    final createdAt = (order['created_at'] ?? '-').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: 'Informasi Order',
            children: [
              _row('Order ID', orderId),
              _row('Queue', queueNumber),
              _row('Status', status.toUpperCase()),
              _row('Dibuat', createdAt),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Customer',
            children: [
              _row('Nama', customerName),
              _row('Email', customerEmail),
            ],
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Transaksi',
            children: [
              _row('Branch', branchName),
              _row('Payment', paymentMethod),
              _row('Order Type', orderType),
              _row('Subtotal', 'Rp$subtotal'),
              _row('Discount', 'Rp$discount'),
              _row('Grand Total', 'Rp$total', bold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
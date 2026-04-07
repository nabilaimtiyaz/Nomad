import 'menu_item_model.dart';

enum OrderStatus { pending, confirmed, ready, done, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:   return 'Menunggu Konfirmasi';
      case OrderStatus.confirmed: return 'Sedang Diproses';
      case OrderStatus.ready:     return 'Siap Diambil';
      case OrderStatus.done:      return 'Selesai';
      case OrderStatus.cancelled: return 'Dibatalkan';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending:   return '⏳';
      case OrderStatus.confirmed: return '☕';
      case OrderStatus.ready:     return '✅';
      case OrderStatus.done:      return '🎉';
      case OrderStatus.cancelled: return '❌';
    }
  }

  bool get isActive =>
    this == OrderStatus.pending ||
    this == OrderStatus.confirmed ||
    this == OrderStatus.ready;
}

class OrderModel {
  final String id;
  final String queueNumber;
  final String branchId;
  final String branchName;
  final List<CartItem> items;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final int subtotal;
  final int discountAmount;   // total diskon (voucher + poin)
  final int serviceFee;
  final int grandTotal;
  final int pointsEarned;
  final int pointsUsed;       // poin yang di-redeem
  final String? voucherCode;  // kode voucher yang dipakai
  final String? orderType;    // dine_in / takeaway
  final String? notes;        // catatan order keseluruhan

  const OrderModel({
    required this.id,
    required this.queueNumber,
    required this.branchId,
    required this.branchName,
    required this.items,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    required this.createdAt,
    required this.subtotal,
    this.discountAmount = 0,
    required this.serviceFee,
    required this.grandTotal,
    required this.pointsEarned,
    this.pointsUsed = 0,
    this.voucherCode,
    this.orderType = 'dine_in',
    this.notes,
  });

  OrderModel copyWith({OrderStatus? status}) {
    return OrderModel(
      id: id, queueNumber: queueNumber,
      branchId: branchId, branchName: branchName,
      items: items, paymentMethod: paymentMethod,
      createdAt: createdAt, subtotal: subtotal,
      discountAmount: discountAmount,
      serviceFee: serviceFee, grandTotal: grandTotal,
      pointsEarned: pointsEarned, pointsUsed: pointsUsed,
      voucherCode: voucherCode, orderType: orderType, notes: notes,
      status: status ?? this.status,
    );
  }
}

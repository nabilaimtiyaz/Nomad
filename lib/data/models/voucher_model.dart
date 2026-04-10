// VoucherModel — representasi voucher/kode promo sesuai pre-plan BAB 3.4
//
// Tipe diskon:
//   percent   → potongan % dari subtotal (ada maxDiscount)
//   fixed     → potongan nominal tetap
//   free_item → item tertentu gratis (dihandle manual saat checkout)
//   birthday  → voucher otomatis ulang tahun

enum VoucherType { percent, fixed, freeItem, birthday }

class VoucherModel {
  final String id;
  final String code;          // kode unik, case-insensitive
  final String name;          // label tampil di UI
  final VoucherType type;
  final int discountValue;    // nilai % atau nominal Rp
  final int? maxDiscount;     // batas potongan untuk tipe percent
  final int minOrderValue;    // minimum subtotal
  final int? usageLimit;      // total pemakaian (null = unlimited)
  final int usedCount;
  final int usagePerUser;     // berapa kali 1 user bisa pakai
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderValue = 0,
    this.usageLimit,
    this.usedCount = 0,
    this.usagePerUser = 1,
    required this.startDate,
    required this.expiryDate,
    this.isActive = true,
  });

  /// ======================
  /// FROM MAP (SUPABASE)
  /// ======================
  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      type: VoucherType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      discountValue: map['discount_value'] ?? 0,
      maxDiscount: map['max_discount'],
      minOrderValue: map['min_order_value'] ?? 0,
      usageLimit: map['usage_limit'],
      usedCount: map['used_count'] ?? 0,
      usagePerUser: map['usage_per_user'] ?? 1,
      startDate: DateTime.parse(map['start_date']),
      expiryDate: DateTime.parse(map['expiry_date']),
      isActive: map['is_active'] ?? true,
    );
  }

  /// ======================
  /// HITUNG DISKON (DOMAIN LOGIC)
  /// ======================
  int calculateDiscount(int subtotal) {
    if (!isValid) return 0;
    if (subtotal < minOrderValue) return 0;

    switch (type) {
      case VoucherType.percent:
        final raw = (subtotal * discountValue / 100).round();
        return maxDiscount != null ? raw.clamp(0, maxDiscount!) : raw;

      case VoucherType.fixed:
      case VoucherType.birthday:
        return discountValue.clamp(0, subtotal);

      case VoucherType.freeItem:
        return 0; // handled di tempat lain
    }
  }

  /// ======================
  /// VALIDASI GLOBAL
  /// ======================
  bool get isValid {
    if (!isActive) return false;

    final now = DateTime.now();

    if (now.isBefore(startDate)) return false;
    if (now.isAfter(expiryDate)) return false;

    if (usageLimit != null && usedCount >= usageLimit!) {
      return false;
    }

    return true;
  }

  /// ======================
  /// VALIDASI DETAIL (UNTUK CONTROLLER)
  /// ======================
  String? validate(int subtotal, int userUsageCount) {
    if (!isActive) return 'Voucher tidak aktif';

    final now = DateTime.now();

    if (now.isBefore(startDate)) return 'Voucher belum aktif';
    if (now.isAfter(expiryDate)) return 'Voucher sudah kadaluarsa';

    if (usageLimit != null && usedCount >= usageLimit!) {
      return 'Voucher sudah habis';
    }

    if (userUsageCount >= usagePerUser) {
      return 'Kamu sudah memakai voucher ini';
    }

    if (subtotal < minOrderValue) {
      return 'Minimum order Rp $minOrderValue untuk pakai voucher ini';
    }

    return null;
  }

  /// ======================
  /// LABEL UI
  /// ======================
  String get typeLabel {
    switch (type) {
      case VoucherType.percent:
        return 'Diskon $discountValue%';
      case VoucherType.fixed:
        return 'Potongan Rp $discountValue';
      case VoucherType.freeItem:
        return 'Gratis Item';
      case VoucherType.birthday:
        return 'Diskon Ulang Tahun';
    }
  }
}
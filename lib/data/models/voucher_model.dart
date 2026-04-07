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

  // Hitung besaran diskon berdasarkan subtotal
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
        // Free item dihandle terpisah saat checkout
        return 0;
    }
  }

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (now.isAfter(expiryDate)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    return true;
  }

  // Label tipe untuk UI
  String get typeLabel {
    switch (type) {
      case VoucherType.percent:   return 'Diskon ${discountValue}%';
      case VoucherType.fixed:     return 'Potongan Rp ${_fmt(discountValue)}';
      case VoucherType.freeItem:  return 'Gratis Item';
      case VoucherType.birthday:  return 'Diskon Ulang Tahun';
    }
  }

  String get icon {
    switch (type) {
      case VoucherType.percent:   return '🏷️';
      case VoucherType.fixed:     return '💵';
      case VoucherType.freeItem:  return '🎁';
      case VoucherType.birthday:  return '🎂';
    }
  }

  // Helper format nominal
  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  // Validasi dan kembalikan pesan error, atau null kalau valid
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
      return 'Minimum order Rp ${_fmt(minOrderValue)} untuk pakai voucher ini';
    }
    return null; // valid
  }
}

// ─── Dummy Vouchers ───────────────────────────────────────────────────────

class DummyVouchers {
  static List<VoucherModel> getAll() {
    final now = DateTime.now();
    return [
      VoucherModel(
        id: 'v1',
        code: 'NOMAD20',
        name: 'Diskon 20% Minuman',
        type: VoucherType.percent,
        discountValue: 20,
        maxDiscount: 20000,
        minOrderValue: 30000,
        usageLimit: 100,
        usedCount: 43,
        usagePerUser: 1,
        startDate: now.subtract(const Duration(days: 30)),
        expiryDate: now.add(const Duration(days: 30)),
      ),
      VoucherModel(
        id: 'v2',
        code: 'HEMAT15K',
        name: 'Potongan Rp 15.000',
        type: VoucherType.fixed,
        discountValue: 15000,
        minOrderValue: 50000,
        usageLimit: 50,
        usedCount: 12,
        usagePerUser: 1,
        startDate: now.subtract(const Duration(days: 7)),
        expiryDate: now.add(const Duration(days: 14)),
      ),
      VoucherModel(
        id: 'v3',
        code: 'WELKOME',
        name: 'Welcome Voucher',
        type: VoucherType.fixed,
        discountValue: 10000,
        minOrderValue: 0,
        usageLimit: null, // unlimited
        usedCount: 0,
        usagePerUser: 1,
        startDate: now.subtract(const Duration(days: 60)),
        expiryDate: now.add(const Duration(days: 60)),
      ),
      VoucherModel(
        id: 'v4',
        code: 'BDAY50',
        name: 'Diskon Ulang Tahun 50%',
        type: VoucherType.birthday,
        discountValue: 50000,
        minOrderValue: 30000,
        usageLimit: 1,
        usedCount: 0,
        usagePerUser: 1,
        startDate: DateTime(now.year, now.month, 1),
        expiryDate: DateTime(now.year, now.month + 1, 0),
      ),
    ];
  }
}

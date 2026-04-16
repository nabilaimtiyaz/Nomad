enum VoucherType { percent, fixed, freeItem, birthday }

class VoucherModel {
  final String id;
  final String code;
  final String name;
  final VoucherType type;
  final int discountValue;
  final int? maxDiscount;
  final int minOrderValue;
  final int? usageLimit;
  final int usedCount;
  final int usagePerUser;
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

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      id: map['id'].toString(),
      code: map['code'].toString(),
      name: map['name'].toString(),
      type: _parseVoucherType(map['type']),
      discountValue: _toInt(map['discount_value']),
      maxDiscount: map['max_discount'] == null
          ? null
          : _toInt(map['max_discount']),
      minOrderValue: _toInt(map['min_order_value']),
      usageLimit: map['usage_limit'] == null
          ? null
          : _toInt(map['usage_limit']),
      usedCount: _toInt(map['used_count']),
      usagePerUser: _toInt(map['usage_per_user'] ?? 1),
      startDate: DateTime.parse(map['start_date'].toString()),
      expiryDate: DateTime.parse(map['expiry_date'].toString()),
      isActive: map['is_active'] ?? true,
    );
  }

  static VoucherType _parseVoucherType(dynamic rawType) {
    final value = (rawType ?? '').toString().trim().toLowerCase();

    switch (value) {
      case 'percent':
      case 'percentage':
        return VoucherType.percent;
      case 'fixed':
        return VoucherType.fixed;
      case 'free_item':
      case 'freeitem':
        return VoucherType.freeItem;
      case 'birthday':
        return VoucherType.birthday;
      default:
        return VoucherType.fixed;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  int calculateDiscount(int subtotal) {
    if (!isValid) return 0;
    if (subtotal < minOrderValue) return 0;

    switch (type) {
      case VoucherType.percent:
        final rawDiscount = ((subtotal * discountValue) / 100).floor();
        if (maxDiscount != null) {
          return rawDiscount.clamp(0, maxDiscount!);
        }
        return rawDiscount;

      case VoucherType.fixed:
      case VoucherType.birthday:
        return discountValue.clamp(0, subtotal);

      case VoucherType.freeItem:
        return 0;
    }
  }

  bool get isValid {
    final now = DateTime.now();

    if (!isActive) return false;
    if (now.isBefore(startDate)) return false;
    if (now.isAfter(expiryDate)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;

    return true;
  }

  String? validate(int subtotal, int userUsageCount) {
    final now = DateTime.now();

    if (!isActive) return 'Voucher tidak aktif';
    if (now.isBefore(startDate)) return 'Voucher belum aktif';
    if (now.isAfter(expiryDate)) return 'Voucher sudah kadaluarsa';
    if (usageLimit != null && usedCount >= usageLimit!) {
      return 'Voucher sudah habis';
    }
    if (userUsageCount >= usagePerUser) {
      return 'Kamu sudah memakai voucher ini';
    }
    if (subtotal < minOrderValue) {
      return 'Minimum order belum memenuhi syarat voucher';
    }

    return null;
  }

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

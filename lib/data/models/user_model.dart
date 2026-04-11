class UserModel {
  final String id;
  final String authId;
  final String name;
  final String email;
  final String phone;
  final int loyaltyPoints;
  final int totalEarnedPoints;
  final String membershipTier;

  const UserModel({
    required this.id,
    required this.authId,
    required this.name,
    required this.email,
    required this.phone,
    required this.loyaltyPoints,
    required this.totalEarnedPoints,
    required this.membershipTier,
  });

  UserModel copyWith({
    String? id,
    String? authId,
    String? name,
    String? email,
    String? phone,
    int? loyaltyPoints,
    int? totalEarnedPoints,
    String? membershipTier,
  }) {
    return UserModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints ?? this.totalEarnedPoints,
      membershipTier: membershipTier ?? this.membershipTier,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final totalEarnedPoints = (map['total_earned_points'] ??
            map['totalEarnedPoints'] ??
            map['total_points'] ??
            0) as int;

    final loyaltyPoints =
        (map['loyalty_points'] ?? map['loyaltyPoints'] ?? 0) as int;

    final tier = (map['membership_tier'] ?? map['membershipTier']) as String?;

    return UserModel(
      /// PENTING:
      /// id = primary key row di tabel users
      id: (map['id'] ?? '').toString(),

      /// authId = id user dari Supabase Auth
      authId: (map['auth_id'] ?? '').toString(),

      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      loyaltyPoints: loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints,
      membershipTier: tier ?? getTier(totalEarnedPoints),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auth_id': authId,
      'name': name,
      'email': email,
      'phone': phone,
      'loyalty_points': loyaltyPoints,
      'total_earned_points': totalEarnedPoints,
      'membership_tier': membershipTier,
    };
  }

  static String getTier(int totalEarned) {
    if (totalEarned >= 5000) return 'platinum';
    if (totalEarned >= 2000) return 'gold';
    if (totalEarned >= 500) return 'silver';
    return 'bronze';
  }

  static String getTierLabel(String tier) {
    switch (tier) {
      case 'platinum':
        return 'Platinum';
      case 'gold':
        return 'Gold';
      case 'silver':
        return 'Silver';
      default:
        return 'Bronze';
    }
  }

  static String getTierIcon(String tier) {
    switch (tier) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      default:
        return '🥉';
    }
  }
}
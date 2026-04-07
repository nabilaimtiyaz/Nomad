class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int loyaltyPoints;
  final int totalEarnedPoints;
  final String membershipTier;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.loyaltyPoints,
    required this.totalEarnedPoints,
    required this.membershipTier,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? loyaltyPoints,
    int? totalEarnedPoints,
    String? membershipTier,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints ?? this.totalEarnedPoints,
      membershipTier: membershipTier ?? this.membershipTier,
    );
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

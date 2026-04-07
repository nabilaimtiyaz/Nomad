class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });
}
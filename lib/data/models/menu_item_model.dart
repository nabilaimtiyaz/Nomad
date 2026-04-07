class MenuItem {
  final String id;
  final String branchId;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final bool isAvailable;
  final int orderCount;

  const MenuItem({
    required this.id,
    required this.branchId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.orderCount,
  });
}

class Category {
  final String id;
  final String name;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class CartItem {
  final String entryId;
  final MenuItem menuItem;
  final int qty;
  final String notes;

  const CartItem({
    required this.entryId,
    required this.menuItem,
    this.qty = 1,
    this.notes = '',
  });

  static String entryKey(String menuId, String notes) {
    final normalized = notes.trim().toLowerCase();
    return '$menuId::$normalized';
  }

  bool get isSimple => notes.trim().isEmpty;
  int get subtotal => menuItem.price * qty;

  CartItem copyWith({
    String? entryId,
    MenuItem? menuItem,
    int? qty,
    String? notes,
  }) {
    return CartItem(
      entryId: entryId ?? this.entryId,
      menuItem: menuItem ?? this.menuItem,
      qty: qty ?? this.qty,
      notes: notes ?? this.notes,
    );
  }
}

class Category {
  final String id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
    );
  }
}

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
  final bool isDrink;

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
    this.isDrink = false,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    final categoryName = (map['category_name'] ?? map['category'] ?? '')
        .toString()
        .toLowerCase();

    return MenuItem(
      id: (map['id'] ?? '').toString(),
      branchId: (map['branch_id'] ?? '').toString(),
      categoryId: (map['category_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: _toInt(map['price']),
      imageUrl: (map['image_url'] ?? '').toString(),
      isAvailable: map['is_available'] == null
          ? true
          : map['is_available'] as bool,
      orderCount: _toInt(map['order_count']),
      isDrink: map['is_drink'] is bool
          ? map['is_drink'] as bool
          : _isDrinkFromCategory(categoryName),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static bool _isDrinkFromCategory(String categoryName) {
    return categoryName.contains('coffee') ||
        categoryName.contains('kopi') ||
        categoryName.contains('tea') ||
        categoryName.contains('teh') ||
        categoryName.contains('drink') ||
        categoryName.contains('minuman');
  }
}

class CartItem {
  final String entryId;
  final MenuItem menuItem;
  final int qty;
  final String notes;

  const CartItem({
    required this.entryId,
    required this.menuItem,
    required this.qty,
    required this.notes,
  });

  factory CartItem.detailed(MenuItem menuItem, int qty, String notes) {
    return CartItem(
      entryId: entryKey(menuItem.id, notes),
      menuItem: menuItem,
      qty: qty,
      notes: notes,
    );
  }

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

  static String entryKey(String menuId, String notes) {
    final normalizedNotes = notes.trim().toLowerCase();
    return '$menuId|$normalizedNotes';
  }
}

class DrinkCustomization {
  final String temperature;
  final String size;
  final String sugar;
  final String ice;

  const DrinkCustomization({
    this.temperature = 'Ice',
    this.size = 'Regular',
    this.sugar = 'Normal',
    this.ice = 'Normal Ice',
  });

  DrinkCustomization copyWith({
    String? temperature,
    String? size,
    String? sugar,
    String? ice,
  }) {
    return DrinkCustomization(
      temperature: temperature ?? this.temperature,
      size: size ?? this.size,
      sugar: sugar ?? this.sugar,
      ice: ice ?? this.ice,
    );
  }

  int get extraPrice {
    switch (size.toLowerCase()) {
      case 'large':
        return 6000;
      case 'medium':
        return 3000;
      default:
        return 0;
    }
  }

  String toSummary() {
    final parts = <String>[temperature, size, sugar];
    if (temperature.toLowerCase() == 'ice' && ice.trim().isNotEmpty) {
      parts.add(ice);
    }
    return parts.join(', ');
  }
}
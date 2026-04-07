import './models/branch_model.dart';
import './models/menu_item_model.dart';
import './models/user_model.dart';

class DummyData {
  // ─── Cabang ────────────────────────────────────────────────────────
  static const List<Branch> branches = [
    Branch(
      id: 'branch_1',
      name: 'Cabang Sudirman',
      address: 'Jl. Jend. Sudirman No. 12, Jakarta Pusat',
      phone: '021-5551234',
      isOpen: true,
      openTime: '08:00',
      closeTime: '22:00',
    ),
    Branch(
      id: 'branch_2',
      name: 'Cabang Kemang',
      address: 'Jl. Kemang Raya No. 45, Jakarta Selatan',
      phone: '021-5555678',
      isOpen: true,
      openTime: '09:00',
      closeTime: '23:00',
    ),
    Branch(
      id: 'branch_3',
      name: 'Cabang Kelapa Gading',
      address: 'Jl. Kelapa Gading Blvd No. 8, Jakarta Utara',
      phone: '021-5559012',
      isOpen: false,
      openTime: '08:00',
      closeTime: '21:00',
    ),
  ];

  // ─── Kategori ──────────────────────────────────────────────────────
  static const List<Category> categories = [
    Category(id: 'cat_all', name: 'Semua', icon: '☕'),
    Category(id: 'cat_kopi', name: 'Kopi', icon: '☕'),
    Category(id: 'cat_teh', name: 'Teh', icon: '🍵'),
    Category(id: 'cat_makanan', name: 'Makanan', icon: '🍽️'),
    Category(id: 'cat_snack', name: 'Snack', icon: '🍪'),
    Category(id: 'cat_paket', name: 'Paket', icon: '🎁'),
  ];

  // ─── Menu Items ────────────────────────────────────────────────────
  static const List<MenuItem> menuItems = [
    // ── BRANCH 1: Cabang Sudirman ──────────────────────────────────
    MenuItem(
      id: 'menu_1', branchId: 'branch_1', categoryId: 'cat_kopi',
      name: 'Nomad Signature Blend',
      description: 'Perpaduan biji kopi arabika pilihan dengan cita rasa coklat dan caramel',
      price: 32000,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',
      isAvailable: true, orderCount: 245,
    ),
    MenuItem(
      id: 'menu_2', branchId: 'branch_1', categoryId: 'cat_kopi',
      name: 'Caramel Macchiato',
      description: 'Espresso dengan susu steamed dan saus karamel premium',
      price: 38000,
      imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510bd9d4?w=400',
      isAvailable: true, orderCount: 189,
    ),
    MenuItem(
      id: 'menu_3', branchId: 'branch_1', categoryId: 'cat_kopi',
      name: 'Cold Brew Classic',
      description: 'Kopi cold brew 12 jam dengan rasa smooth dan tidak pahit',
      price: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400',
      isAvailable: true, orderCount: 167,
    ),
    MenuItem(
      id: 'menu_4', branchId: 'branch_1', categoryId: 'cat_kopi',
      name: 'Espresso Shot',
      description: 'Espresso murni dengan crema sempurna',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400',
      isAvailable: false, orderCount: 98,
    ),
    MenuItem(
      id: 'menu_5', branchId: 'branch_1', categoryId: 'cat_teh',
      name: 'Teh Tarik Nomad',
      description: 'Teh tarik khas dengan susu creamer dan teh ceylon pilihan',
      price: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400',
      isAvailable: true, orderCount: 312,
    ),
    MenuItem(
      id: 'menu_6', branchId: 'branch_1', categoryId: 'cat_teh',
      name: 'Matcha Latte',
      description: 'Matcha grade A dari Jepang dengan susu full cream',
      price: 36000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
      isAvailable: true, orderCount: 203,
    ),
    MenuItem(
      id: 'menu_7', branchId: 'branch_1', categoryId: 'cat_teh',
      name: 'Thai Tea',
      description: 'Teh Thailand dengan susu kental manis dan es batu',
      price: 28000,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      isAvailable: true, orderCount: 178,
    ),
    MenuItem(
      id: 'menu_8', branchId: 'branch_1', categoryId: 'cat_makanan',
      name: 'Roti Bakar Nomad',
      description: 'Roti bakar dengan pilihan selai coklat, keju, atau kacang',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400',
      isAvailable: true, orderCount: 134,
    ),
    MenuItem(
      id: 'menu_9', branchId: 'branch_1', categoryId: 'cat_makanan',
      name: 'Nasi Goreng Kampung',
      description: 'Nasi goreng dengan bumbu rempah tradisional dan telur mata sapi',
      price: 35000,
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
      isAvailable: true, orderCount: 89,
    ),
    MenuItem(
      id: 'menu_10', branchId: 'branch_1', categoryId: 'cat_snack',
      name: 'Cookies Coklat',
      description: 'Cookies renyah dengan chip coklat belgia',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400',
      isAvailable: true, orderCount: 156,
    ),
    MenuItem(
      id: 'menu_11', branchId: 'branch_1', categoryId: 'cat_snack',
      name: 'Kentang Goreng',
      description: 'Kentang goreng crispy dengan saus mayo pedas',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
      isAvailable: false, orderCount: 201,
    ),
    MenuItem(
      id: 'menu_12', branchId: 'branch_1', categoryId: 'cat_paket',
      name: 'Paket Hemat Kopi',
      description: '1 Nomad Signature + 1 Cookies Coklat. Hemat Rp 5.000!',
      price: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      isAvailable: true, orderCount: 78,
    ),
    MenuItem(
      id: 'menu_13', branchId: 'branch_1', categoryId: 'cat_paket',
      name: 'Paket Sarapan',
      description: '1 Teh Tarik + 1 Roti Bakar. Cocok untuk pagi hari!',
      price: 38000,
      imageUrl: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',
      isAvailable: true, orderCount: 112,
    ),

    // ── BRANCH 2: Cabang Kemang ────────────────────────────────────
    MenuItem(
      id: 'menu_b2_1', branchId: 'branch_2', categoryId: 'cat_kopi',
      name: 'Kemang Blend',
      description: 'Racikan khas barista Kemang — bold, fruity, dengan aftertaste panjang',
      price: 34000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
      isAvailable: true, orderCount: 198,
    ),
    MenuItem(
      id: 'menu_b2_2', branchId: 'branch_2', categoryId: 'cat_kopi',
      name: 'Iced Americano',
      description: 'Espresso double shot dengan air es, segar dan kuat',
      price: 28000,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',
      isAvailable: true, orderCount: 234,
    ),
    MenuItem(
      id: 'menu_b2_3', branchId: 'branch_2', categoryId: 'cat_kopi',
      name: 'Vietnam Drip',
      description: 'Kopi Vietnam tubruk pelan dengan susu kental manis',
      price: 30000,
      imageUrl: 'https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=400',
      isAvailable: true, orderCount: 145,
    ),
    MenuItem(
      id: 'menu_b2_4', branchId: 'branch_2', categoryId: 'cat_teh',
      name: 'Teh Susu Boba',
      description: 'Teh susu dengan boba kenyal, pilihan best seller',
      price: 32000,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      isAvailable: true, orderCount: 289,
    ),
    MenuItem(
      id: 'menu_b2_5', branchId: 'branch_2', categoryId: 'cat_teh',
      name: 'Matcha Red Bean',
      description: 'Matcha latte dengan topping red bean manis',
      price: 38000,
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
      isAvailable: true, orderCount: 167,
    ),
    MenuItem(
      id: 'menu_b2_6', branchId: 'branch_2', categoryId: 'cat_makanan',
      name: 'Avocado Toast',
      description: 'Roti sourdough dengan alpukat, telur poach, dan seasoning',
      price: 45000,
      imageUrl: 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400',
      isAvailable: true, orderCount: 122,
    ),
    MenuItem(
      id: 'menu_b2_7', branchId: 'branch_2', categoryId: 'cat_makanan',
      name: 'Croissant Keju',
      description: 'Croissant lapis mentega dengan isian keju cheddar leleh',
      price: 28000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',
      isAvailable: true, orderCount: 178,
    ),
    MenuItem(
      id: 'menu_b2_8', branchId: 'branch_2', categoryId: 'cat_snack',
      name: 'Brownies Coklat',
      description: 'Brownies fudgy dengan topping chocolate ganache',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?w=400',
      isAvailable: true, orderCount: 203,
    ),
    MenuItem(
      id: 'menu_b2_9', branchId: 'branch_2', categoryId: 'cat_paket',
      name: 'Paket Sore Kemang',
      description: '1 Iced Americano + 1 Brownies. Perfect untuk sore hari!',
      price: 40000,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      isAvailable: true, orderCount: 95,
    ),

    // ── BRANCH 3: Kelapa Gading (tutup, tapi punya menu) ──────────
    MenuItem(
      id: 'menu_b3_1', branchId: 'branch_3', categoryId: 'cat_kopi',
      name: 'Kopi Tubruk Tradisional',
      description: 'Kopi tubruk dengan biji robusta pilihan dari Lampung',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
      isAvailable: true, orderCount: 88,
    ),
    MenuItem(
      id: 'menu_b3_2', branchId: 'branch_3', categoryId: 'cat_teh',
      name: 'Es Teh Tarik',
      description: 'Teh tarik dingin, manis pas, segar untuk hari panas',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400',
      isAvailable: true, orderCount: 134,
    ),
    MenuItem(
      id: 'menu_b3_3', branchId: 'branch_3', categoryId: 'cat_makanan',
      name: 'Indomie Goreng Spesial',
      description: 'Mie goreng dengan topping telur, sosis, dan keju',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
      isAvailable: false, orderCount: 201,
    ),
  ];

  // ─── User Dummy ─────────────────────────────────────────────────────
  static const UserModel dummyUser = UserModel(
    id: 'user_1',
    name: 'Camel',
    email: 'camel@email.com',
    phone: '08123456789',
    loyaltyPoints: 850,
    totalEarnedPoints: 1200,
    membershipTier: 'silver',
  );

  // ─── Helper ─────────────────────────────────────────────────────────
  static List<MenuItem> getMenuByBranchAndCategory(
    String branchId,
    String categoryId,
  ) {
    return menuItems.where((item) {
      final matchBranch = item.branchId == branchId;
      final matchCategory =
          categoryId == 'cat_all' || item.categoryId == categoryId;
      return matchBranch && matchCategory;
    }).toList();
  }
}

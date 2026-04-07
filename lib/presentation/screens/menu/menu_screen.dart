import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/menu_item_model.dart';
import 'menu_detail_sheet.dart';

class MenuScreen extends StatefulWidget {
  final Branch? selectedBranch;
  final Function(Branch) onBranchSelected;
  final Map<String, CartItem> cart;
  final Function(MenuItem) onAddToCart;
  final Function(MenuItem, int, String)? onAddToCartWithDetail;
  final Function(String, int) onQtyChanged;
  final VoidCallback? onOpenCart;

  const MenuScreen({
    super.key,
    required this.selectedBranch,
    required this.onBranchSelected,
    required this.cart,
    required this.onAddToCart,
    this.onAddToCartWithDetail,
    required this.onQtyChanged,
    this.onOpenCart,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _catId = 'cat_all';
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MenuItem> get _items {
    List<MenuItem> list;

    if (widget.selectedBranch != null) {
      // Ada cabang: filter by branch + category
      list = DummyData.getMenuByBranchAndCategory(
          widget.selectedBranch!.id, _catId);
    } else {
      // Belum pilih cabang: tampilkan semua, filter by category
      list = _catId == 'cat_all'
          ? DummyData.menuItems.toList()
          : DummyData.menuItems
              .where((i) => i.categoryId == _catId)
              .toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q))
          .toList();
    }
    list.sort((a, b) => b.orderCount.compareTo(a.orderCount));
    return list;
  }

  void _openDetail(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuDetailSheet(
        item: item,
        currentQty: widget.cart[item.id]?.qty ?? 0,
        currentNotes: widget.cart[item.id]?.notes ?? '',
        onAdd: (qty, notes) {
          if (widget.onAddToCartWithDetail != null) {
            widget.onAddToCartWithDetail!(item, qty, notes);
          } else {
            for (var i = 0; i < qty; i++) {
              widget.onAddToCart(item);
            }
          }
          // Snackbar konfirmasi
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${item.name} ditambahkan ke keranjang'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Lihat Cart',
              textColor: Colors.white,
              onPressed: () => widget.onOpenCart?.call(),
            ),
          ));
        },
        onRemove: () => widget.onQtyChanged(item.id, -1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan categories dari DummyData langsung — sudah termasuk cat_all
    final cats = DummyData.categories;
    final cartCount = widget.cart.values.fold(0, (s, i) => s + i.qty);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Top bar ─────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.coffee_rounded,
                    size: 22, color: AppColors.primary),
                const SizedBox(width: 10),
                const Text('Nomad',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
                const Spacer(),
                // Ikon cart dengan badge
                if (cartCount > 0)
                  GestureDetector(
                    onTap: widget.onOpenCart,
                    child: Stack(clipBehavior: Clip.none, children: [
                      const Icon(Icons.shopping_cart_outlined,
                          size: 24, color: AppColors.textPrimary),
                      Positioned(
                        right: -4, top: -4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('$cartCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ]),
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        const NetworkImage('https://i.pravatar.cc/80?img=5'),
                    backgroundColor: AppColors.surfaceGrey,
                  ),
              ]),
              const SizedBox(height: 12),

              // Search bar merah
              Container(
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Find your blend...',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.white60, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white60, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            })
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ),

          // ── Tab kategori ─────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = cats[i];
                final active = _catId == cat.id;
                return GestureDetector(
                  onTap: () => setState(() => _catId = cat.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.cardBorder),
                    ),
                    child: Text(cat.name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // ── Info cabang jika belum dipilih ───────────────────────────
          if (widget.selectedBranch == null)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warning.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Pilih cabang agar menu sesuai lokasi',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.warning)),
              ]),
            ),

          // ── List menu ─────────────────────────────────────────────────
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.divider),
                        const SizedBox(height: 12),
                        Text(
                          widget.selectedBranch == null
                              ? 'Pilih cabang terlebih dahulu'
                              : 'Menu tidak ditemukan',
                          style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                    children: [
                      if (_query.isEmpty) ...[
                        const Text('CURATED SELECTION',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.teal,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        const Text('Signature Menu',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                      ],
                      ..._items.map((item) => _MenuListTile(
                            item: item,
                            qty: widget.cart[item.id]?.qty ?? 0,
                            onTap: () => _openDetail(item),
                            onAdd: () {
                              widget.onAddToCart(item);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content:
                                    Text('${item.name} ditambahkan'),
                                backgroundColor: AppColors.teal,
                                behavior: SnackBarBehavior.floating,
                                duration:
                                    const Duration(seconds: 1),
                              ));
                            },
                            onRemove: () =>
                                widget.onQtyChanged(item.id, -1),
                          )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── _MenuListTile ────────────────────────────────────────────────────────────

class _MenuListTile extends StatelessWidget {
  final MenuItem item;
  final int qty;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _MenuListTile({
    required this.item,
    required this.qty,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80, height: 80,
              color: AppColors.surfaceGrey,
              child: item.imageUrl.startsWith('http')
                  ? Image.network(item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.coffee_rounded,
                          size: 36,
                          color: AppColors.divider))
                  : const Icon(Icons.coffee_rounded,
                      size: 36, color: AppColors.divider),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Expanded(
                  child: Text(item.name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                if (!item.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('Habis',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
              const SizedBox(height: 3),
              Text(item.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Formatters.currency(item.price),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  // Counter jika sudah di cart, tombol + jika belum
                  if (qty > 0)
                    Row(children: [
                      _SmBtn(
                          icon: Icons.remove_rounded,
                          onTap: onRemove,
                          filled: false),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('$qty',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                      _SmBtn(icon: Icons.add_rounded, onTap: onAdd),
                    ])
                  else
                    GestureDetector(
                      onTap: item.isAvailable ? onAdd : null,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? AppColors.teal
                              : AppColors.divider,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SmBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _SmBtn(
      {required this.icon, required this.onTap, this.filled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: filled ? AppColors.teal : Colors.transparent,
          shape: BoxShape.circle,
          border:
              filled ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon,
            size: 14,
            color: filled ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}
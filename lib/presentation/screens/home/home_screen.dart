import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/menu_item_model.dart';
import '../../../data/models/user_model.dart';
import '../menu/menu_detail_sheet.dart';
import '../loyalty/loyalty_screen.dart';
import '../../../core/app_state.dart';

class HomeScreen extends StatefulWidget {
  final Branch? selectedBranch;
  final Function(Branch) onBranchSelected;
  final VoidCallback? onNavigateToMenu;
  final Function(MenuItem)? onAddToCart;
  final Function(MenuItem, int, String)? onAddToCartWithDetail;
  final Function(String, int)? onQtyChanged;
  final Map<String, CartItem> cart;
  final VoidCallback? onOpenCart;

  const HomeScreen({
    super.key,
    required this.selectedBranch,
    required this.onBranchSelected,
    this.onNavigateToMenu,
    this.onAddToCart,
    this.onAddToCartWithDetail,
    this.onQtyChanged,
    this.cart = const {},
    this.onOpenCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showBranchPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BranchSheet(
        selected: widget.selectedBranch,
        onPick: (branch) {
          widget.onBranchSelected(branch);
          Navigator.pop(context);
        },
      ),
    );
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
          widget.onAddToCartWithDetail?.call(item, qty, notes);
        },
        onRemove: () {
          widget.onQtyChanged?.call(item.id, -1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStateProvider.of(context).user;
    final popular =
        DummyData.menuItems
            .where(
              (item) =>
                  widget.selectedBranch == null ||
                  item.branchId == widget.selectedBranch!.id,
            )
            .toList()
          ..sort((a, b) => b.orderCount.compareTo(a.orderCount));

    return Scaffold(
      // Menggunakan warna background yang lebih soft/krem sesuai referensi
      backgroundColor: const Color(0xFFFCF7F3),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMemberCard(user),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Weekly Curations',
                    'VIEW ALL',
                    onTap: widget.onNavigateToMenu,
                  ),
                  const SizedBox(height: 12),
                  _buildOfferBanner(),
                  const SizedBox(height: 24),
                  _buildCategoryRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Popular Nomads', 'FILTER'),
                  const SizedBox(height: 12),
                  _buildMenuGrid(popular.take(4).toList()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    final firstName = user.name.trim().isEmpty
        ? 'Guest'
        : user.name.trim().split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Kiri: Branch Picker
          GestureDetector(
            onTap: _showBranchPicker,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFBEBEA), // Light red bg
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFBA1A1A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT BRANCH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.selectedBranch?.name ?? 'Pilih Cabang',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFBA1A1A), // Red color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Kanan: Avatar & Notification
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryDark,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'N',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel user) {
    final tier = user.membershipTier;
    final points = user.loyaltyPoints;
    final tierLabel = UserModel.getTierLabel(tier);
    const nextPoints = 2500;
    final progress = (points / nextPoints).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoyaltyScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFA61111), // Solid Deep Red
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEMBERSHIP TIER',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1,
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tierLabel Nomad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ID: 8829-102',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress to Gold',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${Formatters.commas(points)} / ${Formatters.commas(nextPoints)} pts',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF67D4B6),
                ), // Mint Green
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Earn ${Formatters.commas(nextPoints - points)} more points to unlock free weekly delivery.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBanner() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2, // Dummy count to show horizontal scrolling capabilities
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: isFirst ? 16 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  isFirst
                      ? 'https://images.unsplash.com/photo-1550450339-e7a4787a2074?q=80&w=1000&auto=format&fit=crop'
                      : 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=1000&auto=format&fit=crop',
                ), // Image placeholder
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIMITED TIME',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFirst
                        ? 'Artisan Oolong Teh Tarik\nNow Available'
                        : 'Daily Fresh Bakes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow() {
    const cats = [
      (Icons.coffee_rounded, 'COFFEE'),
      (Icons.local_cafe_outlined, 'TEA'),
      (Icons.restaurant_menu_rounded, 'FOOD'),
      (Icons.cookie_outlined, 'SNACK'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cats.map((cat) {
        final (icon, label) = cat;
        return GestureDetector(
          onTap: widget.onNavigateToMenu,
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE6E2), // Light Gray/Beige
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String? action, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ), // Red Color Action
      ],
    );
  }

  Widget _buildMenuGrid(List<MenuItem> items) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75, // Disesuaikan agar card proporsional
      children: items
          .map(
            (item) => _MenuCard(
              item: item,
              onTap: () => _openDetail(item),
              onAdd: () => widget.onAddToCart?.call(item),
            ),
          )
          .toList(),
    );
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _MenuCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surfaceGrey,
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.coffee_rounded,
                                  size: 48,
                                  color: AppColors.divider,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.coffee_rounded,
                                size: 48,
                                color: AppColors.divider,
                              ),
                            ),
                    ),
                  ),
                  // Tombol Favorit (Heart)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.grey.shade300, // Abu-abu default
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Teks dan Tombol Add
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menggunakan custom styling string "RM" jika di referensi demikian,
                      // namun tetap fleksibel menggunakan Formatter jika dibutuhkan.
                      Text(
                        'RM ${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFBA1A1A), // Red color text for price
                        ),
                      ),
                      GestureDetector(
                        onTap: item.isAvailable ? onAdd : null,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? const Color(0xFF0C7D6B) // Teal Dark Color
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Bentuk sedikit kotak
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Branch Sheet (Tidak ada perubahan UI drastis disini, dipertahankan) ─────

class _BranchSheet extends StatelessWidget {
  final Branch? selected;
  final Function(Branch) onPick;

  const _BranchSheet({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Cabang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...DummyData.branches.map((branch) {
            final isSelected = selected?.id == branch.id;
            return GestureDetector(
              onTap: branch.isOpen ? () => onPick(branch) : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tealLight : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.teal : AppColors.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: isSelected
                          ? AppColors.teal
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.teal
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            branch.address,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: branch.isOpen
                            ? AppColors.tealLight
                            : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        branch.isOpen ? 'Buka' : 'Tutup',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: branch.isOpen
                              ? AppColors.teal
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

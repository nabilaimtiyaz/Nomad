import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/menu_item_model.dart';

// MenuDetailSheet — referensi UI (hal.8):
// Foto besar tanpa border radius di atas, badge "TERLARIS" merah,
// ikon X dan share di pojok atas, nama + rating + harga besar merah,
// Sugar Level dengan opsi list (bukan grid 2×2), ada deskripsi tiap opsi,
// Extra Add-ons dengan ikon dan tombol "+", qty counter + tombol TAMBAH merah lebar.
class MenuDetailSheet extends StatefulWidget {
  final MenuItem item;
  final int currentQty;
  final String currentNotes;
  final Function(int, String) onAdd;
  final VoidCallback onRemove;

  const MenuDetailSheet({
    super.key,
    required this.item,
    required this.currentQty,
    this.currentNotes = '',
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<MenuDetailSheet> {
  late int _qty;
  late TextEditingController _notesCtrl;
  int _sugarIdx = 0;
  // Map add-on name → jumlah yang dipilih
  final Map<String, int> _addons = {'Honey Boba': 0, 'Grass Jelly': 0};

  static const _sugarOptions = [
    ('Normal', 'The authentic Nomad experience as intended.'),
    ('Less Sugar', 'Reduced sweetness for a bolder tea profile.'),
    ('No Sugar', 'Pure tea goodness without any added sweeteners.'),
  ];

  static const _addonPrices = {
    'Honey Boba': 5000,
    'Grass Jelly': 4000,
  };

  @override
  void initState() {
    super.initState();
    _qty = widget.currentQty > 0 ? widget.currentQty : 1;
    _notesCtrl = TextEditingController(text: widget.currentNotes);
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  int get _addonTotal => _addons.entries.fold(0,
    (s, e) => s + (e.value * (_addonPrices[e.key] ?? 0)));

  int get _totalPrice => (widget.item.price + _addonTotal) * _qty;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.zero,
          children: [
            // ── Foto full width ─────────────────────────────────────
            Stack(children: [
              // Handle drag bar di atas foto
              Container(
                height: 220,
                color: AppColors.surfaceGrey,
                child: widget.item.imageUrl.startsWith('http')
                  ? Image.network(widget.item.imageUrl, fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.coffee_rounded, size: 80, color: AppColors.divider))
                  : const Icon(Icons.coffee_rounded,
                      size: 80, color: AppColors.divider),
              ),

              // Handle bar transparan
              Positioned(
                top: 10, left: 0, right: 0,
                child: Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2)),
                )),
              ),

              // Tombol X (tutup)
              Positioned(
                top: 10, left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textPrimary),
                  ),
                ),
              ),

              // Tombol share
              Positioned(
                top: 10, right: 12,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined,
                    size: 16, color: AppColors.textPrimary),
                ),
              ),

              // Badge TERLARIS
              if (widget.item.orderCount > 10)
                Positioned(
                  top: 10, left: 50,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('TERLARIS',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
            ]),

            // ── Info ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(widget.item.name,
                    style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 4),

                  // Rating
                  Row(children: [
                    const Icon(Icons.star_rounded,
                      size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text('4.9',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                    const SizedBox(width: 4),
                    const Text('(1.2k+ Reviews)',
                      style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 8),

                  // Harga besar merah
                  Text(Formatters.currency(widget.item.price),
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
                  const SizedBox(height: 12),

                  // Deskripsi
                  const Text('DESCRIPTION',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text(widget.item.description,
                    style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary,
                      height: 1.6)),
                  const SizedBox(height: 20),

                  // ── Sugar Level ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SUGAR LEVEL',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary, letterSpacing: 1)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(6)),
                        child: const Text('REQUIRED',
                          style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List opsi gula (sesuai referensi UI hal.8: list vertikal)
                  ..._sugarOptions.asMap().entries.map((e) {
                    final i = e.key;
                    final (name, desc) = e.value;
                    final active = _sugarIdx == i;

                    return GestureDetector(
                      onTap: () => setState(() => _sugarIdx = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: active ? AppColors.tealLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? AppColors.teal : AppColors.cardBorder,
                            width: active ? 1.5 : 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: active ? AppColors.teal
                                                  : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(desc,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                              ],
                            )),
                            // Radio bulat
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: active ? AppColors.teal
                                                : AppColors.divider,
                                  width: 1.5),
                                color: active ? AppColors.teal : Colors.transparent,
                              ),
                              child: active
                                ? const Icon(Icons.check_rounded,
                                    size: 12, color: Colors.white)
                                : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // ── Extra Add-ons ────────────────────────────────
                  const Text('EXTRA ADD-ONS',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 10),

                  ..._addons.entries.map((e) {
                    final price = _addonPrices[e.key] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.bubble_chart_rounded,
                            size: 18, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key,
                              style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                            Text('+${Formatters.currency(price)}',
                              style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        )),
                        // Tombol "+" kecil untuk tambah add-on
                        GestureDetector(
                          onTap: () => setState(
                            () => _addons[e.key] = (e.value + 1)),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBorder)),
                            child: const Icon(Icons.add_rounded,
                              size: 16, color: AppColors.textPrimary),
                          ),
                        ),
                      ]),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Qty + tombol TAMBAH ──────────────────────────
                  Row(children: [
                    // Counter qty
                    Row(children: [
                      _cBtn(Icons.remove_rounded, () {
                        if (_qty > 1) setState(() => _qty--);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty',
                          style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                      ),
                      _cBtn(Icons.add_rounded, () => setState(() => _qty++)),
                    ]),
                    const SizedBox(width: 12),

                    // Tombol TAMBAH merah lebar (sesuai referensi)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.onAdd(_qty, _notesCtrl.text.trim());
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${widget.item.name} ditambahkan ✓'),
                            backgroundColor: AppColors.teal,
                            duration: const Duration(seconds: 2),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('TAMBAH',
                                style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  color: Colors.white, letterSpacing: 0.5)),
                              const SizedBox(width: 10),
                              Text(Formatters.currency(_totalPrice),
                                style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder)),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

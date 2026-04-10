import 'package:get/get.dart';
import '../../core/app_state.dart';
import '../../data/models/user_model.dart';

class LoyaltyController extends GetxController {
  final AppStateController _appState = Get.find<AppStateController>();

  static const tiers = [
    ('silver',   'Silver',   500,  '★', '1.2× Point Multiplier\nBirthday Reward',                         false),
    ('gold',     'Gold',     2000, '◆', '1.5× Point Multiplier\nPriority Reservations\nFree Monthly Drink', true),
    ('platinum', 'Platinum', 5000, '✦', '2× Point Multiplier\nConcierge Service\nExclusive Event Access',   false),
  ];

  static const redeems = [
    ('Artisan Coffee',  'Any handcrafted beverage, any size.',   500,  'coffee'),
    ('Signature Beans', 'Choice of single origin or house blend.', 2000, 'grain'),
    ('Morning Pastry',  'Freshly baked in-house daily.',          350,  'pastry'),
    ('Nomad Vessel',    'Limited edition ceramic tumbler.',        4500, 'cup'),
  ];

  UserModel get user => _appState.user;
  int get points     => _appState.user.loyaltyPoints;
  String get tier    => _appState.user.membershipTier;

  bool canRedeem(int ptsNeeded) => points >= ptsNeeded;

  void redeem(String rewardName, int ptsNeeded) {
    final success = _appState.redeemPoints(ptsNeeded);
    if (success) {
      Get.snackbar('Berhasil!',
        '$ptsNeeded poin ditukar untuk $rewardName',
        snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Gagal', 'Saldo poin tidak cukup',
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showConfirmRedeem(String rewardName, int ptsNeeded) {
    Get.defaultDialog(
      title: 'Konfirmasi Redeem',
      middleText:
          'Tukar $ptsNeeded poin untuk "$rewardName"?\n\n'
          'Saldo setelah: ${points - ptsNeeded} poin',
      textConfirm: 'Tukar',
      textCancel:  'Batal',
      onConfirm: () {
        Get.back();
        redeem(rewardName, ptsNeeded);
      },
    );
  }
}
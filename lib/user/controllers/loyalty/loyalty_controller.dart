import 'package:get/get.dart';

import '../../core/app_state.dart';
import '../../data/models/user_model.dart';

class LoyaltyController extends GetxController {
  final AppStateController appState = Get.find<AppStateController>();

  UserModel get user => appState.user;

  int get points => user.loyaltyPoints;
  int get totalEarned => user.totalEarnedPoints;
  String get tier => user.membershipTier;

  double get multiplier {
    switch (tier) {
      case 'platinum':
        return 2.0;
      case 'gold':
        return 1.5;
      default:
        return 1.0;
    }
  }

  int get nextTierThreshold {
    switch (tier) {
      case 'silver':
        return 1000;
      case 'gold':
        return 3000;
      default:
        return totalEarned;
    }
  }

  double get progress {
    final target = nextTierThreshold;
    if (target == 0) return 1.0;

    return (totalEarned / target).clamp(0.0, 1.0);
  }

  String get tierLabel => UserModel.getTierLabel(tier);
  String get tierIcon => UserModel.getTierIcon(tier);

  String get benefitText {
    return '${multiplier}x poin setiap pembelian';
  }
}

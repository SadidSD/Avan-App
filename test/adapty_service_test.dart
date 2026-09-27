import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/services/adapty_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptyService Architecture & Configuration Tests', () {
    test('AdaptyService initializes cleanly as a singleton', () {
      final s1 = AdaptyService();
      final s2 = AdaptyService();
      expect(identical(s1, s2), isTrue);
    });

    test('AdaptyService contains the user provided public API key', () {
      expect(AdaptyService.publicApiKey, 'public_live_2m5GI2w7.2lrvMP8eBt9VZmbTZXDN');
      expect(AdaptyService.premiumAccessLevelId, 'premium');
      expect(AdaptyService.mainPlacementId, 'avan_main_paywall');
    });

    test('Default non-premium entitlement state before store resolution', () {
      final service = AdaptyService();
      expect(service.isPremium, isFalse);
      expect(service.currentProfile, isNull);
    });
  });
}

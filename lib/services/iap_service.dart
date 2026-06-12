/// IAP Service - Placeholder
/// Install in_app_purchase package when ready for App Store submission
/// This file exists to prevent import errors in main.dart and profile_screen.dart

class IAPService {
  static final IAPService instance = IAPService._internal();
  IAPService._internal();

  bool isAvailable = false;

  void initialize() {}
  void dispose() {}
  Future<void> restorePurchases() async {}
}

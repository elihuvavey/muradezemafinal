import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:muradezema/utils/user_prefs.dart';

class IAPService {
  static final IAPService instance = IAPService._internal();
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> availableProducts = [];
  bool isAvailable = false;
  bool isRestoring = false;

  // UI callbacks
  Function(String productId)? onPurchaseSuccess;
  Function(String error)? onPurchaseError;
  VoidCallback? onRestoreComplete;

  void initialize() {
    _subscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (error) => debugPrint('IAP Stream Error: $error'),
    );
  }

  void dispose() => _subscription.cancel();

  Future<void> fetchProducts(Set<String> productIds) async {
    isAvailable = await _iap.isAvailable();
    if (isAvailable && Platform.isIOS) {
      final response = await _iap.queryProductDetails(productIds);
      availableProducts = response.productDetails;
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP: Products not found: ${response.notFoundIDs}');
      }
    }
  }

  Future<void> buyProduct(String productId) async {
    try {
      final product = availableProducts.firstWhere((p) => p.id == productId);
      final param = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP: Buy failed - $e');
      onPurchaseError?.call('Purchase failed: $e');
    }
  }

  Future<void> restorePurchases() async {
    isRestoring = true;
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> detailsList) {
    for (var details in detailsList) {
      debugPrint('IAP: ${details.productID} -> ${details.status}');

      switch (details.status) {
        case PurchaseStatus.pending:
          break;

        case PurchaseStatus.error:
          onPurchaseError?.call(details.error?.message ?? 'Unknown error');
          _finishTransaction(details);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliverProduct(details);
          break;

        case PurchaseStatus.canceled:
          _finishTransaction(details);
          break;
      }
    }

    if (isRestoring) {
      isRestoring = false;
      onRestoreComplete?.call();
    }
  }

  void _deliverProduct(PurchaseDetails details) {
    final productId = details.productID;
    // Format: com.app.muradezema.[type].[id]
    final parts = productId.split('.');
    if (parts.length >= 5) {
      final contentId = parts.sublist(4).join('.');
      final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
      if (!purchasedIds.contains(contentId)) {
        purchasedIds.add(contentId);
        HivePrefs.saveStringList('purchased_audio_ids', purchasedIds);
        debugPrint('IAP: Unlocked content: $contentId');
      }
    } else {
      // Simple product ID (no dot notation)
      final purchasedIds = HivePrefs.getStringList('purchased_audio_ids') ?? [];
      if (!purchasedIds.contains(productId)) {
        purchasedIds.add(productId);
        HivePrefs.saveStringList('purchased_audio_ids', purchasedIds);
        debugPrint('IAP: Unlocked product: $productId');
      }
    }
    onPurchaseSuccess?.call(productId);
    _finishTransaction(details);
  }

  void _finishTransaction(PurchaseDetails details) {
    if (details.pendingCompletePurchase) {
      _iap.completePurchase(details);
    }
  }
}

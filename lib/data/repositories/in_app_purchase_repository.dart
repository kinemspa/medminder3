import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final inAppPurchaseRepositoryProvider = Provider((ref) => InAppPurchaseRepository());

class InAppPurchaseRepository {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('In-app purchases not available');
      return;
    }
    // Example product: premium subscription
    const Set<String> productIds = {'premium_subscription'};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }
    // Listen for purchases
    _inAppPurchase.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _isPremium = true;
          _inAppPurchase.completePurchase(purchase);
        }
      }
    });
  }

  Future<void> purchasePremium() async {
    const Set<String> productIds = {'premium_subscription'};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
    if (response.productDetails.isNotEmpty) {
      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }
}
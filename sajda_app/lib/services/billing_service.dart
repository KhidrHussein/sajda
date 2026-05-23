import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class BillingService extends ChangeNotifier {
  static final BillingService _instance = BillingService._internal();

  factory BillingService() {
    return _instance;
  }

  BillingService._internal();

  // TODO: Replace these with your actual RevenueCat API keys
  final String _appleApiKey = 'appl_YOUR_APPLE_API_KEY_HERE';
  final String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY_HERE';

  // State
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      PurchasesConfiguration? configuration;

      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        _isInitialized = true;
        await _checkPremiumStatus();

        // Listen for changes in purchaser info
        Purchases.addCustomerInfoUpdateListener((customerInfo) {
          _updatePremiumStatusFromInfo(customerInfo);
        });
      }
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  Future<void> _checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatusFromInfo(customerInfo);
    } catch (e) {
      debugPrint('Error checking premium status: $e');
    }
  }

  void _updatePremiumStatusFromInfo(CustomerInfo customerInfo) {
    // 'premium' is the identifier for the entitlement in RevenueCat
    final isCurrentlyPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
    
    if (_isPremium != isCurrentlyPremium) {
      _isPremium = isCurrentlyPremium;
      notifyListeners();
    }
  }

  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      _updatePremiumStatusFromInfo(purchaseResult.customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatusFromInfo(customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
}

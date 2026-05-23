import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/billing_service.dart';
import '../../theme/design_system.dart';
import '../../widgets/primary_button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final BillingService _billingService = BillingService();
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await _billingService.getAvailablePackages();
    if (mounted) {
      setState(() {
        _packages = packages;
        if (_packages.isNotEmpty) {
          // Default to annual if available, then monthly, then first
          _selectedPackage = _packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => _packages.firstWhere(
              (p) => p.packageType == PackageType.monthly,
              orElse: () => _packages.first,
            ),
          );
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _makePurchase() async {
    if (_selectedPackage == null) return;
    
    setState(() => _isPurchasing = true);
    
    final isPremium = await _billingService.purchasePackage(_selectedPackage!);
    
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to Sajda Premium!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase failed or cancelled.')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    
    final isPremium = await _billingService.restorePurchases();
    
    if (mounted) {
      setState(() => _isPurchasing = false);
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored successfully.')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active purchases found.')),
        );
      }
    }
  }

  String _getPackageTitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return "Monthly Commitment";
      case PackageType.annual:
        return "Yearly Commitment";
      case PackageType.lifetime:
        return "Lifetime Access";
      default:
        return package.storeProduct.title;
    }
  }

  String _getPackageSubtitle(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:
        return "Build the habit step by step";
      case PackageType.annual:
        return "Save over 15% annually";
      case PackageType.lifetime:
        return "One-time contribution";
      default:
        return package.storeProduct.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final bgColor = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          TextButton(
            onPressed: _isPurchasing ? null : _restorePurchases,
            child: Text(
              "Restore",
              style: AppTextStyles.button(AppColors.accentPrimary),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.spacingXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "You already know you should pray.",
                        style: AppTextStyles.heading1(textColor).copyWith(fontSize: 32, height: 1.2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.spacingXl),
                      Text(
                        "Sajda removes the distraction when it matters.",
                        style: AppTextStyles.bodyLarge(secondaryColor).copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      if (_packages.isNotEmpty) ...[
                        ..._packages.map((package) {
                          final isSelected = _selectedPackage?.identifier == package.identifier;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.spacingMd),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPackage = package;
                                });
                              },
                              borderRadius: BorderRadius.circular(AppRadius.radiusCard),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.spacingLg),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentPrimary
                                        : textColor.withOpacity(0.1),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.radiusCard),
                                  color: isSelected
                                      ? AppColors.accentPrimary.withOpacity(0.05)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: isSelected
                                          ? AppColors.accentPrimary
                                          : secondaryColor,
                                    ),
                                    const SizedBox(width: AppSpacing.spacingMd),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getPackageTitle(package),
                                            style: AppTextStyles.bodyLarge(textColor).copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getPackageSubtitle(package),
                                            style: AppTextStyles.bodyMedium(secondaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      package.storeProduct.priceString,
                                      style: AppTextStyles.heading2(textColor).copyWith(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
                if (_isPurchasing)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.accentPrimary),
                    ),
                  ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _packages.isEmpty || _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: _selectedPackage?.packageType == PackageType.lifetime
                        ? "Commit — ${_selectedPackage?.storeProduct.priceString ?? "\$10"} one time"
                        : "Commit — ${_selectedPackage?.storeProduct.priceString ?? "\$1"}/${_selectedPackage?.packageType == PackageType.monthly ? "mo" : "yr"}",
                    onPressed: _isPurchasing ? () {} : _makePurchase,
                  ),
                  const SizedBox(height: AppSpacing.spacingMd),
                  Text(
                    "7-day money-back guarantee",
                    style: AppTextStyles.bodyMedium(secondaryColor),
                  ),
                  const SizedBox(height: AppSpacing.spacingSm),
                ],
              ),
            ),
    );
  }


}

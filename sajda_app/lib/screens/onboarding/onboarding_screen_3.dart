import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/design_system.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/sajda_fade_page_route.dart';
import '../../services/prayer_time_service.dart';
import '../../services/database_service.dart';
import '../../services/platform_channel_service.dart';
import '../../services/distraction_manager.dart';
import '../../services/ios_distraction_service.dart';
import '../../models/app_settings.dart';
import '../home/home_screen.dart';
import 'dart:io';

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({super.key});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final DatabaseService _db = DatabaseService.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingScreenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                Platform.isIOS ? "Define your boundaries." : "Enable the environment.",
                style: AppTextStyles.heading1(textColor),
              ),
              const SizedBox(height: AppSpacing.spacingMd),
              Text(
                Platform.isIOS 
                    ? "Select apps to block during salah." 
                    : "Sajda requires accessibility and overlay permissions to create a distraction-free space during prayer windows.",
                style: AppTextStyles.bodyLarge(textColor),
              ),
              const Spacer(),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
                  ),
                )
              else
                PrimaryButton(
                  label: Platform.isIOS ? "CHOOSE DISTRACTIONS" : "GRANT PERMISSIONS",
                  onPressed: _handlePermissions,
                ),
              const SizedBox(height: AppSpacing.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (Platform.isAndroid) {
        final hasOverlayPermission = await PlatformChannelService.checkOverlayPermission();
        if (!hasOverlayPermission) {
          await PlatformChannelService.requestOverlayPermission();
          // Wait briefly to allow user to return, or in a real app, use a listener.
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final hasBatteryOpt = await PlatformChannelService.checkBatteryOptimization();
        if (!hasBatteryOpt) {
          await PlatformChannelService.requestBatteryOptimization();
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } else if (Platform.isIOS) {
        final iosService = DistractionManager.instance as IOSDistractionService;
        await iosService.init(); // Triggers Screen Time authorization
        await iosService.selectAppsToBlock();
      }

      await _completeOnboarding();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // Auto-detect location and setup defaults
      final position = await _prayerTimeService.getCurrentLocation();
      
      String calcMethod = 'muslim_world_league';
      final lat = position.latitude;
      final lng = position.longitude;

      if (lng > -130 && lng < -60 && lat > 20) {
        calcMethod = 'north_america';
      } else if (lng > 60 && lng < 100 && lat > 5) {
        calcMethod = 'karachi';
      } else if (lng > 35 && lng < 60 && lat > 15) {
        calcMethod = 'umm_al_qura';
      }

      final settings = AppSettings(
        latitude: lat,
        longitude: lng,
        lockDurationMinutes: 15,
        gracePeriodMinutes: 5,
        calculationMethod: calcMethod,
      );
      
      await _db.createAppSettings(settings);
      await _prayerTimeService.updatePrayerTimes();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          SajdaFadePageRoute(child: const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    }
  }
}

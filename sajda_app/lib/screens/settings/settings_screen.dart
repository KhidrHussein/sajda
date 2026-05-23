import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../../theme/design_system.dart';
import '../../services/database_service.dart';
import '../../services/distraction_manager.dart';
import '../../services/ios_distraction_service.dart';
import '../../services/platform_channel_service.dart';
import '../../services/battery_optimization_service.dart';
import '../../services/scheduler_service.dart';
import '../../services/alarm_callback.dart';
import '../../models/app_settings.dart';
import '../../widgets/primary_button.dart';
import '../logo_gallery_screen.dart';
import '../paywall/paywall_screen.dart';
import '../../services/billing_service.dart';
import '../../services/notification_service.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService.instance;
  AppSettings? _settings;
  bool _isLoading = true;
  bool _hasOverlayPermission = false;
  bool _hasBatteryPermission = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await _db.getAppSettings();
    bool hasOverlay = false;
    bool hasBattery = false;
    
    if (Platform.isAndroid) {
      hasOverlay = await PlatformChannelService.checkOverlayPermission();
      hasBattery = await BatteryOptimizationService.hasAllPermissions();
    }

    setState(() {
      _settings = settings;
      _hasOverlayPermission = hasOverlay;
      _hasBatteryPermission = hasBattery;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: AppTextStyles.heading2(textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingLg),
        children: [
          _buildPremiumSection(textColor, secondaryColor),
          const Divider(height: AppSpacing.spacingXl),
          _buildSectionHeader("Configuration", secondaryColor),
          _buildDurationPicker(
            "Lock Duration",
            _settings?.lockDurationMinutes ?? 10,
            (val) async {
              final updated = _settings!.copyWith(lockDurationMinutes: val);
              await _db.updateAppSettings(updated);
              await SchedulerService().reschedule();
              _loadData();
            },
            textColor,
            secondaryColor,
          ),
          _buildSliderPicker(
            "Grace Period",
            "The time after the actual prayer time before the app lock is triggered. 0 means it locks exactly at the Adhan.",
            _settings?.gracePeriodMinutes ?? 5,
            0,
            30,
            (val) async {
              final updated = _settings!.copyWith(gracePeriodMinutes: val.toInt());
              await _db.updateAppSettings(updated);
              await SchedulerService().reschedule();
              _loadData();
            },
            textColor,
            secondaryColor,
          ),
          _buildDropdownPicker(
            "Calculation Method",
            "Select the calculation convention used to compute prayer times based on your location.",
            _settings?.calculationMethod ?? 'muslim_world_league',
            {
              'muslim_world_league': 'Muslim World League',
              'egyptian': 'Egyptian General Authority',
              'karachi': 'University of Islamic Sciences, Karachi',
              'umm_al_qura': 'Umm Al-Qura, Makkah',
              'dubai': 'Dubai',
              'moonsighting_committee': 'Moonsighting Committee',
              'north_america': 'ISNA (North America)',
              'kuwait': 'Kuwait',
              'qatar': 'Qatar',
              'singapore': 'Singapore',
              'tehran': 'Tehran',
              'turkey': 'Turkey',
            },
            (val) async {
              if (val != null) {
                final updated = _settings!.copyWith(calculationMethod: val);
                await _db.updateAppSettings(updated);
                await SchedulerService().reschedule();
                _loadData();
              }
            },
            textColor,
            secondaryColor,
          ),
          _buildDropdownPicker(
            "Madhab (Asr Time)",
            "Hanafi delays Asr until shadow length equals twice the object's length. Shafi/Maliki/Hanbali uses standard single shadow length.",
            _settings?.madhab ?? 'shafi',
            {
              'shafi': 'Shafi, Maliki, Hanbali (Standard)',
              'hanafi': 'Hanafi (Later Asr)',
            },
            (val) async {
              if (val != null) {
                final updated = _settings!.copyWith(madhab: val);
                await _db.updateAppSettings(updated);
                await SchedulerService().reschedule();
                _loadData();
              }
            },
            textColor,
            secondaryColor,
          ),
          const Divider(height: AppSpacing.spacingXl),
          _buildSectionHeader("Prayer Adjustments", secondaryColor),
          ListTile(
            title: Row(
              children: [
                Text("Iqamah Adjustments", style: AppTextStyles.bodyLarge(textColor)),
                const SizedBox(width: AppSpacing.spacingSm),
                GestureDetector(
                  onTap: () => _showInfoDialog(
                    "Iqamah Adjustments",
                    "Add or subtract minutes from the calculated time to match your local mosque's Iqamah time.",
                    textColor,
                    secondaryColor,
                  ),
                  child: Icon(Icons.info_outline, size: 18, color: secondaryColor),
                ),
              ],
            ),
            subtitle: Text("Manually adjust prayer times", style: AppTextStyles.bodyMedium(secondaryColor)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showPrayerAdjustmentsModal(textColor, secondaryColor),
          ),
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text("Play Adhan Sound", style: AppTextStyles.bodyLarge(textColor)),
            subtitle: Text("Play the Adhan with notifications when it's time for salah", style: AppTextStyles.bodyMedium(secondaryColor)),
            value: _settings?.playAdhan ?? false,
            activeColor: AppColors.accentPrimary,
            onChanged: (val) async {
              final updated = _settings!.copyWith(playAdhan: val);
              await _db.updateAppSettings(updated);
              await SchedulerService().reschedule();
              _loadData();
            },
          ),
          if (Platform.isIOS)
            ListTile(
              title: Text("Manage Blocked Apps", style: AppTextStyles.bodyLarge(textColor)),
              trailing: Icon(Icons.chevron_right, color: secondaryColor),
              onTap: () async {
                final iosService = DistractionManager.instance as IOSDistractionService;
                await iosService.selectAppsToBlock();
              },
            ),
          
          const Divider(height: AppSpacing.spacingXl),
          _buildSectionHeader("System Permissions", secondaryColor),
          if (Platform.isAndroid) ...[
            _buildPermissionTile(
              "Overlay Permission",
              _hasOverlayPermission,
              () async {
                await PlatformChannelService.requestOverlayPermission();
                _loadData();
              },
              textColor,
              secondaryColor,
            ),
            _buildPermissionTile(
              "Battery Optimization",
              _hasBatteryPermission,
              () async {
                await BatteryOptimizationService.requestScheduleExactAlarmPermission();
                await BatteryOptimizationService.requestIgnoreBatteryOptimizations();
                _loadData();
              },
              textColor,
              secondaryColor,
            ),
          ],

          const Divider(height: AppSpacing.spacingXl),
          _buildSectionHeader("Testing", secondaryColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: PrimaryButton(
              label: "TRIGGER TEST PRAYER (10S)",
              onPressed: _triggerTestPrayer,
            ),
          ),


          const Divider(height: AppSpacing.spacingXl),
          _buildSectionHeader("Danger Zone", secondaryColor),
          ListTile(
            title: Text("Reset Streaks", style: AppTextStyles.bodyLarge(AppColors.actionDestructive)),
            onTap: _showResetConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(Color textColor, Color secondaryColor) {
    return AnimatedBuilder(
      animation: BillingService(),
      builder: (context, _) {
        final billing = BillingService();
        final isPremium = billing.isPremium;
        
        String title;
        String subtitle;
        
        if (isPremium) {
          title = "Lifetime Commitment Active";
          subtitle = "Thank you for committing to your Salah!";
        } else {
          title = "Commit to Sajda";
          subtitle = "Remove distractions forever with a one-time commitment";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Account", secondaryColor),
            ListTile(
              leading: Icon(
                isPremium ? Icons.verified_rounded : Icons.lock_clock_rounded,
                color: isPremium ? AppColors.accentPrimary : secondaryColor,
              ),
              title: Text(
                title,
                style: AppTextStyles.bodyLarge(
                  isPremium ? AppColors.accentPrimary : textColor,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: AppTextStyles.bodyMedium(secondaryColor),
              ),
              trailing: isPremium ? null : const Icon(Icons.chevron_right),
              onTap: isPremium
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaywallScreen()),
                      );
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.button(color).copyWith(fontSize: 11, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildDurationPicker(String title, int currentVal, Function(int) onSelect, Color textColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(title, style: AppTextStyles.bodyLarge(textColor)),
          subtitle: Text("$currentVal minutes", style: AppTextStyles.bodyMedium(secondaryColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [5, 10, 15, 20].map((mins) {
              final isSelected = currentVal == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => onSelect(mins),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentPrimary : Colors.transparent,
                        border: Border.all(color: isSelected ? AppColors.accentPrimary : secondaryColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(AppRadius.radiusButton),
                      ),
                      child: Center(
                        child: Text(
                          "$mins",
                          style: AppTextStyles.button(isSelected ? AppColors.textPrimaryLight : textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingSm),
      ],
    );
  }

  Widget _buildPermissionTile(String title, bool granted, VoidCallback onGrant, Color textColor, Color secondaryColor) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyLarge(textColor)),
      trailing: granted 
        ? const Icon(Icons.check_circle, color: AppColors.accentPrimary)
        : TextButton(
            onPressed: onGrant,
            child: Text("GRANT", style: AppTextStyles.button(AppColors.accentPrimary)),
          ),
    );
  }

  void _triggerTestPrayer() async {
    if (Platform.isAndroid) {
      await SchedulerService().reschedule();
      final triggerTime = DateTime.now().add(const Duration(seconds: 10));

      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 10),
        100,
        alarmCallback,
        exact: true,
        wakeup: true,
        params: {
          'playAdhan': _settings?.playAdhan ?? false,
          'isLockNotification': true,
        },
      );
      await PlatformChannelService.scheduleNativeAlarm(
        'Test Prayer',
        60,
        triggerTime,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test prayer scheduled for 10 seconds. Close the app!')),
        );
      }
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimaryDark,
        title: Text("Reset Streaks?", style: AppTextStyles.heading2(AppColors.textPrimaryDark)),
        content: Text(
          "This will reset your current and longest streaks. This action cannot be undone.",
          style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: AppTextStyles.button(AppColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetStreaks();
            },
            child: Text("RESET", style: AppTextStyles.button(AppColors.actionDestructive)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetStreaks() async {
    final streak = await _db.getStreak();
    if (streak != null) {
      final resetStreak = streak.copyWith(
        currentStreak: 0,
        longestStreak: 0,
        lastUpdated: DateTime.now(),
      );
      await _db.updateStreak(resetStreak);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Streaks reset successfully")),
      );
    }
  }

  Widget _buildSliderPicker(String title, String tooltip, int currentVal, double min, double max, Function(double) onChanged, Color textColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Row(
            children: [
              Text(title, style: AppTextStyles.bodyLarge(textColor)),
              const SizedBox(width: AppSpacing.spacingSm),
              GestureDetector(
                onTap: () => _showInfoDialog(title, tooltip, textColor, secondaryColor),
                child: Icon(Icons.info_outline, size: 18, color: secondaryColor),
              ),
            ],
          ),
          subtitle: Text("${currentVal.toInt()} minutes", style: AppTextStyles.bodyMedium(secondaryColor)),
        ),
        Slider(
          value: currentVal.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppColors.accentPrimary,
          inactiveColor: secondaryColor.withOpacity(0.3),
          label: "${currentVal.toInt()}m",
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.spacingSm),
      ],
    );
  }

  Widget _buildDropdownPicker(String title, String tooltip, String currentValue, Map<String, String> options, Function(String?) onChanged, Color textColor, Color secondaryColor) {
    return ListTile(
      title: Row(
        children: [
          Text(title, style: AppTextStyles.bodyLarge(textColor)),
          const SizedBox(width: AppSpacing.spacingSm),
          GestureDetector(
            onTap: () => _showInfoDialog(title, tooltip, textColor, secondaryColor),
            child: Icon(Icons.info_outline, size: 18, color: secondaryColor),
          ),
        ],
      ),
      subtitle: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          dropdownColor: AppColors.bgPrimaryDark,
          style: AppTextStyles.bodyMedium(textColor),
          items: options.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showPrayerAdjustmentsModal(Color textColor, Color secondaryColor) {
    if (_settings == null) return;
    
    // Create a local copy to manage state inside the modal
    int fajr = _settings!.fajrOffset;
    int dhuhr = _settings!.dhuhrOffset;
    int asr = _settings!.asrOffset;
    int maghrib = _settings!.maghribOffset;
    int isha = _settings!.ishaOffset;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Widget buildSlider(String name, int val, Function(int) onChanged) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: AppTextStyles.bodyLarge(textColor)),
                      Text(
                        "${val > 0 ? '+' : ''}$val min",
                        style: AppTextStyles.bodyMedium(secondaryColor),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: val.toDouble(),
                  min: -60,
                  max: 60,
                  divisions: 120,
                  activeColor: AppColors.accentPrimary,
                  inactiveColor: secondaryColor.withOpacity(0.3),
                  label: "${val > 0 ? '+' : ''}$val",
                  onChanged: (newVal) => setModalState(() => onChanged(newVal.toInt())),
                ),
              ],
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              top: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Iqamah Adjustments", style: AppTextStyles.heading2(textColor)),
                const SizedBox(height: AppSpacing.spacingLg),
                buildSlider("Fajr", fajr, (v) => fajr = v),
                buildSlider("Dhuhr", dhuhr, (v) => dhuhr = v),
                buildSlider("Asr", asr, (v) => asr = v),
                buildSlider("Maghrib", maghrib, (v) => maghrib = v),
                buildSlider("Isha", isha, (v) => isha = v),
                const SizedBox(height: AppSpacing.spacingLg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: PrimaryButton(
                    label: "SAVE ADJUSTMENTS",
                    onPressed: () async {
                      final updated = _settings!.copyWith(
                        fajrOffset: fajr,
                        dhuhrOffset: dhuhr,
                        asrOffset: asr,
                        maghribOffset: maghrib,
                        ishaOffset: isha,
                      );
                      await _db.updateAppSettings(updated);
                      await SchedulerService().reschedule();
                      _loadData();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(String title, String content, Color textColor, Color secondaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgPrimaryDark,
        title: Text(title, style: AppTextStyles.heading2(AppColors.textPrimaryDark)),
        content: Text(content, style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("GOT IT", style: AppTextStyles.button(AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }
}

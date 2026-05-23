import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prayer.dart';
import '../../services/prayer_time_service.dart';
import '../../services/streak_service.dart';
import '../../theme/design_system.dart';
import '../../widgets/sajda_logo.dart';
import '../lock/post_lock_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final StreakService _streakService = StreakService();

  Prayer? _nextPrayer;
  int _currentStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final nextPrayer = await _prayerTimeService.getNextPrayer();
    final streak = await _streakService.getStreak();

    // Check for missed prayers
    final missedPrayer = await _streakService.checkMissedPrayers();
    if (missedPrayer != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PostLockScreen(prayer: missedPrayer),
        ),
      );
      return;
    }

    setState(() {
      _nextPrayer = nextPrayer;
      _currentStreak = streak.currentStreak;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const SajdaLogo(size: 32),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              if (mounted) {
                _loadData();
              }
            },
            icon: Icon(Icons.settings_outlined, color: secondaryColor),
          ),
          const SizedBox(width: AppSpacing.spacingSm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading 
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPrimary))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingScreenHorizontal),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_nextPrayer != null) ...[
                      Text(
                        "Next Prayer",
                        style: AppTextStyles.bodyMedium(secondaryColor),
                      ),
                      const SizedBox(height: AppSpacing.spacingXs),
                      Text(
                        _nextPrayer!.name.displayName,
                        style: AppTextStyles.heading1(textColor),
                      ),
                      const SizedBox(height: AppSpacing.spacingSm),
                      Text(
                        DateFormat.jm().format(_nextPrayer!.time),
                        style: AppTextStyles.displayLarge(textColor),
                      ),
                      const SizedBox(height: AppSpacing.spacingLg),
                      Text(
                        "$_currentStreak Day Streak",
                        style: AppTextStyles.bodyMedium(AppColors.accentPrimary),
                      ),
                    ] else ...[
                      Text(
                        "Rest.",
                        style: AppTextStyles.heading1(textColor),
                      ),
                      const SizedBox(height: AppSpacing.spacingSm),
                      Text(
                        "All prayers for today are complete.",
                        style: AppTextStyles.bodyLarge(textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/prayer.dart';
import '../../models/prayer_log.dart';
import '../../services/database_service.dart';
import '../../theme/design_system.dart';
import '../../widgets/primary_button.dart';

class PostLockScreen extends StatefulWidget {
  final Prayer? prayer;
  final String? prayerName;
  final bool isMissed;

  const PostLockScreen({
    super.key, 
    this.prayer, 
    this.prayerName,
    this.isMissed = false,
  });

  @override
  State<PostLockScreen> createState() => _PostLockScreenState();
}

class _PostLockScreenState extends State<PostLockScreen> with TickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  late AnimationController _confirmController;

  @override
  void initState() {
    super.initState();
    _confirmController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _confirmController.forward();
    }
  }

  Future<void> _handleResponse(PrayerStatus status) async {
    PrayerName? name = widget.prayer?.name;
    if (name == null && widget.prayerName != null) {
      name = PrayerName.values.firstWhere(
        (e) => e.name.toLowerCase() == widget.prayerName!.toLowerCase(),
        orElse: () => PrayerName.fajr,
      );
    }

    if (name != null) {
      final log = PrayerLog(
        date: DateTime.now(),
        prayerName: name,
        status: status,
      );
      await _db.createPrayerLog(log);
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingScreenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _confirmController,
                child: Column(
                  children: [
                    Text(
                      "Did you pray ${widget.prayer?.name.displayName ?? widget.prayerName ?? ''}?",
                      style: AppTextStyles.heading1(textColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spacingLg),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _handleResponse(PrayerStatus.missed),
                            child: Text(
                              "NO",
                              style: AppTextStyles.button(secondaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacingMd),
                        Expanded(
                          child: PrimaryButton(
                            label: "YES",
                            onPressed: () => _handleResponse(PrayerStatus.completed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

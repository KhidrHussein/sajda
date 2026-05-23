import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/prayer.dart';
import '../../theme/design_system.dart';
import '../../services/distraction_service.dart';
import '../../services/distraction_manager.dart';
import '../../data/quotes.dart';
import '../../widgets/sajda_logo.dart';
import 'post_lock_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  final DistractionService _distractionService = DistractionManager.instance;
  late AnimationController _holdController;
  late ReflectionQuote _quote;
  late Timer _quoteTimer;
  late List<int> _quoteIndices;
  int _currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _quoteIndices = List.generate(reflectionQuotes.length, (i) => i)..shuffle();
    _quote = reflectionQuotes[_quoteIndices[_currentQuoteIndex]];
    
    _quoteTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex++;
          if (_currentQuoteIndex >= _quoteIndices.length) {
            _quoteIndices.shuffle();
            _currentQuoteIndex = 0;
          }
          _quote = reflectionQuotes[_quoteIndices[_currentQuoteIndex]];
        });
      }
    });

    _distractionService.addListener(_onLockChanged);
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _showSkipConfirmation();
          _holdController.reset();
        }
      });
  }

  void _onLockChanged() {
    if (!_distractionService.isActive && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PostLockScreen(
            prayer: _distractionService.currentPrayer,
          ),
        ),
      );
    }
    setState(() {});
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgIntervention,
        title: Text(
          'Skip this prayer lock?',
          style: AppTextStyles.heading2(AppColors.textIntervention),
        ),
        content: Text(
          'Are you sure you want to skip this prayer lock?\n\nThis will mark the prayer as missed.',
          style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.button(AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _distractionService.stopDistractionControl();
            },
            child: Text(
              'Skip',
              style: AppTextStyles.button(AppColors.actionDestructive),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    _distractionService.removeListener(_onLockChanged);
    _holdController.dispose();
    super.dispose();
  }

  String _getFormattedTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgIntervention,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_distractionService.currentPrayer?.name.displayName ?? 'Prayer'} is happening now.",
                    style: AppTextStyles.heading2(AppColors.textIntervention),
                  ),
                  const SizedBox(height: AppSpacing.spacingLg),
                  Text(
                    _getFormattedTime(_distractionService.remainingSeconds),
                    style: AppTextStyles.displayLarge(AppColors.textIntervention).copyWith(
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingSm),
                  Text(
                    "Remaining in window",
                    style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: AppSpacing.spacingXxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingLg),
                    child: Column(
                      children: [
                        Text(
                          _quote.text,
                          style: AppTextStyles.reflection(AppColors.textIntervention),
                          textAlign: TextAlign.center,
                        ),
                        if (_quote.source != null) ...[
                          const SizedBox(height: AppSpacing.spacingSm),
                          Text(
                            _quote.source!,
                            style: AppTextStyles.bodyMedium(AppColors.textSecondaryDark).copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.spacingXxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Opacity(
                      opacity: 0.2,
                      child: SajdaLogo(size: 80, color: AppColors.textIntervention),
                    ),
                    const SizedBox(height: AppSpacing.spacingXxl),
                    GestureDetector(
                      onLongPressStart: (_) => _holdController.forward(),
                      onLongPressEnd: (_) => _holdController.reverse(from: _holdController.value),
                      child: AnimatedBuilder(
                        animation: _holdController,
                        builder: (context, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Press and hold to exit",
                                style: AppTextStyles.bodyMedium(
                                  Color.lerp(AppColors.textSecondaryDark, AppColors.actionDestructive, _holdController.value)!,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.spacingSm),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: _holdController.value,
                                  backgroundColor: AppColors.bgIntervention.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.actionDestructive),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

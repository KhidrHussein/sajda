import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/sajda_fade_page_route.dart';
import 'onboarding_screen_3.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
              Text(
                "A Quiet Shift.",
                style: AppTextStyles.heading1(textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingMd),
              Text(
                "This tool is built to reinforce one truth: I am someone who prays on time.",
                style: AppTextStyles.bodyLarge(textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingLg),
              Text(
                "To make this possible, Sajda will need specific device permissions on the next screen to manage your digital environment during prayer times.",
                style: AppTextStyles.bodyMedium(secondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.spacingXxl),
              PrimaryButton(
                label: "COMMIT TO STRUCTURE",
                onPressed: () {
                  Navigator.push(
                    context,
                    SajdaFadePageRoute(
                      child: const OnboardingScreen3(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

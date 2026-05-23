import 'package:flutter/material.dart';
import '../theme/design_system.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final text = textColor ?? (isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingLg),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.button(text),
        ),
      ),
    );
  }
}

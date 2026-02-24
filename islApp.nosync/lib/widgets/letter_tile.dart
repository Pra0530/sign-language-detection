import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final String description;
  final bool isSelected;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.description,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryTeal],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.glassDark : AppColors.glassLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? AppColors.glassDarkBorder
                    : AppColors.glassLightBorder),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurple.withAlpha(77),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              Icons.sign_language,
              size: 18,
              color: isSelected
                  ? Colors.white.withAlpha(179)
                  : (isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

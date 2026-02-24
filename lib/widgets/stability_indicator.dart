import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StabilityIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isStable;
  final String letter;

  const StabilityIndicator({
    super.key,
    required this.progress,
    required this.isStable,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              color: Colors.white.withAlpha(26),
            ),
          ),
          // Progress circle
          SizedBox(
            width: 100,
            height: 100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isStable ? AppColors.confidenceHigh : AppColors.primaryTeal,
                  ),
                );
              },
            ),
          ),
          // Letter display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  letter.isEmpty ? '?' : letter,
                  key: ValueKey(letter),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isStable
                        ? AppColors.confidenceHigh
                        : AppColors.textPrimaryDark,
                  ),
                ),
              ),
              if (isStable)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.confidenceHigh,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

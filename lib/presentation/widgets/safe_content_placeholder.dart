import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SafeContentPlaceholder extends StatelessWidget {
  final Widget child;
  final bool shouldBlur;
  final bool shouldBlock;
  final String label;
  final VoidCallback? onReveal;

  const SafeContentPlaceholder({
    super.key,
    required this.child,
    required this.shouldBlur,
    required this.shouldBlock,
    this.label = 'Content hidden for safety',
    this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldBlur && !shouldBlock) {
      return child;
    }

    if (shouldBlock) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.danger, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Explicit content blocked by BeOff Content Shield',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      );
    }

    // Blurred Placeholder
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.65),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_off_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (onReveal != null) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: onReveal,
                        icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                        label: const Text('Show Once'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

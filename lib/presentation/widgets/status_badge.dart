import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum BadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.primary.withOpacity(0.14);
        fg = AppColors.primary;
        break;
      case BadgeType.warning:
        bg = AppColors.warning.withOpacity(0.14);
        fg = AppColors.warning;
        break;
      case BadgeType.danger:
        bg = AppColors.danger.withOpacity(0.14);
        fg = AppColors.danger;
        break;
      case BadgeType.info:
        bg = AppColors.accent.withOpacity(0.14);
        fg = AppColors.accent;
        break;
      case BadgeType.neutral:
        bg = Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDarkSecondary
            : AppColors.surfaceLightSecondary;
        fg = Theme.of(context).brightness == Brightness.dark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

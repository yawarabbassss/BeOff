import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'custom_card.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor ?? AppColors.primary),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: Colors.black,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            inactiveTrackColor: isDark ? AppColors.surfaceDarkSecondary : AppColors.surfaceLightSecondary,
          ),
        ],
      ),
    );
  }
}

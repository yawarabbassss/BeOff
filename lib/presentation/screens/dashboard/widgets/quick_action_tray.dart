import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../widgets/custom_card.dart';

class QuickActionTray extends StatelessWidget {
  const QuickActionTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Controls',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                title: 'Content Safety',
                subtitle: 'Family & Blur',
                icon: Icons.family_restroom_rounded,
                color: AppColors.warning,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.contentSafety),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionItem(
                context,
                title: 'Clean Search',
                subtitle: 'Ad-free engine',
                icon: Icons.search_rounded,
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.cleanSearch),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                title: 'Allow / Block',
                subtitle: 'Custom domains',
                icon: Icons.tune_rounded,
                color: AppColors.accent,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.allowlistBlocklist),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionItem(
                context,
                title: 'Shield Browser',
                subtitle: 'Live test sandbox',
                icon: Icons.travel_explore_rounded,
                color: AppColors.primaryLight,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.protectedBrowser),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

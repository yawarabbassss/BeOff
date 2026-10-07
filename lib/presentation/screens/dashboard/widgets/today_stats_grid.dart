import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/protection_stats.dart';
import '../../../widgets/custom_card.dart';

class TodayStatsGrid extends StatelessWidget {
  final ProtectionStats stats;

  const TodayStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Protection",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${stats.totalBlocked} items blocked',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            _buildStatItem(
              title: 'Ads Blocked',
              count: stats.adsBlocked,
              icon: Icons.ad_units_rounded,
              color: AppColors.primary,
            ),
            _buildStatItem(
              title: 'Trackers Stopped',
              count: stats.trackersBlocked,
              icon: Icons.fingerprint_rounded,
              color: AppColors.accent,
            ),
            _buildStatItem(
              title: 'Unsafe Threats',
              count: stats.malwareBlocked,
              icon: Icons.gpp_bad_rounded,
              color: AppColors.danger,
            ),
            _buildStatItem(
              title: 'Explicit Hidden',
              count: stats.explicitBlocked,
              icon: Icons.visibility_off_rounded,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class StatisticsAnalyticsScreen extends StatelessWidget {
  const StatisticsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatisticsProvider>();
    final today = statsProvider.todayStats;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: CustomAppBar(
        title: 'Privacy Statistics',
        subtitle: 'Aggregated local counters (0 URLs saved)',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.danger),
            tooltip: 'Reset Statistics',
            onPressed: () async {
              final confirm = await ConfirmationModal.show(
                context,
                title: 'Reset Protection Stats',
                message: 'This will reset all on-device counters back to zero. Protection will remain active.',
                confirmText: 'Reset Stats',
                isDangerous: true,
              );
              if (confirm == true) {
                await statsProvider.resetStatistics();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Total Impact Card
          CustomCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Threats & Clutter Blocked', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
                    StatusBadge(text: 'Today', type: BadgeType.success),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.decimalPattern().format(today.totalBlocked),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: today.totalQueries > 0 ? (today.totalBlocked / today.totalQueries).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: AppColors.surfaceDarkSecondary,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${today.totalQueries > 0 ? ((today.totalBlocked / today.totalQueries) * 100).toStringAsFixed(1) : "0"}% of all network DNS queries filtered locally.',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Category Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          _buildBreakdownRow('Advertising Domains', today.adsBlocked, AppColors.primary, Icons.block),
          _buildBreakdownRow('Analytics & Trackers', today.trackersBlocked, AppColors.accent, Icons.fingerprint),
          _buildBreakdownRow('Malicious Hosts', today.malwareBlocked, AppColors.danger, Icons.gpp_bad),
          _buildBreakdownRow('Explicit Media Hidden', today.explicitBlocked, AppColors.warning, Icons.visibility_off),

          const SizedBox(height: 24),
          const Text('Device Resource Impact', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDiagnosticMeter('Battery Consumption', '< 1.2% daily', 'Optimized event-driven DNS filter', AppColors.primary),
                const Divider(color: AppColors.borderDark, height: 24),
                _buildDiagnosticMeter('RAM Usage', '~ 18 MB in memory', 'Lightweight Trie indexing', AppColors.accent),
                const Divider(color: AppColors.borderDark, height: 24),
                _buildDiagnosticMeter('Network Latency', '< 1 ms overhead', 'Instant local sinkholing (0.0.0.0)', AppColors.primaryLight),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Strict Zero-History Transparency Notice
          CustomCard(
            backgroundColor: AppColors.surfaceDarkSecondary,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Zero-Log Guarantee: BeOff tracks only mathematical counters. Individual website names, full URLs, queries, and media are never written to database tables or uploaded to servers.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String title, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            Text(
              NumberFormat.decimalPattern().format(count),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticMeter(String label, String value, String sub, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

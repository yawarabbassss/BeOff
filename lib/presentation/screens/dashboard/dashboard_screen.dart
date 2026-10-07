import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/protection_provider.dart';
import '../../providers/statistics_provider.dart';
import 'widgets/engine_status_chips.dart';
import 'widgets/protection_shield_widget.dart';
import 'widgets/quick_action_tray.dart';
import 'widgets/today_stats_grid.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protectionProvider = context.watch<ProtectionProvider>();
    final statsProvider = context.watch<StatisticsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.shieldActiveGradient,
              ),
              child: const Icon(Icons.shield_rounded, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Text(
              'BeOff',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, size: 22),
            tooltip: 'Statistics & Analytics',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.statistics),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, size: 22),
            tooltip: 'Filter Lists',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.filterHub),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await statsProvider.refreshStats();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Active engine status chips
                EngineStatusChips(
                  settings: protectionProvider.settings,
                  isVpnActive: protectionProvider.isProtected,
                ),

                const SizedBox(height: 32),

                // Central interactive shield button
                ProtectionShieldWidget(
                  status: protectionProvider.status,
                  onTap: () => protectionProvider.toggleProtection(),
                ),

                if (protectionProvider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            protectionProvider.errorMessage!,
                            style: const TextStyle(fontSize: 12, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Aggregated stats grid
                TodayStatsGrid(stats: statsProvider.todayStats),

                const SizedBox(height: 28),

                // Quick Action Tray
                const QuickActionTray(),

                const SizedBox(height: 36),

                // Privacy guarantee note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_rounded, size: 14, color: AppColors.textMutedDark),
                    SizedBox(width: 6),
                    Text(
                      'Zero data collection. 100% on-device filtering.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

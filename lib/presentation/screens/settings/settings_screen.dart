import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/protection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_switch_tile.dart';
import '../../widgets/status_badge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protectionProvider = context.watch<ProtectionProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settings = protectionProvider.settings;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'App preferences & engine controls',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Account / Cloud Sync Card
          CustomCard(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: authProvider.isAuthenticated ? AppColors.primary : AppColors.surfaceDarkSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    authProvider.isAuthenticated ? Icons.person_rounded : Icons.person_outline_rounded,
                    color: authProvider.isAuthenticated ? Colors.black : Colors.white70,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.profile.displayName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authProvider.isAuthenticated ? authProvider.profile.email ?? 'Synced' : 'Guest Mode (Tap to sync settings)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  text: authProvider.isAuthenticated ? 'Synced' : 'Guest',
                  type: authProvider.isAuthenticated ? BadgeType.success : BadgeType.neutral,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Protection Engines', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          CustomSwitchTile(
            title: 'Ad Blocking Engine',
            subtitle: 'Block video ads, banner networks and popups',
            icon: Icons.ad_units_rounded,
            iconColor: AppColors.primary,
            value: settings.isAdBlockingEnabled,
            onChanged: (val) => protectionProvider.updateSettings(settings.copyWith(isAdBlockingEnabled: val)),
          ),
          const SizedBox(height: 8),

          CustomSwitchTile(
            title: 'Tracker & Telemetry Shield',
            subtitle: 'Stop cross-site trackers, pixels and profiling',
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.accent,
            value: settings.isTrackerBlockingEnabled,
            onChanged: (val) => protectionProvider.updateSettings(settings.copyWith(isTrackerBlockingEnabled: val)),
          ),
          const SizedBox(height: 8),

          CustomSwitchTile(
            title: 'Malware & Phishing Protection',
            subtitle: 'Sinkhole known scam domains and cryptominers',
            icon: Icons.gpp_good_rounded,
            iconColor: AppColors.danger,
            value: settings.isMalwareProtectionEnabled,
            onChanged: (val) => protectionProvider.updateSettings(settings.copyWith(isMalwareProtectionEnabled: val)),
          ),
          const SizedBox(height: 8),

          CustomSwitchTile(
            title: 'Content Safety & Blur',
            subtitle: 'Detect and blur nudity / explicit media on-device',
            icon: Icons.visibility_off_rounded,
            iconColor: AppColors.warning,
            value: settings.isContentSafetyEnabled,
            onChanged: (val) => protectionProvider.updateSettings(settings.copyWith(isContentSafetyEnabled: val)),
          ),

          const SizedBox(height: 24),
          const Text('Advanced Management', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          _buildNavTile(
            context,
            title: 'Child Protection Mode',
            subtitle: 'Parent PIN lock, strict safe search & filter locking',
            icon: Icons.child_care_rounded,
            color: AppColors.primary,
            route: AppRoutes.childMode,
          ),
          _buildNavTile(
            context,
            title: 'Filter Lists & Update Feeds',
            subtitle: 'Manage community EasyList rules and updates',
            icon: Icons.shield_outlined,
            color: AppColors.accent,
            route: AppRoutes.filterHub,
          ),
          _buildNavTile(
            context,
            title: 'Custom Allow & Block Lists',
            subtitle: 'Manage specific domain exceptions',
            icon: Icons.tune_rounded,
            color: AppColors.primaryLight,
            route: AppRoutes.allowlistBlocklist,
          ),
          _buildNavTile(
            context,
            title: 'Security & DNS Diagnostics',
            subtitle: 'System health, memory consumption and logs',
            icon: Icons.health_and_safety_outlined,
            color: AppColors.info,
            route: AppRoutes.diagnostics,
          ),
          _buildNavTile(
            context,
            title: 'About, Privacy & Licenses',
            subtitle: 'Open-source notices and zero-log privacy policy',
            icon: Icons.info_outline_rounded,
            color: AppColors.textSecondaryDark,
            route: AppRoutes.about,
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedDark),
          ],
        ),
      ),
    );
  }
}

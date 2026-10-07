import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/protection_settings.dart';
import '../../../widgets/status_badge.dart';

class EngineStatusChips extends StatelessWidget {
  final ProtectionSettings settings;
  final bool isVpnActive;

  const EngineStatusChips({
    super.key,
    required this.settings,
    required this.isVpnActive,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          StatusBadge(
            text: isVpnActive ? 'DNS Filter ON' : 'DNS Inactive',
            type: isVpnActive ? BadgeType.success : BadgeType.neutral,
            icon: Icons.vpn_lock_rounded,
          ),
          const SizedBox(width: 8),
          StatusBadge(
            text: settings.isAdBlockingEnabled ? 'Ads Guard' : 'Ads Off',
            type: settings.isAdBlockingEnabled && isVpnActive ? BadgeType.success : BadgeType.neutral,
            icon: Icons.block,
          ),
          const SizedBox(width: 8),
          StatusBadge(
            text: settings.isTrackerBlockingEnabled ? 'Anti-Tracker' : 'Trackers Off',
            type: settings.isTrackerBlockingEnabled && isVpnActive ? BadgeType.info : BadgeType.neutral,
            icon: Icons.fingerprint,
          ),
          const SizedBox(width: 8),
          StatusBadge(
            text: settings.isContentSafetyEnabled ? 'Content Shield' : 'Content Off',
            type: settings.isContentSafetyEnabled ? BadgeType.warning : BadgeType.neutral,
            icon: Icons.security,
          ),
          if (settings.isChildProtectionMode) ...[
            const SizedBox(width: 8),
            const StatusBadge(
              text: 'Child Mode Active',
              type: BadgeType.success,
              icon: Icons.child_care_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

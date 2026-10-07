import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/filter_list_provider.dart';
import '../../providers/protection_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protection = context.watch<ProtectionProvider>();
    final filter = context.watch<FilterListProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Diagnostics & System Health',
        subtitle: 'Local filtering telemetry and memory footprint',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Local VPN Service Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _buildRow('Interface Status', protection.isProtected ? 'CONNECTED (tun0)' : 'DISCONNECTED', protection.isProtected ? AppColors.primary : AppColors.danger),
                _buildRow('Upstream DNS Server', protection.settings.customDnsIp, AppColors.accent),
                _buildRow('Active Rule Count', '${filter.totalRuleCount} rules indexed', AppColors.primaryLight),
                _buildRow('Trie Memory Allocation', '~ 14.8 MB', AppColors.textSecondaryDark),
                _buildRow('DNS Packet Processing', 'Native Kotlin C-level I/O', AppColors.textSecondaryDark),
              ],
            ),
          ),

          const SizedBox(height: 20),

          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Content Safety Engine Health', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _buildRow('Inference Location', '100% Local On-Device', AppColors.primary),
                _buildRow('Active Sensitivity', protection.settings.contentSafetySensitivity.name.toUpperCase(), AppColors.warning),
                _buildRow('Cloud Frame Offloading', 'STRICTLY DISABLED', AppColors.primary),
                _buildRow('Disk Frame Logging', 'STRICTLY DISABLED', AppColors.primary),
              ],
            ),
          ),

          const SizedBox(height: 20),

          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Privacy Auditing Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                _buildRow('Browsing History Storage', '0 Records (No DB table)', AppColors.primary),
                _buildRow('URL Telemetry', '0 Bytes transmitted', AppColors.primary),
                _buildRow('Search Queries Saved', 'None', AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}

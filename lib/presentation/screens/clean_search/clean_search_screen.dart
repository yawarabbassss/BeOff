import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/protection_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_switch_tile.dart';

class CleanSearchScreen extends StatelessWidget {
  const CleanSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final protectionProvider = context.watch<ProtectionProvider>();
    final settings = protectionProvider.settings;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Clean Search & Annoyances',
        subtitle: 'Ad-free search results & popup remover',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          CustomSwitchTile(
            title: 'Clean Search Results',
            subtitle: 'Strip sponsored ads and promotional boxes from search engines',
            icon: Icons.search_rounded,
            iconColor: AppColors.primary,
            value: settings.isCleanSearchEnabled,
            onChanged: (val) {
              protectionProvider.updateSettings(settings.copyWith(isCleanSearchEnabled: val));
            },
          ),
          const SizedBox(height: 12),

          CustomSwitchTile(
            title: 'Cookie & Annoyance Blocker',
            subtitle: 'Automatically dismiss GDPR cookie banners and newsletter popups',
            icon: Icons.cookie_outlined,
            iconColor: AppColors.warning,
            value: settings.isAnnoyanceBlockingEnabled,
            onChanged: (val) {
              protectionProvider.updateSettings(settings.copyWith(isAnnoyanceBlockingEnabled: val));
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Supported Search Engines',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          _buildEngineCard('Google Search', 'Removes top & bottom text ads, sponsored cards, and shopping units.'),
          _buildEngineCard('Bing Search', 'Removes sponsored search results and promotional sidebars.'),
          _buildEngineCard('DuckDuckGo', 'Hides sponsored affiliate links and ad snippets.'),
          _buildEngineCard('Yahoo Search', 'Removes sponsored listings and promotional banners.'),

          const SizedBox(height: 20),

          CustomCard(
            backgroundColor: AppColors.surfaceDarkSecondary,
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search Cleanup applies across supported browser webviews and network filtering rules.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineCard(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/content_safety_result.dart';
import '../../../routes/app_routes.dart';
import '../../providers/content_safety_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_switch_tile.dart';

class ContentSafetyScreen extends StatelessWidget {
  const ContentSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safetyProvider = context.watch<ContentSafetyProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Content Safety Shield',
        subtitle: 'Protect against nudity and explicit media',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Master switch
          CustomSwitchTile(
            title: 'Content Protection',
            subtitle: 'Automatically detect & blur explicit or suggestive web media',
            icon: Icons.shield_outlined,
            iconColor: AppColors.warning,
            value: safetyProvider.isContentSafetyEnabled,
            onChanged: (val) => safetyProvider.toggleContentSafety(val),
          ),

          const SizedBox(height: 20),

          // Child Mode Banner Card
          CustomCard(
            backgroundColor: AppColors.primary.withOpacity(0.08),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.child_care_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Child Protection Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  safetyProvider.isChildProtectionMode
                      ? 'Child Mode is currently ACTIVE and locked with parental PIN.'
                      : 'Lock strict adult blocking, safe search, and tamper prevention for children.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.4),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: safetyProvider.isChildProtectionMode ? 'Manage Child Lock' : 'Enable Child Mode',
                  variant: ButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.childMode),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Protection Sensitivity',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          _buildSensitivityOption(
            context,
            title: 'Strict / Child Mode',
            subtitle: 'Aggressively filters suggestive & explicit imagery. Safe search enforced.',
            sensitivity: ContentSafetySensitivity.strictChild,
            current: safetyProvider.sensitivity,
            onSelect: () => safetyProvider.setSensitivity(ContentSafetySensitivity.strictChild),
          ),
          _buildSensitivityOption(
            context,
            title: 'High Sensitivity (Recommended)',
            subtitle: 'Blurs nudity, graphic adult imagery, and highly suggestive thumbnails.',
            sensitivity: ContentSafetySensitivity.high,
            current: safetyProvider.sensitivity,
            onSelect: () => safetyProvider.setSensitivity(ContentSafetySensitivity.high),
          ),
          _buildSensitivityOption(
            context,
            title: 'Medium Sensitivity',
            subtitle: 'Blocks confirmed explicit content while reducing false positives on art & anatomy.',
            sensitivity: ContentSafetySensitivity.medium,
            current: safetyProvider.sensitivity,
            onSelect: () => safetyProvider.setSensitivity(ContentSafetySensitivity.medium),
          ),
          _buildSensitivityOption(
            context,
            title: 'Low Sensitivity',
            subtitle: 'Only blocks hardcore adult portals and strictly explicit frames.',
            sensitivity: ContentSafetySensitivity.low,
            current: safetyProvider.sensitivity,
            onSelect: () => safetyProvider.setSensitivity(ContentSafetySensitivity.low),
          ),

          const SizedBox(height: 24),

          // Interactive ML Classifier Sandbox
          CustomCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.science_outlined, color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'On-Device Classifier Lab',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Test local image safety analysis in real-time with zero cloud uploads.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.accent),
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.testClassifier),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSensitivityOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ContentSafetySensitivity sensitivity,
    required ContentSafetySensitivity current,
    required VoidCallback onSelect,
  }) {
    final isSelected = sensitivity == current;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        onTap: onSelect,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderDark,
          width: isSelected ? 1.5 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<ContentSafetySensitivity>(
              value: sensitivity,
              groupValue: current,
              onChanged: (_) => onSelect(),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

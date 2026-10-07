import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';

class AboutLicensesScreen extends StatelessWidget {
  const AboutLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'About BeOff',
        subtitle: 'Version 1.0.0 • Privacy & Open Source',
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.shieldActiveGradient,
              ),
              child: const Icon(Icons.shield_rounded, size: 44, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'BeOff',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Privacy, Ad Blocking & Content Protection',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
            ),
          ),

          const SizedBox(height: 28),
          const Text('Product Principles & Privacy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('1. Local-First Processing', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                SizedBox(height: 4),
                Text('All network evaluation and image classification happens on your device.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                SizedBox(height: 12),
                Text('2. Zero Browsing History', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                SizedBox(height: 4),
                Text('No URLs or searches are ever recorded, saved in databases, or uploaded.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                SizedBox(height: 12),
                Text('3. Honest Security Limits', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
                SizedBox(height: 4),
                Text('We never make false claims or claim 100% detection of all zero-day threats.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Open Source Filter Licenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('EasyList & EasyPrivacy', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                Text('Dual-licensed under GNU GPLv3 and Creative Commons Attribution-ShareAlike 3.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                SizedBox(height: 12),
                Text('BeOff Security Feeds', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                Text('Licensed under MIT Open Source License', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

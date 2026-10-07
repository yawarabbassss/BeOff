import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/protection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = const [
    OnboardingStep(
      title: 'Browse cleaner.\nStay safer.',
      subtitle: 'BeOff creates a high-speed protective shield around your device to eliminate ads, trackers, and explicit content.',
      icon: Icons.shield_outlined,
      accentColor: AppColors.primary,
    ),
    OnboardingStep(
      title: 'Block ads, trackers\nand harmful scams.',
      subtitle: 'Say goodbye to video ad interruptions, invasive cross-site telemetry trackers, and phishing traps.',
      icon: Icons.block_flipped,
      accentColor: AppColors.accent,
    ),
    OnboardingStep(
      title: '100% On-Device\nZero Data Collection.',
      subtitle: 'BeOff runs locally using Android’s secure filtering. Your browsing history is NEVER uploaded, stored, or sold.',
      icon: Icons.lock_outline_rounded,
      accentColor: AppColors.primaryLight,
    ),
    OnboardingStep(
      title: 'Turn protection on.\nNo account required.',
      subtitle: 'You are in full control. Start protecting your family immediately as a guest or sign in to sync settings.',
      icon: Icons.power_settings_new_rounded,
      accentColor: AppColors.primary,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final settingsProvider = context.read<SettingsProvider>();
    final protectionProvider = context.read<ProtectionProvider>();

    await settingsProvider.completeOnboarding();
    await protectionProvider.enableProtection();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Bar with Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.shield_rounded, size: 18, color: Colors.black),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'BeOff',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _steps.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // PageView
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _steps.length,
                  itemBuilder: (ctx, idx) {
                    final step = _steps[idx];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: step.accentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step.accentColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(step.icon, size: 54, color: step.accentColor),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (idx) {
                  final isSelected = idx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.borderDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Action Button
              CustomButton(
                text: _currentPage == _steps.length - 1 ? 'Turn Protection On' : 'Continue',
                icon: _currentPage == _steps.length - 1 ? Icons.power_settings_new_rounded : null,
                onPressed: _nextPage,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

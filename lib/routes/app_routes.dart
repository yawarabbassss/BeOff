import 'package:flutter/material.dart';
import '../presentation/screens/browser/protected_browser_screen.dart';
import '../presentation/screens/clean_search/clean_search_screen.dart';
import '../presentation/screens/content_safety/child_protection_mode_screen.dart';
import '../presentation/screens/content_safety/content_safety_screen.dart';
import '../presentation/screens/content_safety/test_classifier_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/filters/allowlist_blocklist_screen.dart';
import '../presentation/screens/filters/filter_hub_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/security/malware_threat_screen.dart';
import '../presentation/screens/settings/about_licenses_screen.dart';
import '../presentation/screens/settings/account_screen.dart';
import '../presentation/screens/settings/diagnostics_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/statistics/statistics_analytics_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String filterHub = '/filters';
  static const String allowlistBlocklist = '/allowlist-blocklist';
  static const String contentSafety = '/content-safety';
  static const String childMode = '/child-mode';
  static const String testClassifier = '/test-classifier';
  static const String cleanSearch = '/clean-search';
  static const String malwareThreats = '/malware-threats';
  static const String statistics = '/statistics';
  static const String protectedBrowser = '/protected-browser';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String diagnostics = '/diagnostics';
  static const String about = '/about';

  static Map<String, WidgetBuilder> get routes => {
        splash: (ctx) => const SplashScreen(),
        onboarding: (ctx) => const OnboardingScreen(),
        dashboard: (ctx) => const DashboardScreen(),
        filterHub: (ctx) => const FilterHubScreen(),
        allowlistBlocklist: (ctx) => const AllowlistBlocklistScreen(),
        contentSafety: (ctx) => const ContentSafetyScreen(),
        childMode: (ctx) => const ChildProtectionModeScreen(),
        testClassifier: (ctx) => const TestClassifierScreen(),
        cleanSearch: (ctx) => const CleanSearchScreen(),
        malwareThreats: (ctx) => const MalwareThreatScreen(),
        statistics: (ctx) => const StatisticsAnalyticsScreen(),
        protectedBrowser: (ctx) => const ProtectedBrowserScreen(),
        settings: (ctx) => const SettingsScreen(),
        account: (ctx) => const AccountScreen(),
        diagnostics: (ctx) => const DiagnosticsScreen(),
        about: (ctx) => const AboutLicensesScreen(),
      };
}

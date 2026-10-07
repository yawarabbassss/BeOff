import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/theme.dart';
import 'core/utils/logger.dart';
import 'data/local/app_database.dart';
import 'data/local/shared_prefs_helper.dart';
import 'data/remote/filter_downloader.dart';
import 'data/remote/supabase_service.dart';
import 'data/repositories/filter_repository.dart';
import 'data/repositories/protection_repository.dart';
import 'data/repositories/statistics_repository.dart';
import 'data/repositories/user_repository.dart';
import 'domain/services/content_classifier_service.dart';
import 'domain/services/native_vpn_service.dart';
import 'engines/content_safety_engine.dart';
import 'engines/protection_manager.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/content_safety_provider.dart';
import 'presentation/providers/filter_list_provider.dart';
import 'presentation/providers/protection_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/statistics_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce preferred portrait orientation and edge-to-edge transparent system UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  AppLogger.info('Starting BeOff Privacy & Protection Application...', 'Bootstrap');

  // 1. Initialize Local Storage & Database
  final sharedPrefsHelper = await SharedPrefsHelper.create();
  final appDatabase = AppDatabase.instance;

  // 2. Initialize Supabase (Handles offline/placeholder mode safely)
  await SupabaseService.initialize();
  final supabaseService = SupabaseService.instance;

  // 3. Initialize Services & Repositories
  final nativeVpn = NativeVpnService();
  final contentClassifier = ContentClassifierService();
  final filterDownloader = FilterDownloader();

  final filterRepo = FilterRepository(appDatabase, filterDownloader);
  final protectionRepo = ProtectionRepository(sharedPrefsHelper, nativeVpn, supabaseService);
  final statsRepo = StatisticsRepository(appDatabase, nativeVpn);
  final userRepo = UserRepository(supabaseService);

  // 4. Initialize Engines & Protection Manager
  final contentSafetyEngine = ContentSafetyEngine(contentClassifier);
  final protectionManager = ProtectionManager(
    protectionRepo,
    filterRepo,
    statsRepo,
    contentSafetyEngine,
  );

  await protectionManager.initialize();

  runApp(
    BeOffApp(
      sharedPrefsHelper: sharedPrefsHelper,
      filterRepo: filterRepo,
      protectionRepo: protectionRepo,
      statsRepo: statsRepo,
      userRepo: userRepo,
      protectionManager: protectionManager,
      contentSafetyEngine: contentSafetyEngine,
    ),
  );
}

class BeOffApp extends StatelessWidget {
  final SharedPrefsHelper sharedPrefsHelper;
  final FilterRepository filterRepo;
  final ProtectionRepository protectionRepo;
  final StatisticsRepository statsRepo;
  final UserRepository userRepo;
  final ProtectionManager protectionManager;
  final ContentSafetyEngine contentSafetyEngine;

  const BeOffApp({
    super.key,
    required this.sharedPrefsHelper,
    required this.filterRepo,
    required this.protectionRepo,
    required this.statsRepo,
    required this.userRepo,
    required this.protectionManager,
    required this.contentSafetyEngine,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(sharedPrefsHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(userRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ProtectionProvider(protectionRepo, protectionManager),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(statsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => FilterListProvider(filterRepo, protectionManager),
        ),
        ChangeNotifierProxyProvider<ProtectionProvider, ContentSafetyProvider>(
          create: (ctx) => ContentSafetyProvider(
            contentSafetyEngine,
            ctx.read<ProtectionProvider>(),
          ),
          update: (_, protection, safety) =>
              safety ?? ContentSafetyProvider(contentSafetyEngine, protection),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (ctx, settingsProvider, child) {
          return MaterialApp(
            title: 'BeOff',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}

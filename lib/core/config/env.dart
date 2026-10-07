/// Environment configuration reader with safe defaults
class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder-key',
  );

  static const String remoteConfigUrl = String.fromEnvironment(
    'REMOTE_FILTER_FEED_URL',
    defaultValue: 'https://placeholder-project.supabase.co/functions/v1/remote_config',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
}

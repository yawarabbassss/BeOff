import '../../domain/models/protection_stats.dart';
import '../../domain/services/native_vpn_service.dart';
import '../local/app_database.dart';

class StatisticsRepository {
  final AppDatabase _db;
  final NativeVpnService _nativeVpn;

  StatisticsRepository(this._db, this._nativeVpn);

  Future<ProtectionStats> getTodayStats() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final dbStats = await _db.getStatsForDate(today);

    // Merge real-time native counter deltas
    final nativeData = await _nativeVpn.getProtectionStats();
    if (nativeData.isNotEmpty) {
      final nativeAds = (nativeData['adsBlocked'] as num?)?.toInt() ?? 0;
      final nativeTrackers = (nativeData['trackersBlocked'] as num?)?.toInt() ?? 0;
      final nativeMalware = (nativeData['malwareBlocked'] as num?)?.toInt() ?? 0;
      final nativeExplicit = (nativeData['explicitBlocked'] as num?)?.toInt() ?? 0;
      final nativeTotal = (nativeData['totalQueries'] as num?)?.toInt() ?? 0;

      return dbStats.copyWith(
        adsBlocked: dbStats.adsBlocked + nativeAds,
        trackersBlocked: dbStats.trackersBlocked + nativeTrackers,
        malwareBlocked: dbStats.malwareBlocked + nativeMalware,
        explicitBlocked: dbStats.explicitBlocked + nativeExplicit,
        totalQueries: dbStats.totalQueries + nativeTotal,
      );
    }

    return dbStats;
  }

  Future<List<ProtectionStats>> getWeeklyStats() async {
    return await _db.getWeeklyStats();
  }

  Future<void> recordEvent({
    int ads = 0,
    int trackers = 0,
    int malware = 0,
    int explicit = 0,
    int annoyances = 0,
    int queries = 0,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    await _db.recordStatIncrement(
      dateString: today,
      ads: ads,
      trackers: trackers,
      malware: malware,
      explicit: explicit,
      annoyances: annoyances,
      queries: queries,
    );
  }

  Future<void> resetAllStats() async {
    await _db.clearAllStats();
    await _nativeVpn.resetProtectionStats();
  }
}

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/logger.dart';
import '../../domain/models/block_entry.dart';
import '../../domain/models/filter_list_meta.dart';
import '../../domain/models/protection_stats.dart';

/// Local SQLite Persistent Database
/// STRICT PRIVACY: NEVER stores browsing history, URLs, queries, or user content.
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'beoff_local_v1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Allowlist and Custom Blocklist Table
    await db.execute('''
      CREATE TABLE custom_entries (
        domain TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        listType TEXT NOT NULL,
        addedAt TEXT NOT NULL,
        note TEXT,
        isEnabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 2. Filter Lists Metadata Table
    await db.execute('''
      CREATE TABLE filter_lists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        url TEXT,
        localAssetPath TEXT,
        ruleCount INTEGER NOT NULL,
        version TEXT NOT NULL,
        license TEXT NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        lastUpdatedAt TEXT
      )
    ''');

    // 3. Aggregated Daily Protection Statistics (Aggregated counters only)
    await db.execute('''
      CREATE TABLE daily_stats (
        date TEXT PRIMARY KEY,
        adsBlocked INTEGER NOT NULL DEFAULT 0,
        trackersBlocked INTEGER NOT NULL DEFAULT 0,
        malwareBlocked INTEGER NOT NULL DEFAULT 0,
        explicitBlocked INTEGER NOT NULL DEFAULT 0,
        annoyancesBlocked INTEGER NOT NULL DEFAULT 0,
        totalQueries INTEGER NOT NULL DEFAULT 0
      )
    ''');

    AppLogger.info('Local SQLite database initialized with privacy schema.', 'AppDatabase');
  }

  // --- Block / Allow Entries ---
  Future<void> insertOrUpdateEntry(BlockEntry entry) async {
    final db = await database;
    await db.insert(
      'custom_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntry(String domain) async {
    final db = await database;
    await db.delete('custom_entries', where: 'domain = ?', whereArgs: [domain]);
  }

  Future<List<BlockEntry>> getEntries({ListType? listType}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = listType == null
        ? await db.query('custom_entries')
        : await db.query('custom_entries', where: 'listType = ?', whereArgs: [listType.name]);

    return maps.map((m) => BlockEntry.fromMap(m)).toList();
  }

  // --- Filter Lists ---
  Future<void> saveFilterLists(List<FilterListMeta> lists) async {
    final db = await database;
    final batch = db.batch();
    for (final list in lists) {
      batch.insert('filter_lists', list.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<FilterListMeta>> getFilterLists() async {
    final db = await database;
    final maps = await db.query('filter_lists');
    return maps.map((m) => FilterListMeta.fromMap(m)).toList();
  }

  // --- Aggregated Daily Stats ---
  Future<void> recordStatIncrement({
    required String dateString,
    int ads = 0,
    int trackers = 0,
    int malware = 0,
    int explicit = 0,
    int annoyances = 0,
    int queries = 0,
  }) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO daily_stats (date, adsBlocked, trackersBlocked, malwareBlocked, explicitBlocked, annoyancesBlocked, totalQueries)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(date) DO UPDATE SET
        adsBlocked = adsBlocked + excluded.adsBlocked,
        trackersBlocked = trackersBlocked + excluded.trackersBlocked,
        malwareBlocked = malwareBlocked + excluded.malwareBlocked,
        explicitBlocked = explicitBlocked + excluded.explicitBlocked,
        annoyancesBlocked = annoyancesBlocked + excluded.annoyancesBlocked,
        totalQueries = totalQueries + excluded.totalQueries
    ''', [dateString, ads, trackers, malware, explicit, annoyances, queries]);
  }

  Future<ProtectionStats> getStatsForDate(String dateString) async {
    final db = await database;
    final maps = await db.query('daily_stats', where: 'date = ?', whereArgs: [dateString]);
    if (maps.isNotEmpty) {
      return ProtectionStats.fromMap(maps.first);
    }
    return ProtectionStats(date: DateTime.tryParse(dateString) ?? DateTime.now());
  }

  Future<List<ProtectionStats>> getWeeklyStats() async {
    final db = await database;
    final maps = await db.query('daily_stats', orderBy: 'date DESC', limit: 7);
    return maps.map((m) => ProtectionStats.fromMap(m)).toList();
  }

  Future<void> clearAllStats() async {
    final db = await database;
    await db.delete('daily_stats');
  }
}

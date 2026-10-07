import '../../core/utils/logger.dart';
import '../../domain/models/block_entry.dart';
import '../../domain/models/filter_list_meta.dart';
import '../local/app_database.dart';
import '../remote/filter_downloader.dart';

class FilterRepository {
  final AppDatabase _db;
  final FilterDownloader _downloader;

  FilterRepository(this._db, this._downloader);

  static List<FilterListMeta> get defaultLists => [
    FilterListMeta(
      id: 'easylist',
      name: 'EasyList Standard (Ad Blocking)',
      description: 'Primary rule list blocking video ads, banners, and popup networks.',
      url: 'https://easylist.to/easylist/easylist.txt',
      localAssetPath: 'assets/filters/easylist_default.txt',
      ruleCount: 75200,
      version: '2026.10.01',
      license: 'GPLv3 / CC BY-SA 3.0',
      isEnabled: true,
      lastUpdatedAt: DateTime.now(),
    ),
    FilterListMeta(
      id: 'easyprivacy',
      name: 'EasyPrivacy (Trackers & Telemetry)',
      description: 'Blocks analytics scripts, tracking pixels, and behavioral fingerprinting.',
      url: 'https://easylist.to/easylist/easyprivacy.txt',
      localAssetPath: 'assets/filters/easyprivacy_default.txt',
      ruleCount: 38400,
      version: '2026.10.01',
      license: 'GPLv3 / CC BY-SA 3.0',
      isEnabled: true,
      lastUpdatedAt: DateTime.now(),
    ),
    FilterListMeta(
      id: 'beoff_malware',
      name: 'BeOff Malware & Phishing Shield',
      description: 'Blocks malicious domains, cryptominers, ransomware gateways, and phishing hosts.',
      url: 'https://raw.githubusercontent.com/beoff/security-feed/main/malware.txt',
      localAssetPath: 'assets/filters/malware_default.txt',
      ruleCount: 15400,
      version: '2026.10.05',
      license: 'MIT',
      isEnabled: true,
      lastUpdatedAt: DateTime.now(),
    ),
    FilterListMeta(
      id: 'beoff_annoyances',
      name: 'BeOff Annoyance & Cookie Popups',
      description: 'Removes GDPR cookie banners, newsletter subscription overlays, and auto-play prompts.',
      url: 'https://raw.githubusercontent.com/beoff/security-feed/main/annoyances.txt',
      localAssetPath: 'assets/filters/annoyances_default.txt',
      ruleCount: 12100,
      version: '2026.10.05',
      license: 'MIT',
      isEnabled: true,
      lastUpdatedAt: DateTime.now(),
    ),
    FilterListMeta(
      id: 'beoff_explicit',
      name: 'BeOff Adult & Explicit Shield',
      description: 'Network-level blocking of pornographic and explicit adult domains for Family Safety.',
      url: 'https://raw.githubusercontent.com/beoff/security-feed/main/explicit.txt',
      localAssetPath: 'assets/filters/explicit_domains_default.txt',
      ruleCount: 8900,
      version: '2026.10.05',
      license: 'MIT',
      isEnabled: true,
      lastUpdatedAt: DateTime.now(),
    ),
  ];

  Future<List<FilterListMeta>> loadFilterLists() async {
    final stored = await _db.getFilterLists();
    if (stored.isEmpty) {
      await _db.saveFilterLists(defaultLists);
      return defaultLists;
    }
    return stored;
  }

  Future<void> saveFilterLists(List<FilterListMeta> lists) async {
    await _db.saveFilterLists(lists);
  }

  Future<List<String>> getRulesForList(FilterListMeta meta) async {
    return await _downloader.loadFilterRules(meta);
  }

  Future<FilterListMeta> updateList(FilterListMeta meta) async {
    try {
      final newCount = await _downloader.updateFilterList(meta);
      final updated = meta.copyWith(
        ruleCount: newCount,
        lastUpdatedAt: DateTime.now(),
        status: FilterListStatus.updated,
      );
      await _db.saveFilterLists([updated]);
      return updated;
    } catch (e) {
      AppLogger.error('Failed to update filter list: ${meta.id}', e, null, 'FilterRepository');
      return meta.copyWith(
        status: FilterListStatus.error,
        errorMessage: 'Update failed. Using cached rules.',
      );
    }
  }

  // --- Custom Allowlist & Blocklist ---
  Future<List<BlockEntry>> getAllowlist() async {
    return await _db.getEntries(listType: ListType.allowlist);
  }

  Future<List<BlockEntry>> getBlocklist() async {
    return await _db.getEntries(listType: ListType.blocklist);
  }

  Future<void> addEntry(BlockEntry entry) async {
    await _db.insertOrUpdateEntry(entry);
  }

  Future<void> removeEntry(String domain) async {
    await _db.deleteEntry(domain);
  }
}

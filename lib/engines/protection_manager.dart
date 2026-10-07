import 'dart:typed_data';
import '../core/utils/domain_parser.dart';
import '../core/utils/logger.dart';
import '../data/repositories/filter_repository.dart';
import '../data/repositories/protection_repository.dart';
import '../data/repositories/statistics_repository.dart';
import '../domain/models/block_entry.dart';
import '../domain/models/content_safety_result.dart';
import '../domain/models/protection_settings.dart';
import 'ad_block_engine.dart';
import 'annoyance_block_engine.dart';
import 'clean_search_engine.dart';
import 'content_safety_engine.dart';
import 'malware_protection_engine.dart';
import 'tracker_block_engine.dart';

enum NetworkDecisionType {
  allowed,
  blockedAd,
  blockedTracker,
  blockedMalware,
  blockedExplicit,
  blockedAnnoyance,
  blockedCustom,
  allowlisted,
}

class NetworkDecision {
  final NetworkDecisionType type;
  final String domain;
  final String? reason;

  NetworkDecision({
    required this.type,
    required this.domain,
    this.reason,
  });

  bool get isBlocked =>
      type != NetworkDecisionType.allowed && type != NetworkDecisionType.allowlisted;
}

/// Master Coordinator for all BeOff Security and Privacy Engines
class ProtectionManager {
  final ProtectionRepository _protectionRepo;
  final FilterRepository _filterRepo;
  final StatisticsRepository _statsRepo;

  final AdBlockEngine adBlockEngine = AdBlockEngine();
  final TrackerBlockEngine trackerBlockEngine = TrackerBlockEngine();
  final MalwareProtectionEngine malwareEngine = MalwareProtectionEngine();
  final AnnoyanceBlockEngine annoyanceEngine = AnnoyanceBlockEngine();
  final CleanSearchEngine cleanSearchEngine = CleanSearchEngine();
  late final ContentSafetyEngine contentSafetyEngine;

  final Set<String> _userAllowlist = {};
  final Set<String> _userBlocklist = {};

  ProtectionManager(
    this._protectionRepo,
    this._filterRepo,
    this._statsRepo,
    this.contentSafetyEngine,
  );

  /// Initializes all engines with settings, filter lists, and allow/block rules
  Future<void> initialize() async {
    AppLogger.info('Initializing ProtectionManager engines...', 'ProtectionManager');

    final settings = _protectionRepo.getSettings();
    applySettings(settings);

    // Load filter lists and seed engines
    final filterLists = await _filterRepo.loadFilterLists();
    for (final listMeta in filterLists) {
      if (listMeta.isEnabled) {
        final rules = await _filterRepo.getRulesForList(listMeta);
        switch (listMeta.id) {
          case 'easylist':
            adBlockEngine.loadRules(rules);
            break;
          case 'easyprivacy':
            trackerBlockEngine.loadRules(rules);
            break;
          case 'beoff_malware':
            malwareEngine.loadRules(rules);
            break;
          case 'beoff_annoyances':
            annoyanceEngine.loadRules(rules);
            break;
          case 'beoff_explicit':
            contentSafetyEngine.loadExplicitDomains(rules);
            break;
        }
      }
    }

    // Load custom allowlist & blocklist
    final allowlistEntries = await _filterRepo.getAllowlist();
    _userAllowlist.clear();
    _userAllowlist.addAll(allowlistEntries.where((e) => e.isEnabled).map((e) => e.domain.toLowerCase()));

    final blocklistEntries = await _filterRepo.getBlocklist();
    _userBlocklist.clear();
    _userBlocklist.addAll(blocklistEntries.where((e) => e.isEnabled).map((e) => e.domain.toLowerCase()));

    AppLogger.info('ProtectionManager initialized with all rules loaded.', 'ProtectionManager');
  }

  void applySettings(ProtectionSettings settings) {
    adBlockEngine.isEnabled = settings.isProtectionEnabled && settings.isAdBlockingEnabled;
    trackerBlockEngine.isEnabled = settings.isProtectionEnabled && settings.isTrackerBlockingEnabled;
    malwareEngine.isEnabled = settings.isProtectionEnabled && settings.isMalwareProtectionEnabled;
    annoyanceEngine.isEnabled = settings.isProtectionEnabled && settings.isAnnoyanceBlockingEnabled;
    cleanSearchEngine.isEnabled = settings.isProtectionEnabled && settings.isCleanSearchEnabled;
    contentSafetyEngine.isEnabled = settings.isProtectionEnabled && settings.isContentSafetyEnabled;
    contentSafetyEngine.sensitivity = settings.contentSafetySensitivity;
    contentSafetyEngine.isChildProtectionMode = settings.isChildProtectionMode;
  }

  /// Master Network Request Inspector
  /// Evaluates an outgoing request in strict priority order:
  /// 1. User Allowlist (Always bypass)
  /// 2. User Blocklist (Always block)
  /// 3. Malware / Phishing (High security threat)
  /// 4. Explicit Adult Portals (Content safety)
  /// 5. Trackers & Analytics
  /// 6. Ads & Sponsored Networks
  /// 7. Annoyances & Cookie Banners
  Future<NetworkDecision> evaluateRequest(String urlOrDomain) async {
    final domain = DomainParser.normalize(urlOrDomain);
    if (domain.isEmpty) {
      return NetworkDecision(type: NetworkDecisionType.allowed, domain: domain);
    }

    // 1. Allowlist Check
    if (_isDomainInSet(domain, _userAllowlist)) {
      return NetworkDecision(
        type: NetworkDecisionType.allowlisted,
        domain: domain,
        reason: 'Allowlisted by user',
      );
    }

    // 2. Custom Blocklist Check
    if (_isDomainInSet(domain, _userBlocklist)) {
      await _statsRepo.recordEvent(ads: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedCustom,
        domain: domain,
        reason: 'Blocked by custom rule',
      );
    }

    // 3. Malware Check
    if (malwareEngine.isMalicious(domain)) {
      await _statsRepo.recordEvent(malware: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedMalware,
        domain: domain,
        reason: 'Malware or phishing host detected',
      );
    }

    // 4. Explicit Adult Content Check
    if (contentSafetyEngine.isExplicitDomain(domain)) {
      await _statsRepo.recordEvent(explicit: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedExplicit,
        domain: domain,
        reason: 'Explicit adult content domain blocked',
      );
    }

    // 5. Tracker Check
    if (trackerBlockEngine.shouldBlock(domain)) {
      await _statsRepo.recordEvent(trackers: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedTracker,
        domain: domain,
        reason: 'Telemetry or tracking endpoint blocked',
      );
    }

    // 6. Ad Check
    if (adBlockEngine.shouldBlock(domain)) {
      await _statsRepo.recordEvent(ads: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedAd,
        domain: domain,
        reason: 'Advertising domain blocked',
      );
    }

    // 7. Annoyance Check
    if (annoyanceEngine.shouldBlock(domain)) {
      await _statsRepo.recordEvent(annoyances: 1, queries: 1);
      return NetworkDecision(
        type: NetworkDecisionType.blockedAnnoyance,
        domain: domain,
        reason: 'Annoyance / cookie overlay host blocked',
      );
    }

    // Normal allowed traffic
    await _statsRepo.recordEvent(queries: 1);
    return NetworkDecision(type: NetworkDecisionType.allowed, domain: domain);
  }

  /// Evaluates an image frame in memory via local Content Safety Engine
  Future<ContentSafetyResult> evaluateImage(Uint8List imageBytes) async {
    final result = await contentSafetyEngine.evaluateImageFrame(imageBytes);
    if (result.isUnsafe) {
      await _statsRepo.recordEvent(explicit: 1);
    }
    return result;
  }

  // --- Dynamic Allowlist / Blocklist Management ---
  Future<void> allowDomain(String domain) async {
    final clean = DomainParser.normalize(domain);
    _userAllowlist.add(clean);
    _userBlocklist.remove(clean);
    await _filterRepo.addEntry(
      BlockEntry(
        domain: clean,
        type: BlockType.custom,
        listType: ListType.allowlist,
        addedAt: DateTime.now(),
      ),
    );
  }

  Future<void> blockDomain(String domain) async {
    final clean = DomainParser.normalize(domain);
    _userBlocklist.add(clean);
    _userAllowlist.remove(clean);
    await _filterRepo.addEntry(
      BlockEntry(
        domain: clean,
        type: BlockType.custom,
        listType: ListType.blocklist,
        addedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeDomainRule(String domain) async {
    final clean = DomainParser.normalize(domain);
    _userAllowlist.remove(clean);
    _userBlocklist.remove(clean);
    await _filterRepo.removeEntry(clean);
  }

  bool _isDomainInSet(String domain, Set<String> set) {
    if (set.contains(domain)) return true;
    var sub = domain;
    while (sub.contains('.')) {
      final nextDot = sub.indexOf('.');
      sub = sub.substring(nextDot + 1);
      if (set.contains(sub)) return true;
    }
    return false;
  }
}

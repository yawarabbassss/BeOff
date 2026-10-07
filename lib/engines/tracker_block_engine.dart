import '../core/network/url_sanitizer.dart';
import '../core/utils/domain_parser.dart';
import '../data/local/rule_trie.dart';

class TrackerBlockEngine {
  final RuleTrie _trackerTrie = RuleTrie();
  bool isEnabled = true;

  int get ruleCount => _trackerTrie.ruleCount;

  void loadRules(List<String> rules) {
    _trackerTrie.clear();
    for (final rule in rules) {
      _trackerTrie.insert(rule, 'TRACKER');
    }
  }

  /// Evaluates whether a domain is a known telemetry, analytics, or fingerprinting host
  bool shouldBlock(String urlOrDomain) {
    if (!isEnabled) return false;
    final domain = DomainParser.normalize(urlOrDomain);
    return _trackerTrie.matches(domain);
  }

  /// Sanitizes URL to remove UTM, fbclid, gclid, and other cross-site tracking parameters
  String cleanUrl(String rawUrl) {
    if (!isEnabled) return rawUrl;
    return UrlSanitizer.sanitizeUrl(rawUrl);
  }

  /// Checks if URL contains tracking parameters
  bool hasTracking(String rawUrl) {
    return UrlSanitizer.hasTrackingParameters(rawUrl);
  }
}

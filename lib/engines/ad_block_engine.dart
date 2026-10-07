import '../core/utils/domain_parser.dart';
import '../data/local/rule_trie.dart';

class AdBlockEngine {
  final RuleTrie _adTrie = RuleTrie();
  bool isEnabled = true;

  int get ruleCount => _adTrie.ruleCount;

  void loadRules(List<String> rules) {
    _adTrie.clear();
    for (final rule in rules) {
      _adTrie.insert(rule, 'AD');
    }
  }

  /// Evaluates whether a domain or URL belongs to known ad networks
  bool shouldBlock(String urlOrDomain) {
    if (!isEnabled) return false;
    final domain = DomainParser.normalize(urlOrDomain);
    return _adTrie.matches(domain);
  }

  /// CSS rules injected into webviews to eliminate ad containers & banners
  String getCosmeticHideCss() {
    return '''
      [id*="google_ads"], [class*="ad-container"], [class*="ad_banner"],
      [class*="sponsored-post"], [id*="taboola"], [id*="outbrain"],
      .adsbygoogle, .ad-unit, [data-ad-client], .ad-wrapper, .ad-box {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }
    ''';
  }
}

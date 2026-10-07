import '../core/utils/domain_parser.dart';
import '../data/local/rule_trie.dart';

class AnnoyanceBlockEngine {
  final RuleTrie _annoyanceTrie = RuleTrie();
  bool isEnabled = true;

  int get ruleCount => _annoyanceTrie.ruleCount;

  void loadRules(List<String> rules) {
    _annoyanceTrie.clear();
    for (final rule in rules) {
      _annoyanceTrie.insert(rule, 'ANNOYANCE');
    }
  }

  bool shouldBlock(String urlOrDomain) {
    if (!isEnabled) return false;
    final domain = DomainParser.normalize(urlOrDomain);
    return _annoyanceTrie.matches(domain);
  }

  /// CSS rules injected into webviews to eliminate cookie consent dialogs & newsletter popups
  String getAntiAnnoyanceCss() {
    return '''
      #onetrust-consent-sdk, .cc-window, .cookie-banner, .cookie-notice,
      #cookie-law-info-bar, [id*="cookie-notice"], [class*="newsletter-modal"],
      .pushcrew-prompt, [class*="subscribe-popup"], .fancybox-overlay {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
        pointer-events: none !important;
      }
      body {
        overflow: auto !important;
        position: static !important;
      }
    ''';
  }
}

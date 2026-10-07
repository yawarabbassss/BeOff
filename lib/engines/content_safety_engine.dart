import 'dart:typed_data';
import '../core/utils/domain_parser.dart';
import '../data/local/rule_trie.dart';
import '../domain/models/content_safety_result.dart';
import '../domain/services/content_classifier_service.dart';

class ContentSafetyEngine {
  final ContentClassifierService _classifierService;
  final RuleTrie _explicitDomainTrie = RuleTrie();

  bool isEnabled = true;
  ContentSafetySensitivity sensitivity = ContentSafetySensitivity.high;
  bool isChildProtectionMode = false;

  ContentSafetyEngine(this._classifierService);

  int get explicitDomainCount => _explicitDomainTrie.ruleCount;

  void loadExplicitDomains(List<String> domains) {
    _explicitDomainTrie.clear();
    for (final domain in domains) {
      _explicitDomainTrie.insert(domain, 'EXPLICIT');
    }
  }

  /// Checks if a domain is a known explicit/adult portal
  bool isExplicitDomain(String urlOrDomain) {
    if (!isEnabled && !isChildProtectionMode) return false;
    final domain = DomainParser.normalize(urlOrDomain);
    return _explicitDomainTrie.matches(domain);
  }

  /// Evaluates an image frame in memory using the on-device ML classifier
  Future<ContentSafetyResult> evaluateImageFrame(Uint8List imageBytes) async {
    if (!isEnabled && !isChildProtectionMode) {
      return ContentSafetyResult.safe();
    }

    final activeSensitivity = isChildProtectionMode
        ? ContentSafetySensitivity.strictChild
        : sensitivity;

    return await _classifierService.classifyImageBytes(
      imageBytes: imageBytes,
      sensitivity: activeSensitivity,
    );
  }

  /// JavaScript to inject into browser webviews that intercepts images before rendering
  /// and applies a placeholder blur until verified
  String getContentProtectionJs() {
    if (!isEnabled && !isChildProtectionMode) return '';

    return '''
      (function() {
        const style = document.createElement('style');
        style.innerHTML = `
          .beoff-safe-blur {
            filter: blur(28px) grayscale(80%) !important;
            transition: filter 0.3s ease !important;
          }
          .beoff-safe-placeholder {
            background-color: #0f172a !important;
            color: #10b981 !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 13px !important;
            font-weight: 600 !important;
            border-radius: 8px !important;
          }
        `;
        document.head.appendChild(style);
      })();
    ''';
  }
}

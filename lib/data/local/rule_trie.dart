import '../../core/utils/domain_parser.dart';

/// Node in a Reverse Domain Trie
class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEndOfRule = false;
  String? ruleTag;
}

/// High-performance in-memory Reverse Domain Trie for fast Adblock/Hosts matching
class RuleTrie {
  final TrieNode root = TrieNode();
  int _ruleCount = 0;

  int get ruleCount => _ruleCount;

  /// Inserts a domain or EasyList pattern (e.g. `||doubleclick.net^` or `adservice.google.com`)
  void insert(String rawRule, [String? tag]) {
    final cleaned = _parseRule(rawRule);
    if (cleaned.isEmpty) return;

    final parts = cleaned.split('.').reversed.toList();
    TrieNode current = root;

    for (final part in parts) {
      current = current.children.putIfAbsent(part, () => TrieNode());
    }

    if (!current.isEndOfRule) {
      current.isEndOfRule = true;
      current.ruleTag = tag;
      _ruleCount++;
    }
  }

  /// Checks if the target hostname matches any rule in the Trie (accounting for subdomains)
  bool matches(String hostname) {
    final cleanHost = DomainParser.normalize(hostname);
    if (cleanHost.isEmpty) return false;

    final parts = cleanHost.split('.').reversed.toList();
    TrieNode current = root;

    for (final part in parts) {
      if (current.children.containsKey(part)) {
        current = current.children[part]!;
        if (current.isEndOfRule) {
          return true;
        }
      } else {
        break;
      }
    }

    return false;
  }

  /// Clears all rules
  void clear() {
    root.children.clear();
    _ruleCount = 0;
  }

  /// Parses ABP / EasyList format lines into plain domains
  String _parseRule(String rule) {
    var line = rule.trim().toLowerCase();

    // Ignore comments and cosmetic rules
    if (line.isEmpty || line.startsWith('!') || line.startsWith('#') || line.contains('##')) {
      return '';
    }

    // Strip EasyList anchor ||
    if (line.startsWith('||')) {
      line = line.substring(2);
    }

    // Strip separator ^
    if (line.contains('^')) {
      line = line.split('^').first;
    }

    // Strip options $
    if (line.contains('\$')) {
      line = line.split('\$').first;
    }

    return DomainParser.normalize(line);
  }
}

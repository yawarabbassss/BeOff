import 'package:beoff/data/local/rule_trie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleTrie Domain Matching Tests', () {
    late RuleTrie trie;

    setUp(() {
      trie = RuleTrie();
    });

    test('matches exact domain rule', () {
      trie.insert('doubleclick.net');
      expect(trie.matches('doubleclick.net'), isTrue);
      expect(trie.matches('google.com'), isFalse);
    });

    test('matches subdomains automatically', () {
      trie.insert('doubleclick.net');
      expect(trie.matches('ad.doubleclick.net'), isTrue);
      expect(trie.matches('secure.sub.doubleclick.net'), isTrue);
      expect(trie.matches('notdoubleclick.net'), isFalse);
    });

    test('parses EasyList syntax with anchors and separators', () {
      trie.insert('||googleads.g.doubleclick.net^');
      expect(trie.matches('googleads.g.doubleclick.net'), isTrue);
      expect(trie.matches('sub.googleads.g.doubleclick.net'), isTrue);
    });

    test('clearing trie resets rule count and matching', () {
      trie.insert('badactor.com');
      expect(trie.matches('badactor.com'), isTrue);
      trie.clear();
      expect(trie.matches('badactor.com'), isFalse);
      expect(trie.ruleCount, 0);
    });
  });
}

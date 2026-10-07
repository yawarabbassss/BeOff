import 'package:beoff/engines/ad_block_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdBlockEngine Tests', () {
    late AdBlockEngine engine;

    setUp(() {
      engine = AdBlockEngine();
      engine.loadRules([
        '||doubleclick.net^',
        '||googleads.g.doubleclick.net^',
        '||applovin.com^',
      ]);
    });

    test('blocks known ad network domains', () {
      expect(engine.shouldBlock('https://ad.doubleclick.net/pagead/ads'), isTrue);
      expect(engine.shouldBlock('applovin.com'), isTrue);
      expect(engine.shouldBlock('https://wikipedia.org'), isFalse);
    });

    test('disabling engine allows all requests', () {
      engine.isEnabled = false;
      expect(engine.shouldBlock('doubleclick.net'), isFalse);
    });
  });
}

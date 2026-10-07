import 'package:beoff/engines/tracker_block_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackerBlockEngine Tests', () {
    late TrackerBlockEngine engine;

    setUp(() {
      engine = TrackerBlockEngine();
      engine.loadRules([
        '||google-analytics.com^',
        '||segment.io^',
        '||hotjar.com^',
      ]);
    });

    test('blocks analytics and telemetry endpoints', () {
      expect(engine.shouldBlock('https://google-analytics.com/collect'), isTrue);
      expect(engine.shouldBlock('api.segment.io'), isTrue);
      expect(engine.shouldBlock('https://github.com'), isFalse);
    });

    test('cleans URLs with tracking parameters', () {
      final clean = engine.cleanUrl('https://site.com/post?utm_source=fb&gclid=123');
      expect(clean, 'https://site.com/post');
    });
  });
}

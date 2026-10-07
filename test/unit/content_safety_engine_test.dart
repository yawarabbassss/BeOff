import 'dart:typed_data';
import 'package:beoff/domain/models/content_safety_result.dart';
import 'package:beoff/domain/services/content_classifier_service.dart';
import 'package:beoff/engines/content_safety_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentSafetyEngine Tests', () {
    late ContentSafetyEngine engine;
    late ContentClassifierService classifier;

    setUp(() {
      classifier = ContentClassifierService();
      engine = ContentSafetyEngine(classifier);
      engine.loadExplicitDomains([
        '||pornhub.com^',
        '||xvideos.com^',
      ]);
    });

    test('detects and blocks explicit adult domains', () {
      expect(engine.isExplicitDomain('https://m.pornhub.com'), isTrue);
      expect(engine.isExplicitDomain('xvideos.com'), isTrue);
      expect(engine.isExplicitDomain('https://nationalgeographic.com'), isFalse);
    });

    test('evaluates safe image bytes returning safe result', () async {
      final safeBytes = Uint8List(500);
      final result = await engine.evaluateImageFrame(safeBytes);
      expect(result.isUnsafe, isFalse);
      expect(result.category, ContentSafetyCategory.safe);
    });
  });
}

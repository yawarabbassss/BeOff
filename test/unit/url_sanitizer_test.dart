import 'package:beoff/core/network/url_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlSanitizer Tracking Parameters Stripper', () {
    test('strips utm parameters from clean URL', () {
      const raw = 'https://example.com/article?utm_source=twitter&utm_medium=social&utm_campaign=winter_promo';
      final clean = UrlSanitizer.sanitizeUrl(raw);
      expect(clean, 'https://example.com/article');
    });

    test('strips fbclid and gclid while preserving legitimate query params', () {
      const raw = 'https://shop.example.com/item?id=12345&fbclid=IwAR3xYZ&color=blue&gclid=CjwKCAiA';
      final clean = UrlSanitizer.sanitizeUrl(raw);
      expect(clean, 'https://shop.example.com/item?id=12345&color=blue');
    });

    test('detects presence of tracking query parameters accurately', () {
      expect(UrlSanitizer.hasTrackingParameters('https://example.com/?fbclid=123'), isTrue);
      expect(UrlSanitizer.hasTrackingParameters('https://example.com/?utm_source=news'), isTrue);
      expect(UrlSanitizer.hasTrackingParameters('https://example.com/?page=2&sort=asc'), isFalse);
    });
  });
}

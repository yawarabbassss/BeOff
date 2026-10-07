/// URL Sanitizer for Privacy Protection
/// Strips known tracking parameters from URLs to prevent cross-site user tracking
class UrlSanitizer {
  static const Set<String> _knownTrackingParameters = {
    // Google & Analytics
    'utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content',
    'utm_id', 'utm_reader', 'utm_place', 'utm_userid', 'gclid', 'gclsrc', 'dclid',
    // Facebook / Instagram / Meta
    'fbclid', 'igshid', 'fbadid',
    // Twitter / X
    'twclid', 't', 'ref_src', 'ref_url',
    // Microsoft / Bing
    'msclkid',
    // TikTok
    'ttclid', '_s',
    // MailChimp & Email Marketing
    'mc_cid', 'mc_eid', 'vero_id', 'vero_conv', 'wickedid',
    // Yandex
    'yclid', 'ymid',
    // Affiliate & Telemetry
    'aff_id', 'affiliate_id', 'trk_contact', 'trk_msg', 'trk_module', 'trk_sid',
    'spJobID', 'spMailingID', 'spReportId', 'spUserID'
  };

  /// Strips tracking query parameters from the given URL string.
  /// Returns the cleaned URL.
  static String sanitizeUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    
    try {
      final uri = Uri.parse(rawUrl);
      if (!uri.hasQuery) return rawUrl;

      final Map<String, dynamic> filteredQueryParameters = {};
      uri.queryParametersAll.forEach((key, values) {
        final lowerKey = key.toLowerCase();
        if (!_knownTrackingParameters.contains(lowerKey) && !lowerKey.startsWith('utm_')) {
          filteredQueryParameters[key] = values.length == 1 ? values.first : values;
        }
      });

      return uri.replace(queryParameters: filteredQueryParameters.isEmpty ? null : filteredQueryParameters).toString();
    } catch (e) {
      // If parsing fails, return original URL safely
      return rawUrl;
    }
  }

  /// Returns true if the URL contained tracking query parameters that were stripped.
  static bool hasTrackingParameters(String rawUrl) {
    try {
      final uri = Uri.parse(rawUrl);
      if (!uri.hasQuery) return false;

      for (final key in uri.queryParameters.keys) {
        final lowerKey = key.toLowerCase();
        if (_knownTrackingParameters.contains(lowerKey) || lowerKey.startsWith('utm_')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

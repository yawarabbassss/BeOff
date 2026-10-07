/// Clean Search System & Search Engine Cleanup Engine
/// Removes sponsored links, paid boxes, and ad clutter from search engines,
/// and enforces SafeSearch parameters in Child Mode.
class CleanSearchEngine {
  bool isEnabled = true;

  /// Returns SafeSearch sanitized search query URL
  String enforceSafeSearch(String searchUrl, {bool isChildMode = false}) {
    if (!isEnabled && !isChildMode) return searchUrl;

    try {
      final uri = Uri.parse(searchUrl);
      final host = uri.host.toLowerCase();
      final queryParams = Map<String, dynamic>.from(uri.queryParameters);

      // Google
      if (host.contains('google.')) {
        queryParams['safe'] = 'active';
      }
      // Bing
      else if (host.contains('bing.')) {
        queryParams['adlt'] = 'strict';
      }
      // DuckDuckGo
      else if (host.contains('duckduckgo.')) {
        queryParams['kp'] = '1'; // Strict SafeSearch
      }
      // Yahoo
      else if (host.contains('yahoo.')) {
        queryParams['vm'] = 'r'; // Strict SafeSearch
      }

      return uri.replace(queryParameters: queryParams).toString();
    } catch (e) {
      return searchUrl;
    }
  }

  /// Injected CSS rules specifically targeting sponsored search ad containers
  String getCleanSearchCss() {
    if (!isEnabled) return '';
    return '''
      /* Google Search Sponsored Ads */
      #tvcap, #bottomads, .commercial-unit, [data-text-ad], .uEec3, .vdLsw, [aria-label="Sponsored"], .pla-unit {
        display: none !important;
        visibility: hidden !important;
        height: 0 !important;
      }
      /* Bing Search Sponsored Ads */
      .b_ad, .b_adTop, .b_adBottom, .b_algoSubContent_ad {
        display: none !important;
        visibility: hidden !important;
      }
      /* DuckDuckGo Ads */
      .js-badge-main-source, .results--ads {
        display: none !important;
      }
    ''';
  }
}

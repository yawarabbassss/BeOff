/// Fast domain parsing and normalization utility
class DomainParser {
  /// Extracts the clean, normalized domain name from a URL or raw domain string
  static String normalize(String input) {
    if (input.isEmpty) return '';
    String domain = input.trim().toLowerCase();

    // Strip protocols
    if (domain.startsWith('http://')) {
      domain = domain.substring(7);
    } else if (domain.startsWith('https://')) {
      domain = domain.substring(8);
    }

    // Strip port and paths
    final slashIndex = domain.indexOf('/');
    if (slashIndex != -1) {
      domain = domain.substring(0, slashIndex);
    }

    final colonIndex = domain.indexOf(':');
    if (colonIndex != -1) {
      domain = domain.substring(0, colonIndex);
    }

    // Strip trailing dots
    return domain.replaceAll(RegExp(r'\.+$'), '');
  }

  /// Checks if a hostname matches a target rule domain, accounting for subdomains.
  /// Example: 'ad.doubleclick.net' matches 'doubleclick.net'
  static bool matchesDomain(String hostname, String targetRule) {
    final cleanHost = normalize(hostname);
    final cleanTarget = normalize(targetRule);

    if (cleanHost == cleanTarget) return true;
    if (cleanHost.endsWith('.$cleanTarget')) return true;

    return false;
  }
}

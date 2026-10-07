# BeOff — Filter Lists & Rule Engine Specification

## 1. Supported Filter Formats

BeOff parses Adblock Plus (ABP), EasyList, and hosts-file formats.

### Syntax Support:
- `||domain.com^` (Standard domain anchor and separator)
- `||adservice.google.com^$third-party` (Third-party request rule)
- `127.0.0.1 badhost.com` / `0.0.0.0 badhost.com` (Standard hosts syntax)
- Comment lines starting with `!` or `#` are safely skipped.

---

## 2. Bundled & Remote Filter Lists

1. **EasyList Standard (Ad Blocking)**:
   - Primary domain rules for banner, video, and popup ad networks.
   - Dual-licensed under GPLv3 and CC BY-SA 3.0.
   - Local Asset: `assets/filters/easylist_default.txt`
   - Remote URL: `https://easylist.to/easylist/easylist.txt`

2. **EasyPrivacy (Trackers & Telemetry)**:
   - Analytics engines, fingerprinting scripts, tracking pixels, and telemetry beacons.
   - Dual-licensed under GPLv3 and CC BY-SA 3.0.
   - Local Asset: `assets/filters/easyprivacy_default.txt`
   - Remote URL: `https://easylist.to/easylist/easyprivacy.txt`

3. **BeOff Malware & Phishing Shield**:
   - Active malicious domains, ransomware command & control, and cryptojacking endpoints.
   - Licensed under MIT.
   - Local Asset: `assets/filters/malware_default.txt`

4. **BeOff Annoyance & Cookie Popups**:
   - GDPR consent overlays, intrusive subscription modals, and notification prompts.
   - Licensed under MIT.
   - Local Asset: `assets/filters/annoyances_default.txt`

5. **BeOff Explicit & Adult Domains**:
   - Network-level domain blocking for adult and explicit websites.
   - Licensed under MIT.
   - Local Asset: `assets/filters/explicit_domains_default.txt`

---

## 3. High-Speed Trie Indexing & Caching

- Rules are compiled in memory into a **Reverse Domain Trie** (`RuleTrie.dart` / `NetworkFilterEngine.kt`).
- Subdomain lookup complexity: $O(k)$ where $k$ is the number of domain parts (labels).
- Offline updates are cached to the app's sandboxed document storage. If a remote update fails, BeOff automatically rolls back to the last valid cache without disrupting user protection.

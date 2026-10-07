# BeOff 🛡️ — Privacy, Ad Blocking & Content Protection App

[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Flutter-blue.svg)](https://flutter.dev)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-success.svg)](PRIVACY.md)
[![Zero Logs](https://img.shields.io/badge/Browsing%20History-Zero%20Logs-brightgreen.svg)](PRIVACY.md)
[![Status](https://img.shields.io/badge/Release-v1.0.0-cyan.svg)](https://github.com/yawarabbassss/BeOff/releases)

> **Browse cleaner. Stay safer.**  
> BeOff is an Android-first, local-first security and privacy application engineered to shield users and families from ads, cross-site trackers, malicious/phishing websites, sponsored search clutter, and inappropriate sexual/explicit content while maximizing privacy and zero browsing data collection.

---

## 🏷️ Repository Tags & Topics

`#privacy` `#ad-blocker` `#tracker-blocker` `#content-safety` `#family-safety` `#parental-controls` `#android` `#flutter` `#vpnservice` `#dns-filter` `#malware-protection` `#zero-log` `#on-device-ml` `#clean-architecture` `#supabase`

---

## 🌟 Key Pillars & Features

1. **Ad & Pop-Up Blocking**
   - In-memory DNS wire parsing and sinkholing ($0.0.0.0$) via Android `VpnService`.
   - Compatible with EasyList and community filter formats.
   - Cosmetic HTML/CSS ad-container removal for supported browser webviews.

2. **Tracker & Telemetry Shield**
   - Blocks cross-site analytics, tracking pixels, telemetry endpoints, and fingerprinting scripts (EasyPrivacy).
   - Automated query-parameter stripping (`utm_*`, `fbclid`, `gclid`, `mc_eid`, etc.).

3. **On-Device Content Safety Engine**
   - Local computer vision and chrominance heuristic classifier (`SAFE`, `SUGGESTIVE`, `NUDITY`, `EXPLICIT`).
   - **Zero Cloud Leakage**: Frames are processed purely in device RAM and instantly recycled.
   - Pre-render placeholders and blur shields.

4. **Child Protection Mode**
   - Parent PIN lock (SHA-256 hashed with salt via Android Keystore).
   - Strict SafeSearch enforcement (Google, Bing, DuckDuckGo, Yahoo).
   - Strict filter list locks and tamper prevention.
   - **No Surveillance Guarantee**: Protects children without spying on browsing history.

5. **Clean Search & Annoyance Removal**
   - Removes sponsored ads, paid boxes, and recommendation clutter from top search engines.
   - Automatically hides intrusive GDPR cookie banners and newsletter overlays.

6. **Malware & Phishing Protection**
   - Active security threat feed blocking malware drops, ransomware gateways, and phishing scams.
   - Encrypted DNS upstream support (Cloudflare 1.1.1.1, Quad9 9.9.9.9, AdGuard DNS).

7. **Zero-Log Privacy Architecture**
   - **NO Browsing History Database Table**: Zero visited URLs or search queries recorded.
   - **Guest Mode by Default**: Account creation is 100% optional.
   - Optional Supabase sync for cross-device filter preferences and device backup only.

---

## 📂 Project Structure

```
BeOff/
├── LICENSE                # MIT Open Source License
├── android/               # Native Kotlin VPNService, DNS Wire Parser & ML Bridge
├── assets/                # Rule assets (EasyList, EasyPrivacy, Malware, SVG Logo)
├── lib/
│   ├── core/              # Theme, Colors, URL Sanitizer, Domain Parser, PinService
│   ├── data/              # SQLite AppDatabase, RuleTrie, Supabase Service, Repositories
│   ├── domain/            # Models & Native Service Abstractions
│   ├── engines/           # AdBlock, TrackerBlock, Malware, CleanSearch, ContentSafety, Manager
│   ├── presentation/      # Providers, Dashboard, Filters, Content Safety, Browser, Settings
│   └── routes/            # Navigation Route Map
├── supabase/              # PostgreSQL Database Schema, RLS Policies & Edge Functions
├── test/                  # Unit and Widget Tests
└── docs/                  # In-depth architectural & privacy documentation
```

---

## 🚀 Quick Start

1. Clone repository and ensure Flutter SDK (>= 3.16) and Android SDK (API 34) are installed.
2. Copy environment template:
   ```bash
   cp .env.example .env
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run unit and widget tests:
   ```bash
   flutter test
   ```
5. Run on an Android emulator or device:
   ```bash
   flutter run -d android
   ```

---

## 📜 Licenses

* **Application Code**: Licensed under the [MIT License](LICENSE).
* **EasyList & EasyPrivacy**: Dual-licensed under GPLv3 / CC BY-SA 3.0.
* **BeOff Security Feeds**: Licensed under MIT License.

# BeOff — Architecture Specification

## 1. High-Level Architecture Overview

BeOff is built with a clean, decoupled layered architecture separating Flutter UI, State Management, Domain Engines, Native Android Services, Local SQLite Storage, and Supabase Cloud Backend.

```
Flutter UI (Presentation Layer)
  ├── Dashboard Screen & Shield Toggle
  ├── Content Safety & Child Mode
  ├── Filter Hub & Allowlist / Blocklist
  ├── Clean Search & Annoyance Controls
  ├── Protected Sandbox Browser
  ├── Privacy Statistics & Diagnostics
  └── Account & Settings
         │
         ▼
State Management & Providers (ChangeNotifier)
  ├── ProtectionProvider (Syncs with Native VPN state)
  ├── ContentSafetyProvider (Sensitivity, PIN lock)
  ├── FilterListProvider (Rule sets, Allowlist/Blocklist)
  ├── StatisticsProvider (Aggregated counters only)
  └── AuthProvider (Optional Supabase Auth & Guest merge)
         │
         ▼
Protection Manager (Master Coordinator)
  ├── Ad Blocking Engine (EasyList ABP format)
  ├── Tracker Blocking Engine (Telemetry, Pixels & URL Sanitizer)
  ├── Malware Protection Engine (Threat feed & bypass confirmation)
  ├── Annoyance Blocking Engine (Cookie overlays, Newsletter modals)
  ├── Clean Search Engine (Sponsored ads & SafeSearch injection)
  ├── Content Safety Engine (On-device image classifier & blur placeholders)
  └── Allowlist / Blocklist Manager (User domain rules)
         │
         ▼
Native Android Bridge (`BeOffBridgePlugin.kt`)
  ├── MethodChannel (`com.beoff.app/control`)
  └── EventChannel (`com.beoff.app/stats_stream`)
         │
         ▼
Android Native Layer
  ├── `BeOffVpnService.kt` (Android VpnService tun0 interface)
  ├── `DnsPacketParser.kt` (RFC 1035 wire format parser & 0.0.0.0 sinkhole generator)
  ├── `NetworkFilterEngine.kt` (Kotlin Multi-threaded Trie / HashSet domain matcher)
  └── `ContentSafetyClassifier.kt` (On-device pixel heuristic & TFLite pipeline)
```

---

## 2. Local vs Cloud Separation

| Component | Execution Location | Data Persisted | Network Traffic |
| :--- | :--- | :--- | :--- |
| **DNS Request Filtering** | Device (`BeOffVpnService`) | None (Stat counters in RAM) | None for blocked; Direct to Upstream DNS for allowed |
| **Image Frame Classification** | Device (`ContentSafetyClassifier`) | None (Frames recycled immediately) | 0 Bytes |
| **Tracking Parameter Stripper** | Device (`UrlSanitizer`) | None | 0 Bytes |
| **Allowlist / Blocklist** | Device SQLite (`app_database.dart`) | Domain strings | Optional sync to Supabase if authenticated |
| **Protection Statistics** | Device SQLite (`daily_stats` table) | Daily aggregated integer counts | 0 Bytes (never uploaded) |
| **User Account & Settings** | Supabase Cloud | Email, Display Name, Settings Toggles | Encrypted HTTPS with RLS |
| **Browsing History** | **DOES NOT EXIST** | **0 Bytes (No table)** | **0 Bytes** |

---

## 3. Data Flow

1. **Network Request Flow**:
   - Outgoing app network request issues UDP DNS query on port 53.
   - Captured by `BeOffVpnService` via virtual `tun0` interface.
   - Parsed by `DnsPacketParser` to extract hostname (e.g. `adservice.google.com`).
   - `NetworkFilterEngine` checks domain against:
     1. User Allowlist (if found $\rightarrow$ forward to Upstream DNS).
     2. Custom Blocklist (if found $\rightarrow$ send synthetic $0.0.0.0$ response).
     3. Malware / Phishing (if found $\rightarrow$ send synthetic $0.0.0.0$ response).
     4. Explicit / Adult Domains (if found $\rightarrow$ send synthetic $0.0.0.0$ response).
     5. Trackers & Telemetry (if found $\rightarrow$ send synthetic $0.0.0.0$ response).
     6. Ad Networks (if found $\rightarrow$ send synthetic $0.0.0.0$ response).
     7. Normal allowed domain $\rightarrow$ forward to secure upstream DNS (1.1.1.1).
   - Real-time integer statistics counter incremented in native memory and pushed via `EventChannel` to Flutter UI.

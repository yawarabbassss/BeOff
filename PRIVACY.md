# BeOff — Privacy Model & Guarantees

## 🔒 Fundamental Privacy Guarantees

1. **Zero Browsing History Collection**
   - The application does NOT contain a database table for visited URLs, web pages, or timestamps.
   - We do not track, log, aggregate, or transmit which websites you or your family visit.

2. **Zero Image & Media Cloud Uploads**
   - Content Safety analysis is performed 100% locally on your device.
   - Screenshots, camera images, video frames, and web pictures are NEVER transmitted to external cloud servers or AI APIs for classification.
   - Analyzed frames are processed in volatile memory and promptly recycled.

3. **No Surveillance in Child Protection Mode**
   - Child Protection Mode focuses exclusively on blocking harmful explicit material, enforcing strict SafeSearch, and preventing unauthorized settings changes via parent PIN lock.
   - Parents are given peace of mind without transforming BeOff into spyware or surveillance software.

4. **No Mandatory Account**
   - Basic protection and all core features work immediately out of the box in Guest Mode without requiring an email or login.

5. **Local-First Statistics**
   - The Statistics dashboard tracks only aggregated numerical counters (e.g. "342 ads blocked"). These counters are stored locally in on-device SQLite and are never sent to Supabase.
   - Users can wipe all local counters at any time using the "Reset Statistics" action.

---

## 📊 What We Store vs What We Never Store

| Data Type | Stored on Device? | Stored in Supabase? | Shared with Third Parties? |
| :--- | :--- | :--- | :--- |
| **Visited URLs & History** | ❌ **NEVER** | ❌ **NEVER** | ❌ **NEVER** |
| **Search Queries** | ❌ **NEVER** | ❌ **NEVER** | ❌ **NEVER** |
| **User Images / Video Frames** | ❌ **NEVER** | ❌ **NEVER** | ❌ **NEVER** |
| **Aggregated Block Counters** | ✅ Yes (SQLite integers) | ❌ **NEVER** | ❌ **NEVER** |
| **Filter List Preferences** | ✅ Yes (Local SharedPreferences) | Optional (Only if logged in) | ❌ **NEVER** |
| **Custom Allowlist / Blocklist**| ✅ Yes (SQLite) | Optional (Only if logged in) | ❌ **NEVER** |
| **Parental PIN (SHA-256 hash)** | ✅ Yes (Android Keystore) | ❌ **NEVER** | ❌ **NEVER** |

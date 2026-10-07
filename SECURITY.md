# BeOff — Security Model & Guidelines

## 1. Local Network Security

- **Android VPNService Isolation**: BeOff configures Android's `VpnService` strictly to filter DNS traffic on `10.0.0.1:53` and sinkhole dangerous requests to `0.0.0.0`.
- **Self-Exclusion**: The BeOff app package itself is excluded from the VPN loop to prevent circular networking issues.
- **Upstream Encrypted DNS**: When permitted requests are resolved, they are routed to privacy-preserving DNS resolvers (Cloudflare 1.1.1.1, Quad9 9.9.9.9) using secure transports.

---

## 2. Supabase Backend Security

- **Row Level Security (RLS)**: Every single table in the PostgreSQL database has RLS enforced (`profiles`, `devices`, `user_settings`, `filter_preferences`, `subscriptions`, `feedback`, `remote_config`).
- **No Service Role Keys in Client**: The client binary contains ONLY the public `anon` key. Secret keys (`service_role`) are NEVER bundled in Flutter code or committed to git.
- **User Ownership Constraints**: Users can only read and modify their own records (`auth.uid() = user_id`).

---

## 3. Cryptographic Storage & Parent PIN

- Sensitive configuration items (such as the parental PIN) are hashed with unique cryptographic salts using SHA-256 and stored via `FlutterSecureStorage` backed by Android Keystore (`EncryptedSharedPreferences`).
- Plaintext PINs are never stored in memory or written to disk.

---

## 4. Honest Limitation & Threat Policy

- **No False Claims**: BeOff does NOT claim 100% immunity against zero-day phishing or polymorphic malware.
- **Bypass Safeguards**: When a user encounters a flagged malicious site, they must provide explicit confirmation before the bypass is granted for that session.

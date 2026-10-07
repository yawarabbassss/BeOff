# BeOff — Supabase Backend Configuration & Database Setup

## 1. Setting Up Database Tables & Row Level Security

1. Navigate to your Supabase Project Dashboard -> **SQL Editor**.
2. Copy the entire contents of `supabase/schema.sql` into the SQL Editor and click **Run**.
3. This creates:
   - `profiles` (User metadata & parent PIN status)
   - `devices` (Registered device identifiers for sync)
   - `user_settings` (Feature toggle preferences)
   - `filter_preferences` (Custom allowlist & blocklist domains)
   - `subscriptions` (Subscription status and tiers)
   - `feedback` (User bug reports / feedback)
   - `remote_config` (App version & remote filter list manifests)
   - Automatic `on_auth_user_created` PostgreSQL trigger function.
   - Row Level Security (RLS) policies on all tables.

---

## 2. Deploying the Remote Config Edge Function

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```
2. Login and link to your Supabase project:
   ```bash
   supabase login
   supabase link --project-ref your-project-id
   ```
3. Deploy the function:
   ```bash
   supabase functions deploy remote_config
   ```

---

## 3. Strict Privacy Guarantees

- **No Browsing History**: No table for visited URLs, domains, or query history exists.
- **Client Security**: Mobile apps connect strictly via `SUPABASE_ANON_KEY`. The `SUPABASE_SERVICE_ROLE_KEY` must NEVER be placed in client apps.

-- ==============================================================================
-- BeOff — Privacy-First Backend Database Schema (Supabase PostgreSQL + RLS)
-- ==============================================================================
-- STRICT PRIVACY GUARANTEES:
-- 1. NO BROWSING HISTORY TABLE EXISTS.
-- 2. NO VISITED URLS ARE STORED.
-- 3. NO SEARCH QUERIES ARE STORED.
-- 4. NO ANALYZED IMAGES OR VIDEO FRAMES ARE STORED.
-- 5. ALL USER TABLES HAVE ROW LEVEL SECURITY (RLS) ENABLED.
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. PROFILES TABLE (Associated with Supabase Auth users)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    is_child_mode_pin_set BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
    ON public.profiles FOR DELETE
    USING (auth.uid() = id);

-- ------------------------------------------------------------------------------
-- 2. DEVICES TABLE (Multi-device synchronization registration)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id_hash TEXT NOT NULL,
    device_name TEXT NOT NULL,
    platform TEXT NOT NULL,
    app_version TEXT NOT NULL,
    last_sync_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, device_id_hash)
);

ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their registered devices"
    ON public.devices FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can register new device"
    ON public.devices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their devices"
    ON public.devices FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their devices"
    ON public.devices FOR DELETE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 3. USER_SETTINGS TABLE (Device protection configuration sync)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    protection_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    ad_block_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    tracker_block_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    malware_protection_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    annoyance_block_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    clean_search_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    content_safety_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    content_safety_level TEXT DEFAULT 'HIGH' NOT NULL, -- LOW, MEDIUM, HIGH, STRICT_CHILD
    child_mode_enabled BOOLEAN DEFAULT FALSE NOT NULL,
    dns_provider TEXT DEFAULT 'STANDARD_SECURE' NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own settings"
    ON public.user_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own settings"
    ON public.user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings"
    ON public.user_settings FOR UPDATE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 4. FILTER_PREFERENCES TABLE (Custom Allowlist & Blocklist sync)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.filter_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    enabled_filter_lists JSONB DEFAULT '["easylist", "easyprivacy", "beoff_malware", "beoff_annoyances"]'::jsonb NOT NULL,
    allowlist_domains JSONB DEFAULT '[]'::jsonb NOT NULL, -- Array of strings e.g. ["example.com"]
    blocklist_domains JSONB DEFAULT '[]'::jsonb NOT NULL, -- Array of strings e.g. ["custombadsite.com"]
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.filter_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own filter preferences"
    ON public.filter_preferences FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own filter preferences"
    ON public.filter_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own filter preferences"
    ON public.filter_preferences FOR UPDATE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 5. SUBSCRIPTIONS TABLE (Entitlement management abstraction)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tier TEXT DEFAULT 'free' NOT NULL, -- free, pro, family
    status TEXT DEFAULT 'active' NOT NULL, -- active, trialing, past_due, canceled
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id)
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
    ON public.subscriptions FOR SELECT
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 6. FEEDBACK TABLE (User bug reports / feedback with zero tracking)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    feedback_type TEXT NOT NULL, -- bug, feature_request, false_positive, general
    message TEXT NOT NULL,
    app_version TEXT NOT NULL,
    platform TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert feedback
CREATE POLICY "Authenticated users can submit feedback"
    ON public.feedback FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Allow anonymous inserts via Edge Functions or anon role
CREATE POLICY "Anonymous users can submit feedback"
    ON public.feedback FOR INSERT
    WITH CHECK (user_id IS NULL);

-- ------------------------------------------------------------------------------
-- 7. REMOTE_CONFIG TABLE (Global filter manifests & minimum app versions)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.remote_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    min_app_version TEXT NOT NULL DEFAULT '1.0.0',
    latest_app_version TEXT NOT NULL DEFAULT '1.0.0',
    filter_lists_manifest JSONB NOT NULL DEFAULT '{}'::jsonb,
    announcement JSONB,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.remote_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active remote config"
    ON public.remote_config FOR SELECT
    USING (is_active = true);

-- ------------------------------------------------------------------------------
-- AUTOMATIC PROFILE CREATION TRIGGER ON USER SIGNUP
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, created_at, updated_at)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', 'BeOff User'), NOW(), NOW())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.filter_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.subscriptions (user_id, tier, status)
    VALUES (NEW.id, 'free', 'active')
    ON CONFLICT (user_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

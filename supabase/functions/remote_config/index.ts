// Supabase Edge Function: Remote Config & Filter List Manifest
// Serves filter list update metadata and version verification
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? ""
    );

    const { data, error } = await supabaseClient
      .from("remote_config")
      .select("*")
      .eq("is_active", true)
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw error;
    }

    const defaultManifest = {
      min_app_version: "1.0.0",
      latest_app_version: "1.0.0",
      filter_lists_manifest: {
        easylist: {
          id: "easylist",
          name: "EasyList Standard (Ad Blocking)",
          url: "https://easylist.to/easylist/easylist.txt",
          rules_count: 75000,
          version: "2026.10.01",
          license: "GPLv3 / CC BY-SA 3.0"
        },
        easyprivacy: {
          id: "easyprivacy",
          name: "EasyPrivacy (Trackers & Telemetry)",
          url: "https://easylist.to/easylist/easyprivacy.txt",
          rules_count: 38000,
          version: "2026.10.01",
          license: "GPLv3 / CC BY-SA 3.0"
        },
        beoff_malware: {
          id: "beoff_malware",
          name: "BeOff Malware & Phishing Shield",
          url: "https://raw.githubusercontent.com/beoff/security-feed/main/malware.txt",
          rules_count: 15400,
          version: "2026.10.05",
          license: "MIT"
        },
        beoff_annoyances: {
          id: "beoff_annoyances",
          name: "BeOff Annoyances & Cookie Popups",
          url: "https://raw.githubusercontent.com/beoff/security-feed/main/annoyances.txt",
          rules_count: 12100,
          version: "2026.10.05",
          license: "MIT"
        }
      }
    };

    return new Response(JSON.stringify(data ?? defaultManifest), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});

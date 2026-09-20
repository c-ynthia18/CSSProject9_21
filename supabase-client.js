/* global supabase */
(function initialiseSupabase() {
  const config = window.SUPABASE_CONFIG;

  if (!config?.url || !config?.publishableKey) {
    console.warn("Supabase is not configured. Copy supabase-config.example.js to supabase-config.js.");
    return;
  }

  if (!window.supabase) {
    console.error("The Supabase browser client did not load.");
    return;
  }

  window.supabaseClient = window.supabase.createClient(config.url, config.publishableKey);

  // Read-only diagnostic for initial connection verification. It does not alter data.
  window.testSupabaseConnection = async function testSupabaseConnection() {
    const { count, error } = await window.supabaseClient
      .from("goals")
      .select("id", { count: "exact", head: true });

    const detail = error
      ? { connected: false, error: error.message }
      : { connected: true, goalCount: count ?? 0 };

    window.dispatchEvent(new CustomEvent("supabase-connection-test", { detail }));
    return detail;
  };
})();

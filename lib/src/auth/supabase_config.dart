/// Supabase connection settings, injected at build/run time via `--dart-define`
/// so no secrets live in the repository:
///
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
/// ```
///
/// The anon key is a public client key (protected by Row Level Security) — it is
/// safe to ship in the app. Never put the service-role key or a management token
/// here.
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

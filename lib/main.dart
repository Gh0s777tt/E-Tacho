import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'src/app.dart';
import 'src/auth/supabase_auth_service.dart';
import 'src/auth/supabase_config.dart';
import 'src/data/preferences_store.dart';
import 'src/providers.dart';
import 'src/sync/supabase_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  final prefs = await SharedPreferences.getInstance();

  final overrides = <Override>[
    preferencesStoreProvider.overrideWithValue(SharedPreferencesStore(prefs)),
  ];

  // Use real Supabase auth only when configured via --dart-define; otherwise
  // the app falls back to the in-memory stub (preview / tests).
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // The classic anon public key is passed here (safe in a client app).
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
    final client = Supabase.instance.client;
    overrides.add(
      authServiceProvider.overrideWithValue(SupabaseAuthService(client)),
    );
    overrides.add(
      syncServiceProvider.overrideWithValue(SupabaseSyncService(client)),
    );
  }

  runApp(ProviderScope(overrides: overrides, child: const ETachoApp()));
}

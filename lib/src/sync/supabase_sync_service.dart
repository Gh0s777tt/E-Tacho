import 'package:compliance_engine/compliance_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'sync_service.dart';

/// Upserts activity events into the `activity_events` table (scoped to the
/// signed-in user by Row Level Security). Best-effort: failures (e.g. offline)
/// are swallowed since the local store remains authoritative.
class SupabaseSyncService implements SyncService {
  SupabaseSyncService(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<void> push(List<ActivityEvent> events) async {
    final user = _client.auth.currentUser;
    if (user == null || events.isEmpty) return;
    final rows = [
      for (final e in events)
        {
          'id': e.id,
          'user_id': user.id,
          'type': e.type.name,
          'start_time': e.startTime.toUtc().toIso8601String(),
          'source': e.source.name,
        },
    ];
    try {
      await _client.from('activity_events').upsert(rows);
    } catch (_) {
      // Offline / transient error — the local store stays authoritative and the
      // events will be retried on the next change.
    }
  }
}

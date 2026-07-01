import 'package:compliance_engine/compliance_engine.dart';

/// Best-effort cloud backup of activity events. Offline-first: the local Drift
/// store is the source of truth; this pushes events to the server when signed in
/// and Supabase is configured. No-op otherwise.
abstract class SyncService {
  Future<void> push(List<ActivityEvent> events);
}

class NoopSyncService implements SyncService {
  const NoopSyncService();

  @override
  Future<void> push(List<ActivityEvent> events) async {}
}

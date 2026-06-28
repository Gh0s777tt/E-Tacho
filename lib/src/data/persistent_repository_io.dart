import 'package:compliance_engine/compliance_engine.dart';

import 'activity_repository.dart';
import 'app_database.dart';

/// Native platforms: persist with Drift (SQLite).
ActivityRepository createPersistentRepository() =>
    DriftActivityRepository(AppDatabase());

class DriftActivityRepository implements ActivityRepository {
  DriftActivityRepository(this._db);

  final AppDatabase _db;
  int _seq = 0;

  @override
  Stream<List<ActivityEvent>> watch() => _db.watchEvents();

  @override
  Future<void> add(ActivityType type, {DateTime? at}) {
    final when = (at ?? DateTime.now()).toUtc();
    return _db.insertEvent(
      ActivityEvent(
        id: '${when.microsecondsSinceEpoch}-${_seq++}',
        type: type,
        startTime: when,
      ),
    );
  }

  @override
  Future<void> clear() => _db.clearEvents();

  @override
  Future<void> dispose() => _db.close();
}

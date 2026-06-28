import 'dart:io';

import 'package:compliance_engine/compliance_engine.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Persistent activity log. The generated row class is named `ActivityEventRow`
/// to avoid clashing with the engine's [ActivityEvent] model.
@DataClassName('ActivityEventRow')
class ActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ActivityEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  /// Live stream of all events, oldest first, mapped to engine models.
  Stream<List<ActivityEvent>> watchEvents() {
    final query = select(activityEvents)
      ..orderBy([(t) => OrderingTerm.asc(t.startTime)]);
    return query
        .watch()
        .map((rows) => rows.map(_toModel).toList(growable: false));
  }

  Future<void> insertEvent(ActivityEvent event) {
    return into(activityEvents).insertOnConflictUpdate(
      ActivityEventsCompanion.insert(
        id: event.id,
        type: event.type.name,
        startTime: event.startTime,
        source: Value(event.source.name),
      ),
    );
  }

  Future<void> clearEvents() => delete(activityEvents).go();

  static ActivityEvent _toModel(ActivityEventRow row) => ActivityEvent(
        id: row.id,
        type: ActivityType.values.byName(row.type),
        startTime: row.startTime.toUtc(),
        source: ActivitySource.values.byName(row.source),
      );

  static LazyDatabase _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'e_tacho.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

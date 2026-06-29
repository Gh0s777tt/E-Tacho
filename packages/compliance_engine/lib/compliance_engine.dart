/// Pure-Dart compliance engine for driver working-time rules
/// (EU Regulation 561/2006 + Polish Drivers' Working Time Act).
///
/// This library has no Flutter, UI or database dependencies and is fully
/// unit-testable without an emulator.
library;

// Engine entry point + extension point.
export 'src/counters/counter.dart' show Counter, CounterContext, CounterResult;
export 'src/engine/compliance_engine.dart';
// Models.
export 'src/models/activity_event.dart';
export 'src/models/activity_type.dart';
export 'src/models/compliance_state.dart';
export 'src/models/counter_status.dart';
export 'src/models/counter_type.dart';
export 'src/models/duty_mode.dart';
export 'src/models/required_action.dart';
export 'src/models/rules_pack.dart';
export 'src/models/violation.dart';
// Notifications.
export 'src/notifications/notification_planner.dart';
export 'src/notifications/planned_notification.dart';
// Timeline.
export 'src/timeline/activity_interval.dart';
export 'src/timeline/activity_timeline.dart';

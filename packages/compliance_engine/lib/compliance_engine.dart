/// Pure-Dart compliance engine for driver working-time rules
/// (EU Regulation 561/2006 + Polish Drivers' Working Time Act).
///
/// This library has no Flutter, UI or database dependencies and is fully
/// unit-testable without an emulator.
library;

// Models
export 'src/models/activity_event.dart';
export 'src/models/activity_type.dart';
export 'src/models/compliance_state.dart';
export 'src/models/counter_status.dart';
export 'src/models/counter_type.dart';
export 'src/models/required_action.dart';
export 'src/models/rules_pack.dart';
export 'src/models/violation.dart';

// Timeline
export 'src/timeline/activity_interval.dart';
export 'src/timeline/activity_timeline.dart';

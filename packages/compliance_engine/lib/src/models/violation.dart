import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'counter_type.dart';

/// A limit that is currently breached.
///
/// Carries an i18n [messageKey] + [messageArgs], never a pre-formatted string.
@immutable
class Violation extends Equatable {
  const Violation({
    required this.counter,
    required this.messageKey,
    required this.occurredAt,
    this.messageArgs = const {},
  });

  final CounterType counter;
  final String messageKey;

  /// When the limit was crossed (UTC), as best the engine can determine.
  final DateTime occurredAt;

  final Map<String, Object> messageArgs;

  @override
  List<Object?> get props => [counter, messageKey, occurredAt, messageArgs];

  @override
  bool get stringify => true;
}

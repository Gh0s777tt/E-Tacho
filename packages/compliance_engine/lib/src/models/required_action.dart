import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// The kind of obligation a [RequiredAction] represents.
enum RequiredActionType {
  /// A 45-minute break (or the start of a 15+30 split) is required.
  takeBreak,

  /// The second part (30 min) of a split break is required to complete it.
  takeSplitBreakSecondPart,

  /// A daily rest period is required.
  takeDailyRest,

  /// The duty window is closing — work must end and the daily rest must start.
  endDuty,

  /// A break is required after consecutive working time (PL art. 13).
  takeWorkBreak,

  /// After a rest, the driver may resume work (now or at [timeUntil]).
  mayResumeWork,
}

/// A near-future obligation surfaced to the driver, e.g. "45-min break required
/// in 14 min".
///
/// Carries an i18n [messageKey] and [messageArgs] — never a pre-formatted
/// string. Formatting/translation happens in the UI layer.
@immutable
class RequiredAction extends Equatable {
  const RequiredAction({
    required this.type,
    required this.timeUntil,
    required this.messageKey,
    this.messageArgs = const {},
  });

  final RequiredActionType type;

  /// Time until the action becomes due. Negative means it is overdue.
  final Duration timeUntil;

  final String messageKey;
  final Map<String, Object> messageArgs;

  bool get isOverdue => timeUntil.isNegative;

  @override
  List<Object?> get props => [type, timeUntil, messageKey, messageArgs];

  @override
  bool get stringify => true;
}

import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

String stateLabel(AppLocalizations l, ActivityType type) {
  switch (type) {
    case ActivityType.driving:
      return l.stateDriving;
    case ActivityType.otherWork:
      return l.stateOtherWork;
    case ActivityType.availability:
      return l.stateAvailability;
    case ActivityType.rest:
      return l.stateRest;
  }
}

IconData iconFor(ActivityType type) {
  switch (type) {
    case ActivityType.driving:
      return Icons.local_shipping;
    case ActivityType.otherWork:
      return Icons.build;
    case ActivityType.availability:
      return Icons.hourglass_empty;
    case ActivityType.rest:
      return Icons.hotel;
  }
}

String actionLabel(AppLocalizations l, RequiredActionType type) {
  switch (type) {
    case RequiredActionType.takeBreak:
    case RequiredActionType.takeSplitBreakSecondPart:
      return l.actionTakeBreak;
    case RequiredActionType.takeWorkBreak:
      return l.actionTakeWorkBreak;
    case RequiredActionType.takeDailyRest:
      return l.actionTakeDailyRest;
    case RequiredActionType.endDuty:
      return l.actionEndDuty;
    case RequiredActionType.mayResumeWork:
      return l.actionMayResumeWork;
  }
}

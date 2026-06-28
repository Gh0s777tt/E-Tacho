import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../providers.dart';

/// Keeps the home-screen widget in sync with the two key countdowns. Updates
/// only when the displayed values change (minute granularity), so it does not
/// hammer the OS on every clock tick. Renders [child] unchanged.
class HomeWidgetUpdater extends ConsumerStatefulWidget {
  const HomeWidgetUpdater({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetUpdater> createState() => _HomeWidgetUpdaterState();
}

class _HomeWidgetUpdaterState extends ConsumerState<HomeWidgetUpdater> {
  String? _last;

  @override
  Widget build(BuildContext context) {
    ref.listen<ComplianceState>(
      complianceProvider,
      (_, next) => _maybeUpdate(next),
    );
    return widget.child;
  }

  void _maybeUpdate(ComplianceState state) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final breakValue = formatHm(
      state.counter(CounterType.continuousDriving)?.remaining ?? Duration.zero,
    );
    final dutyValue = formatHm(
      state.counter(CounterType.dutyWindow)?.remaining ?? Duration.zero,
    );
    final key = '$breakValue|$dutyValue';
    if (key == _last) return;
    _last = key;
    ref.read(homeWidgetServiceProvider).update(
          breakLabel: l.untilBreak,
          breakValue: breakValue,
          dutyLabel: l.untilDutyEnd,
          dutyValue: dutyValue,
        );
  }
}

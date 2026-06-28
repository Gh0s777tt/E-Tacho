import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(complianceProvider);
    final hasEvents = ref.watch(activityStoreProvider).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CurrentStateBar(state: state),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    Expanded(
                      child: _CountdownCard(
                        label: l.untilBreak,
                        status: state.counter(CounterType.continuousDriving),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CountdownCard(
                        label: l.untilDutyEnd,
                        status: state.counter(CounterType.dutyWindow),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _NextActionBanner(state: state, hasEvents: hasEvents),
              const SizedBox(height: 16),
              _StateButtons(active: state.currentActivity, hasEvents: hasEvents),
              const SizedBox(height: 12),
              Text(
                l.disclaimer,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentStateBar extends StatelessWidget {
  const _CurrentStateBar({required this.state});

  final ComplianceState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = levelColor(state.overall);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_iconFor(state.currentActivity), color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text(
            _stateLabel(l, state.currentActivity),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.label, required this.status});

  final String label;
  final CounterStatus? status;

  @override
  Widget build(BuildContext context) {
    final s = status;
    final color = s == null ? Colors.grey : levelColor(s.level);
    final remaining = s?.remaining ?? Duration.zero;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              formatHm(remaining),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionBanner extends StatelessWidget {
  const _NextActionBanner({required this.state, required this.hasEvents});

  final ComplianceState state;
  final bool hasEvents;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (state.upcomingActions.isEmpty) {
      if (!hasEvents) {
        return Text(
          l.noData,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      }
      return const SizedBox.shrink();
    }
    final action = state.upcomingActions.first;
    final label = _actionLabel(l, action.type);
    final text = action.timeUntil <= Duration.zero
        ? l.actionNow(label)
        : l.actionIn(label, formatHm(action.timeUntil));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StateButtons extends ConsumerWidget {
  const _StateButtons({required this.active, required this.hasEvents});

  final ActivityType active;
  final bool hasEvents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final store = ref.read(activityStoreProvider.notifier);
    final items = <(ActivityType, String, IconData)>[
      (ActivityType.driving, l.btnDrive, Icons.local_shipping),
      (ActivityType.otherWork, l.btnOtherWork, Icons.build),
      (ActivityType.availability, l.btnAvailability, Icons.hourglass_empty),
      (ActivityType.rest, l.btnRest, Icons.hotel),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        for (final (type, label, icon) in items)
          _StateButton(
            label: label,
            icon: icon,
            selected: hasEvents && type == active,
            onTap: () => store.setActivity(type),
          ),
      ],
    );
  }
}

class _StateButton extends StatelessWidget {
  const _StateButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _stateLabel(AppLocalizations l, ActivityType type) {
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

IconData _iconFor(ActivityType type) {
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

String _actionLabel(AppLocalizations l, RequiredActionType type) {
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

import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../providers.dart';
import '../ui_labels.dart';

/// Activity record (ewidencja): the day's intervals, newest first.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final loc = ref.watch(baseLocationProvider);
    final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now().toUtc();
    final events =
        ref.watch(activityEventsProvider).valueOrNull ?? const <ActivityEvent>[];
    final intervals =
        ActivityTimeline.fromEvents(events, now: now).intervals.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: intervals.isEmpty
          ? Center(
              child: Text(
                l.historyEmpty,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              itemCount: intervals.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final iv = intervals[i];
                return ListTile(
                  leading: Icon(iconFor(iv.type)),
                  title: Text(stateLabel(l, iv.type)),
                  subtitle: Text(
                    '${formatClock(iv.start, loc)} – ${formatClock(iv.end, loc)}',
                  ),
                  trailing: Text(
                    formatHm(iv.duration),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

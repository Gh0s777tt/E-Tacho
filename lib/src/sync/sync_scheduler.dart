import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Pushes newly added activity events to the cloud (best-effort). Renders
/// [child] unchanged. No-op unless a real [SyncService] is configured.
class SyncScheduler extends ConsumerStatefulWidget {
  const SyncScheduler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncScheduler> createState() => _SyncSchedulerState();
}

class _SyncSchedulerState extends ConsumerState<SyncScheduler> {
  final Set<String> _pushed = {};

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<ActivityEvent>>>(
      activityEventsProvider,
      (_, next) {
        final events = next.valueOrNull ?? const <ActivityEvent>[];
        final fresh = events.where((e) => !_pushed.contains(e.id)).toList();
        if (fresh.isEmpty) return;
        for (final e in fresh) {
          _pushed.add(e.id);
        }
        ref.read(syncServiceProvider).push(fresh);
      },
    );
    return widget.child;
  }
}

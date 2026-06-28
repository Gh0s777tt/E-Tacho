import 'dart:async';

import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../format.dart';
import '../providers.dart';

/// Listens to [DrivingDetector] and, after a stop, asks the driver to confirm a
/// detected driving period — backfilling a driving event from the detected
/// start. Renders [child] unchanged.
class DrivingDetectionListener extends ConsumerStatefulWidget {
  const DrivingDetectionListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DrivingDetectionListener> createState() =>
      _DrivingDetectionListenerState();
}

class _DrivingDetectionListenerState
    extends ConsumerState<DrivingDetectionListener> {
  StreamSubscription<DateTime>? _subscription;
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription =
          ref.read(drivingDetectorProvider).detections.listen(_onDetected);
    });
  }

  Future<void> _onDetected(DateTime startedAt) async {
    if (!mounted || _prompting) return;
    _prompting = true;
    final l = AppLocalizations.of(context);
    final loc = ref.read(baseLocationProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.detectDrivingTitle),
        content: Text(l.detectDrivingBody(formatClock(startedAt, loc))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.yes),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && mounted) {
      await ref
          .read(activityRepositoryProvider)
          .add(ActivityType.driving, at: startedAt);
    }
    _prompting = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

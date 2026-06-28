import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../providers.dart';

const List<String> _timeZones = [
  'Europe/Warsaw',
  'Europe/Berlin',
  'Europe/Paris',
  'Europe/London',
  'UTC',
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsBuffer),
            subtitle: Text('${settings.bufferMinutes} min'),
          ),
          Slider(
            value: settings.bufferMinutes.toDouble(),
            max: 60,
            divisions: 12,
            label: '${settings.bufferMinutes} min',
            onChanged: (v) => controller.setBufferMinutes(v.round()),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsTimeZone),
            trailing: DropdownButton<String>(
              value: settings.timeZoneId,
              items: [
                for (final zone in _timeZones)
                  DropdownMenuItem(value: zone, child: Text(zone)),
              ],
              onChanged: (v) {
                if (v != null) controller.setTimeZoneId(v);
              },
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsLanguage),
            trailing: DropdownButton<String?>(
              value: settings.localeCode,
              items: [
                DropdownMenuItem(value: null, child: Text(l.languageSystem)),
                const DropdownMenuItem(value: 'pl', child: Text('Polski')),
                const DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: controller.setLocaleCode,
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.download),
            title: Text(l.settingsExport),
            onTap: () => _export(context, ref, l),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: Text(l.settingsReset),
            onTap: () => _reset(context, ref, l),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final events =
        ref.read(activityEventsProvider).valueOrNull ?? const <ActivityEvent>[];
    final loc = ref.read(baseLocationProvider);
    final now = ref.read(nowProvider).valueOrNull ?? DateTime.now().toUtc();
    await Clipboard.setData(ClipboardData(text: _buildCsv(events, now, loc)));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.exportCopied)));
    }
  }

  Future<void> _reset(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetConfirmTitle),
        content: Text(l.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await ref.read(activityRepositoryProvider).clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.resetDone)));
      }
    }
  }

  String _buildCsv(List<ActivityEvent> events, DateTime now, tz.Location loc) {
    final intervals = ActivityTimeline.fromEvents(events, now: now).intervals;
    final buffer = StringBuffer('type,start,end,duration_min\n');
    for (final iv in intervals) {
      final start = tz.TZDateTime.from(iv.start, loc).toIso8601String();
      final end = tz.TZDateTime.from(iv.end, loc).toIso8601String();
      buffer.writeln('${iv.type.name},$start,$end,${iv.duration.inMinutes}');
    }
    return buffer.toString();
  }
}

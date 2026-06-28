import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';

/// Formats a duration as `H:MM` (e.g. `4:05`). Negatives get a leading minus.
String formatHm(Duration d) {
  final negative = d.isNegative;
  final abs = d.abs();
  final h = abs.inHours;
  final m = abs.inMinutes.remainder(60);
  final text = '$h:${m.toString().padLeft(2, '0')}';
  return negative ? '-$text' : text;
}

/// High-contrast accent colour for a compliance level.
Color levelColor(ComplianceLevel level) {
  switch (level) {
    case ComplianceLevel.ok:
      return const Color(0xFF1B5E20); // green 900
    case ComplianceLevel.approaching:
      return const Color(0xFFF9A825); // amber 800
    case ComplianceLevel.critical:
      return const Color(0xFFE65100); // orange 900
    case ComplianceLevel.exceeded:
      return const Color(0xFFB71C1C); // red 900
  }
}

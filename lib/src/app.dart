import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'theme.dart';

class ETachoApp extends StatelessWidget {
  const ETachoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

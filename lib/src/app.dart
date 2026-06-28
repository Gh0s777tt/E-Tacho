import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'detection/driving_detection_listener.dart';
import 'home/home_screen.dart';
import 'notifications/notification_scheduler.dart';
import 'onboarding/onboarding_screen.dart';
import 'providers.dart';
import 'theme.dart';
import 'widget/home_widget_updater.dart';

class ETachoApp extends ConsumerWidget {
  const ETachoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(onboardingAcceptedProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      home: accepted
          ? const NotificationScheduler(
              child: DrivingDetectionListener(
                child: HomeWidgetUpdater(child: HomeScreen()),
              ),
            )
          : const OnboardingScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'auth/auth_screen.dart';
import 'detection/driving_detection_listener.dart';
import 'home/home_screen.dart';
import 'notifications/notification_scheduler.dart';
import 'onboarding/onboarding_screen.dart';
import 'providers.dart';
import 'sync/sync_scheduler.dart';
import 'theme.dart';
import 'widget/home_widget_updater.dart';

class ETachoApp extends ConsumerWidget {
  const ETachoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(onboardingAcceptedProvider);
    final signedIn = ref.watch(authStateProvider).valueOrNull != null;

    final Widget home;
    if (!accepted) {
      home = const OnboardingScreen();
    } else if (!signedIn) {
      home = const AuthScreen();
    } else {
      home = const NotificationScheduler(
        child: DrivingDetectionListener(
          child: HomeWidgetUpdater(
            child: SyncScheduler(child: HomeScreen()),
          ),
        ),
      );
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      home: home,
    );
  }
}

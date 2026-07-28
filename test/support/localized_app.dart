import 'package:flutter/material.dart';
import 'package:cinefile/l10n/app_localizations.dart';

/// A [MaterialApp] wired up the way main.dart wires the real one.
///
/// Widget tests used to build a bare `MaterialApp(home: ...)`. That works right
/// up until the screen under test reads `AppLocalizations.of(context)`, which
/// then throws because no delegate provided it — and the failure surfaces as an
/// unrelated-looking render error deep inside the widget being tested.
///
/// Tests default to the binding's locale (en-US); pass [locale] to pin one, for
/// example to assert a screen renders in Turkish.
class LocalizedTestApp extends StatelessWidget {
  const LocalizedTestApp({
    super.key,
    required this.home,
    this.locale,
    this.navigatorObservers = const [],
  });

  final Widget home;
  final Locale? locale;
  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: navigatorObservers,
      home: home,
    );
  }
}

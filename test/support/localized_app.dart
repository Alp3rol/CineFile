import 'package:flutter/material.dart';
import 'package:cinefile/core/theme/app_theme.dart';
import 'package:cinefile/l10n/app_localizations.dart';

/// A [MaterialApp] wired up the way main.dart wires the real one.
///
/// Widget tests used to build a bare `MaterialApp(home: ...)`. That works right
/// up until the screen under test reads `AppLocalizations.of(context)`, which
/// then throws because no delegate provided it — and the failure surfaces as an
/// unrelated-looking render error deep inside the widget being tested.
///
/// The same argument applies to the theme, which this used to leave unset.
/// Screens that size their own text rendered identically either way, so it
/// went unnoticed — but the moment a screen started reading
/// `textTheme.displayLarge` instead of writing `fontSize: 28`, tests began
/// laying it out at Flutter's default 57px and overflowing. The tests were
/// measuring a theme the app never runs with.
///
/// Tests default to the binding's locale (en-US); pass [locale] to pin one, for
/// example to assert a screen renders in Turkish.
class LocalizedTestApp extends StatelessWidget {
  const LocalizedTestApp({
    super.key,
    required this.home,
    this.locale,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.theme,
  });

  final Widget home;
  final Locale? locale;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;

  /// Defaults to the app's own theme. Overridable so a test that genuinely
  /// wants to isolate a widget from it can, rather than every test silently
  /// getting Flutter's defaults.
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      home: home,
    );
  }
}

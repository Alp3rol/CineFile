import 'dart:ui' show Locale, PlatformDispatcher;

import '../../l10n/app_localizations.dart';

/// Resolves [AppLocalizations] without a [BuildContext].
///
/// Most strings are looked up with `AppLocalizations.of(context)`, but a few
/// live outside the widget tree entirely — [NotificationService] builds
/// notification titles from a background isolate callback, and controllers
/// surface failures before any widget has been built. Those call sites pass
/// the user's chosen locale (from `localeProvider`) and get the same generated
/// class back.
///
/// [locale] of `null` means "follow the system", matching `localeProvider`'s
/// own null-is-system convention.
AppLocalizations lookupL10n(Locale? locale) {
  final resolved = locale ?? _systemLocale();
  return lookupAppLocalizations(resolved);
}

/// The device locale, narrowed to a language the app actually ships. Falls back
/// to Turkish, which is the template language.
Locale _systemLocale() {
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
  for (final locale in PlatformDispatcher.instance.locales) {
    if (supported.contains(locale.languageCode)) return Locale(locale.languageCode);
  }
  return const Locale('tr');
}

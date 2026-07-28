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
AppLocalizations lookupL10n(Locale? locale) => lookupAppLocalizations(resolveAppLocale(locale));

/// Turns `localeProvider`'s nullable value into a concrete language the app
/// ships translations for.
///
/// `null` means "follow the device", so the device's preferred languages are
/// walked in order and the first supported one wins; if none match, Turkish is
/// used because it is the template language. Anything that needs to act on the
/// effective language outside the widget tree — [lookupL10n], the TMDb request
/// language — goes through here so they can never disagree.
Locale resolveAppLocale(Locale? locale) {
  if (locale != null) return locale;

  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
  for (final deviceLocale in PlatformDispatcher.instance.locales) {
    if (supported.contains(deviceLocale.languageCode)) return Locale(deviceLocale.languageCode);
  }
  return const Locale('tr');
}

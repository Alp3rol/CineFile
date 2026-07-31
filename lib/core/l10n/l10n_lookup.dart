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

/// The country the device is configured for, as an uppercase ISO-3166-1 code,
/// or null when it reports none.
///
/// [resolveAppLocale] above deliberately throws the country away — the app
/// ships one translation per *language*, so `en-GB` and `en-US` are the same
/// thing to it. Streaming availability is the opposite: it is entirely a
/// question of country, and Netflix's Turkish catalogue is not its German one.
/// This is the companion accessor for that, kept here because this file is
/// already the single place that reads [PlatformDispatcher].
///
/// Not validated against any list of known countries. TMDb simply has no entry
/// for a region it doesn't cover, which the parser already treats as "nothing
/// to show" — whereas filtering here would silently hand a user in an
/// uncurated country somebody else's catalogue.
String? deviceCountryCode() {
  for (final deviceLocale in PlatformDispatcher.instance.locales) {
    final country = deviceLocale.countryCode;
    if (country != null && country.length == 2) return country.toUpperCase();
  }
  return null;
}

/// Date formatting and casing that follow the user's language.
///
/// Dates used to be built with `DateFormat('d MMMM y', 'tr_TR')` and
/// `DateFormat('dd.MM.yyyy')` — a hardcoded locale and a day-first pattern that
/// is a European convention, not a universal one. Both are wrong the moment
/// the app speaks a second language.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// The BCP-47 tag of the locale currently in scope, for `intl`.
String localeTagOf(BuildContext context) => Localizations.localeOf(context).toLanguageTag();

/// A long date — "12 Mart 2026" / "12 March 2026".
String formatLongDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMMd(localeTagOf(context)).format(date);

/// A numeric date, in whichever order the locale writes them: Turkish gets
/// 12.03.2026, English (US) gets 3/12/2026.
String formatShortDate(BuildContext context, DateTime date) =>
    DateFormat.yMd(localeTagOf(context)).format(date);

/// A month heading — "MART 2026" / "MARCH 2026".
String formatMonthHeading(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context);
  return upperCaseFor(DateFormat.yMMMM(locale.toLanguageTag()).format(date), locale);
}

/// [String.toUpperCase] with the Turkish dotted-i rule applied.
///
/// Dart's casing is locale-invariant, so "Nisan".toUpperCase() gives "NISAN" —
/// but Turkish uppercases a dotted i to a dotted İ, making the correct answer
/// "NİSAN". The month headings in the diary were quietly wrong for April, June
/// and October. Only the two i's differ; everything else follows the default.
String upperCaseFor(String value, Locale locale) {
  if (locale.languageCode != 'tr') return value.toUpperCase();
  return value.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}

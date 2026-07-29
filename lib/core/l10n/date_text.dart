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

/// A short month name for chart and heatmap axes — "Oca" / "Jan".
///
/// [month] is 1-based, matching [DateTime.month]. Comes from intl rather than a
/// hand-written table: three separate hardcoded Turkish month arrays existed
/// before this, and none of them would ever have been translated.
String shortMonthName(BuildContext context, int month) =>
    DateFormat.MMM(localeTagOf(context)).format(DateTime(2000, month));

/// A full weekday name — "Pazartesi" / "Monday". [weekday] is 1-based
/// (Monday = 1), matching [DateTime.weekday].
String weekdayName(BuildContext context, int weekday) =>
    DateFormat.EEEE(localeTagOf(context)).format(_dateForWeekday(weekday));

/// A short weekday name — "Pzt" / "Mon".
String shortWeekdayName(BuildContext context, int weekday) =>
    DateFormat.E(localeTagOf(context)).format(_dateForWeekday(weekday));

/// Any date with the requested weekday. 2024-01-01 was a Monday, so adding
/// `weekday - 1` days lands on the one asked for.
DateTime _dateForWeekday(int weekday) => DateTime(2024, 1, weekday);

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

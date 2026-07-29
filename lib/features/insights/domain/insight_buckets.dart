import '../../../l10n/app_localizations.dart';

/// The four bands the time-of-day breakdown groups watches into.
///
/// These used to be the Turkish strings "Sabah"/"Öğle"/"Akşam"/"Gece", used as
/// both the map key and the label. The widget then looked the counts up by
/// label — so in any other language every lookup missed and the chart read as
/// all-zeroes. Same shape of bug as storing genres by name.
enum TimeOfDayBand {
  morning,
  midday,
  evening,
  night;

  static TimeOfDayBand forHour(int hour) {
    if (hour >= 6 && hour < 12) return TimeOfDayBand.morning;
    if (hour >= 12 && hour < 18) return TimeOfDayBand.midday;
    if (hour >= 18 && hour < 24) return TimeOfDayBand.evening;
    return TimeOfDayBand.night;
  }

  /// The clock range this band covers, for the row subtitle. Not localized:
  /// it is digits and a separator in every language the app ships.
  String get hoursLabel => switch (this) {
        TimeOfDayBand.morning => '06:00 - 12:00',
        TimeOfDayBand.midday => '12:00 - 18:00',
        TimeOfDayBand.evening => '18:00 - 24:00',
        TimeOfDayBand.night => '00:00 - 06:00',
      };

  String label(AppLocalizations l10n) => switch (this) {
        TimeOfDayBand.morning => l10n.insightsTimeMorning,
        TimeOfDayBand.midday => l10n.insightsTimeNoon,
        TimeOfDayBand.evening => l10n.insightsTimeEvening,
        TimeOfDayBand.night => l10n.insightsTimeNight,
      };
}

/// Meteorological seasons, on the northern-hemisphere boundaries the app has
/// always used. Keyed like [TimeOfDayBand] and for the same reason.
enum Season {
  winter,
  spring,
  summer,
  autumn;

  static Season forMonth(int month) {
    if (month == 12 || month == 1 || month == 2) return Season.winter;
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    return Season.autumn;
  }

  String label(AppLocalizations l10n) => switch (this) {
        Season.winter => l10n.insightsSeasonWinter,
        Season.spring => l10n.insightsSeasonSpring,
        Season.summer => l10n.insightsSeasonSummer,
        Season.autumn => l10n.insightsSeasonAutumn,
      };

  /// The longer form used as a bar label, with the months spelled out.
  String longLabel(AppLocalizations l10n) => switch (this) {
        Season.winter => l10n.insightsSeasonWinterLong,
        Season.spring => l10n.insightsSeasonSpringLong,
        Season.summer => l10n.insightsSeasonSummerLong,
        Season.autumn => l10n.insightsSeasonAutumnLong,
      };
}

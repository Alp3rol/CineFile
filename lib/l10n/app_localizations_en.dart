// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CineFile';

  @override
  String get firebaseInitErrorTitle => 'Starting Connection';

  @override
  String get firebaseInitErrorMessage =>
      'Connecting to Firebase services. Please try again.';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageTitle => 'Choose Language';

  @override
  String get commonCancel => 'Cancel';
}

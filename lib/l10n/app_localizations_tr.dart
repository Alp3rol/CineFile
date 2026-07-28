// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CineFile';

  @override
  String get firebaseInitErrorTitle => 'Bağlantı Başlatılıyor';

  @override
  String get firebaseInitErrorMessage =>
      'Firebase servislerine erişim sağlanıyor. Lütfen tekrar deneyin.';

  @override
  String get commonRetry => 'Tekrar Deneyin';

  @override
  String get settingsLanguageLabel => 'Dil';

  @override
  String get settingsLanguageSystem => 'Sistem';

  @override
  String get settingsLanguageTitle => 'Dil Seçin';

  @override
  String get commonCancel => 'İptal';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The application name, shown in the OS task switcher.
  ///
  /// In tr, this message translates to:
  /// **'CineFile'**
  String get appTitle;

  /// Title of the screen shown when Firebase fails to initialize at startup.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Başlatılıyor'**
  String get firebaseInitErrorTitle;

  /// Body text of the Firebase initialization failure screen.
  ///
  /// In tr, this message translates to:
  /// **'Firebase servislerine erişim sağlanıyor. Lütfen tekrar deneyin.'**
  String get firebaseInitErrorMessage;

  /// Generic retry button label.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Deneyin'**
  String get commonRetry;

  /// Label of the language row in Settings > Preferences.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguageLabel;

  /// Language option that follows the device's own language setting.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get settingsLanguageSystem;

  /// Title of the language picker dialog.
  ///
  /// In tr, this message translates to:
  /// **'Dil Seçin'**
  String get settingsLanguageTitle;

  /// Generic cancel button label.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get commonCancel;

  /// No description provided for @genreAction.
  ///
  /// In tr, this message translates to:
  /// **'Aksiyon'**
  String get genreAction;

  /// No description provided for @genreAdventure.
  ///
  /// In tr, this message translates to:
  /// **'Macera'**
  String get genreAdventure;

  /// No description provided for @genreAnimation.
  ///
  /// In tr, this message translates to:
  /// **'Animasyon'**
  String get genreAnimation;

  /// No description provided for @genreComedy.
  ///
  /// In tr, this message translates to:
  /// **'Komedi'**
  String get genreComedy;

  /// No description provided for @genreCrime.
  ///
  /// In tr, this message translates to:
  /// **'Suç'**
  String get genreCrime;

  /// No description provided for @genreDocumentary.
  ///
  /// In tr, this message translates to:
  /// **'Belgesel'**
  String get genreDocumentary;

  /// No description provided for @genreDrama.
  ///
  /// In tr, this message translates to:
  /// **'Dram'**
  String get genreDrama;

  /// No description provided for @genreFamily.
  ///
  /// In tr, this message translates to:
  /// **'Aile'**
  String get genreFamily;

  /// No description provided for @genreFantasy.
  ///
  /// In tr, this message translates to:
  /// **'Fantastik'**
  String get genreFantasy;

  /// No description provided for @genreHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get genreHistory;

  /// No description provided for @genreHorror.
  ///
  /// In tr, this message translates to:
  /// **'Korku'**
  String get genreHorror;

  /// No description provided for @genreMusic.
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get genreMusic;

  /// No description provided for @genreMystery.
  ///
  /// In tr, this message translates to:
  /// **'Gizem'**
  String get genreMystery;

  /// No description provided for @genreRomance.
  ///
  /// In tr, this message translates to:
  /// **'Romantik'**
  String get genreRomance;

  /// No description provided for @genreScienceFiction.
  ///
  /// In tr, this message translates to:
  /// **'Bilim Kurgu'**
  String get genreScienceFiction;

  /// No description provided for @genreThriller.
  ///
  /// In tr, this message translates to:
  /// **'Gerilim'**
  String get genreThriller;

  /// No description provided for @genreWar.
  ///
  /// In tr, this message translates to:
  /// **'Savaş'**
  String get genreWar;

  /// No description provided for @genreWestern.
  ///
  /// In tr, this message translates to:
  /// **'Vahşi Batı'**
  String get genreWestern;

  /// No description provided for @genreActionAdventure.
  ///
  /// In tr, this message translates to:
  /// **'Aksiyon & Macera'**
  String get genreActionAdventure;

  /// No description provided for @genreKids.
  ///
  /// In tr, this message translates to:
  /// **'Çocuk'**
  String get genreKids;

  /// No description provided for @genreNews.
  ///
  /// In tr, this message translates to:
  /// **'Haberler'**
  String get genreNews;

  /// No description provided for @genreReality.
  ///
  /// In tr, this message translates to:
  /// **'Realite'**
  String get genreReality;

  /// No description provided for @genreSciFiFantasy.
  ///
  /// In tr, this message translates to:
  /// **'Bilim Kurgu & Fantazi'**
  String get genreSciFiFantasy;

  /// No description provided for @genreSoap.
  ///
  /// In tr, this message translates to:
  /// **'Pembe Dizi'**
  String get genreSoap;

  /// No description provided for @genreTalk.
  ///
  /// In tr, this message translates to:
  /// **'Talk Show'**
  String get genreTalk;

  /// No description provided for @genreWarPolitics.
  ///
  /// In tr, this message translates to:
  /// **'Savaş & Politika'**
  String get genreWarPolitics;

  /// Shown for a stored genre id TMDb has since retired or that this app does not know.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get genreUnknown;

  /// No description provided for @authErrorUsernameEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı boş olamaz.'**
  String get authErrorUsernameEmpty;

  /// No description provided for @authErrorAccountCreationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturulamadı, lütfen tekrar deneyin.'**
  String get authErrorAccountCreationFailed;

  /// No description provided for @authErrorUsernameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı zaten alınmış.'**
  String get authErrorUsernameTaken;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi zaten kullanılıyor.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz bir e-posta adresi girdiniz.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorNotSignedIn.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı oturumu bulunamadı.'**
  String get authErrorNotSignedIn;

  /// No description provided for @authErrorUserDataMissing.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı verisi bulunamadı.'**
  String get authErrorUserDataMissing;

  /// No description provided for @authErrorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu.'**
  String get authErrorUnknown;

  /// No description provided for @authGateErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik Doğrulama Hatası'**
  String get authGateErrorTitle;

  /// No description provided for @authGateErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bilgisi alınamadı. Lütfen tekrar deneyin.'**
  String get authGateErrorMessage;

  /// No description provided for @authTagline.
  ///
  /// In tr, this message translates to:
  /// **'Topluluğa katılın, günlüklerinizi paylaşın.'**
  String get authTagline;

  /// No description provided for @authSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get authSignUp;

  /// No description provided for @authEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get authEmailHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta adresinizi girin.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır.'**
  String get authPasswordTooShort;

  /// No description provided for @authUsernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get authUsernameLabel;

  /// No description provided for @authUsernameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen kullanıcı adı girin.'**
  String get authUsernameRequired;

  /// No description provided for @authUsernameTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı en az 3 karakter olmalıdır.'**
  String get authUsernameTooShort;

  /// No description provided for @authUsernameNoSpaces.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı boşluk içeremez.'**
  String get authUsernameNoSpaces;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu? '**
  String get authNoAccountPrompt;

  /// No description provided for @authSignUpLink.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Olun'**
  String get authSignUpLink;

  /// No description provided for @authHasAccountPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabınız var mı? '**
  String get authHasAccountPrompt;

  /// No description provided for @authSignInLink.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapın'**
  String get authSignInLink;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Giriş yapabilirsiniz.'**
  String get authRegisterSuccess;

  /// No description provided for @authSignInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen giriş yapın.'**
  String get authSignInRequired;

  /// No description provided for @authUserNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı.'**
  String get authUserNotFound;

  /// No description provided for @profileEdit.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get profileEdit;

  /// No description provided for @profilePresetAvatars.
  ///
  /// In tr, this message translates to:
  /// **'Hazır Avatarlar'**
  String get profilePresetAvatars;

  /// No description provided for @profileUsernameHint.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı girin'**
  String get profileUsernameHint;

  /// No description provided for @profileShowcaseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil Vitrini (En Fazla 5 Öne Çıkan Film)'**
  String get profileShowcaseTitle;

  /// No description provided for @profileShowcaseEdit.
  ///
  /// In tr, this message translates to:
  /// **'Vitrini Düzenle'**
  String get profileShowcaseEdit;

  /// No description provided for @profileShowcasePickTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkarılacak Filmleri Seç'**
  String get profileShowcasePickTitle;

  /// No description provided for @profileShowcaseNone.
  ///
  /// In tr, this message translates to:
  /// **'Henüz öne çıkarılan film seçilmedi.'**
  String get profileShowcaseNone;

  /// No description provided for @profileShowcaseLimit.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 5 film seçebilirsiniz.'**
  String get profileShowcaseLimit;

  /// No description provided for @profileShowcaseSelected.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkarılan Filmleri Seç ({count}/5)'**
  String profileShowcaseSelected(int count);

  /// No description provided for @profileShowcasePickCount.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 5 favori seçin ({count}/5)'**
  String profileShowcasePickCount(int count);

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla güncellendi.'**
  String get profileUpdated;

  /// No description provided for @profileNoWatchRecords.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç izleme kaydınız yok.'**
  String get profileNoWatchRecords;

  /// No description provided for @profileRecentWatches.
  ///
  /// In tr, this message translates to:
  /// **'Son İzlediklerim'**
  String get profileRecentWatches;

  /// No description provided for @profileNoRecentWatches.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç izleme kaydı eklenmemiş.'**
  String get profileNoRecentWatches;

  /// No description provided for @profileBadgesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan Rozetler'**
  String get profileBadgesTitle;

  /// No description provided for @profileBadgesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kazanılmış bir rozet yok. Film izledikçe kilitler açılacaktır! Tümünü incelemek için tıklayın.'**
  String get profileBadgesEmpty;

  /// No description provided for @profileBadgesSeeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör ({unlocked}/{total})'**
  String profileBadgesSeeAll(int unlocked, int total);

  /// No description provided for @profileSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileFollowers.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In tr, this message translates to:
  /// **'Takip'**
  String get profileFollowing;

  /// No description provided for @profileRankNovice.
  ///
  /// In tr, this message translates to:
  /// **'Çaylak Sinefil 🍿'**
  String get profileRankNovice;

  /// No description provided for @profileRankTicketBuddy.
  ///
  /// In tr, this message translates to:
  /// **'Bilet Ortağı 🎬'**
  String get profileRankTicketBuddy;

  /// No description provided for @profileRankConnoisseur.
  ///
  /// In tr, this message translates to:
  /// **'Kültür Üstadı 🏛️'**
  String get profileRankConnoisseur;

  /// No description provided for @profileRankGuru.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Gurusu 👑'**
  String get profileRankGuru;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

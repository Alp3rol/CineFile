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

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler'**
  String get settingsPreferences;

  /// No description provided for @settingsReleaseReminders.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Hatırlatıcıları'**
  String get settingsReleaseReminders;

  /// No description provided for @settingsDynamicBackground.
  ///
  /// In tr, this message translates to:
  /// **'Dinamik Arka Plan'**
  String get settingsDynamicBackground;

  /// No description provided for @settingsNotificationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim izni reddedildi. Sistem ayarlarından açabilirsiniz.'**
  String get settingsNotificationPermissionDenied;

  /// No description provided for @settingsDataSection.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yönetimi & Yedekleme'**
  String get settingsDataSection;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Yedekleme'**
  String get settingsBackupTitle;

  /// No description provided for @settingsBackupDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm izleme geçmişinizi, koleksiyonlarınızı, favorilerinizi ve notlarınızı JSON formatında yedekleyebilir ve istediğiniz cihazda geri yükleyebilirsiniz. Geri yükleme mevcut verilerin üzerine yazar.'**
  String get settingsBackupDescription;

  /// No description provided for @letterboxdImportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Letterboxd CSV Önizleme'**
  String get letterboxdImportTitle;

  /// No description provided for @letterboxdImportDescription.
  ///
  /// In tr, this message translates to:
  /// **'Letterboxd diary.csv dosyanı güvenle kontrol et. Bu aşama hiçbir kaydı CineFile\'a yazmaz.'**
  String get letterboxdImportDescription;

  /// No description provided for @letterboxdChooseCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV Dosyası Seç'**
  String get letterboxdChooseCsv;

  /// No description provided for @letterboxdInvalidCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV doğrulanamadı'**
  String get letterboxdInvalidCsv;

  /// No description provided for @letterboxdPreviewOnly.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca önizleme: Henüz hiçbir kayıt eklenmedi.'**
  String get letterboxdPreviewOnly;

  /// No description provided for @letterboxdTotalRows.
  ///
  /// In tr, this message translates to:
  /// **'Toplam: {count}'**
  String letterboxdTotalRows(int count);

  /// No description provided for @letterboxdValidRows.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli: {count}'**
  String letterboxdValidRows(int count);

  /// No description provided for @letterboxdInvalidRows.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı: {count}'**
  String letterboxdInvalidRows(int count);

  /// No description provided for @settingsExport.
  ///
  /// In tr, this message translates to:
  /// **'Dışa Aktar'**
  String get settingsExport;

  /// No description provided for @settingsRestore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get settingsRestore;

  /// No description provided for @settingsCleanDuplicates.
  ///
  /// In tr, this message translates to:
  /// **'Mükerrer Kayıtları Temizle'**
  String get settingsCleanDuplicates;

  /// No description provided for @settingsDataProvider.
  ///
  /// In tr, this message translates to:
  /// **'Veri Sağlayıcı'**
  String get settingsDataProvider;

  /// No description provided for @settingsTmdbAttribution.
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulama TMDB API\'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.'**
  String get settingsTmdbAttribution;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String settingsVersion(String version);

  /// No description provided for @backupCopiedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedek Panoya Kopyalandı!'**
  String get backupCopiedTitle;

  /// No description provided for @backupCopiedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme verileriniz kopyalandı. Bu veriyi bir dosyaya kaydederek veya başka bir cihaza göndererek saklayabilirsiniz.'**
  String get backupCopiedMessage;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedekten Geri Yükle'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreWarning.
  ///
  /// In tr, this message translates to:
  /// **'Daha önce kopyaladığınız JSON yedek kodunu aşağıdaki alana yapıştırın. Bu işlem koleksiyonlarınızın VE hesabınızdaki tüm izleme geçmişinizin üzerine yazacaktır!'**
  String get backupRestoreWarning;

  /// No description provided for @backupRestoreHint.
  ///
  /// In tr, this message translates to:
  /// **'JSON kodunu buraya yapıştırın...'**
  String get backupRestoreHint;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Yükle'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz yedekten başarıyla yüklendi!'**
  String get backupRestoreSuccess;

  /// No description provided for @backupExportError.
  ///
  /// In tr, this message translates to:
  /// **'Yedekleme dosyası oluşturulurken hata: {error}'**
  String backupExportError(String error);

  /// No description provided for @backupRestoreInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Hata: Geçersiz yedek kodu formatı! ({error})'**
  String backupRestoreInvalid(String error);

  /// No description provided for @duplicateCleanupTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mükerrer Kayıtları Temizle'**
  String get duplicateCleanupTitle;

  /// No description provided for @duplicateCleanupConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mükerrer Kayıtları Sil'**
  String get duplicateCleanupConfirmTitle;

  /// No description provided for @duplicateCleanupNone.
  ///
  /// In tr, this message translates to:
  /// **'Mükerrer kayıt bulunamadı. Günlüğün temiz görünüyor.'**
  String get duplicateCleanupNone;

  /// No description provided for @duplicateCleanupConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} dizi/film için fazladan günlük kayıtları silinecek, sadece en son ilerlemeyi yansıtan kayıt tutulacak. Bu işlem geri alınamaz.}}'**
  String duplicateCleanupConfirmBody(int count);

  /// No description provided for @duplicateCleanupIntro.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} dizi/film için aynı gün birden fazla kayıt bulundu. Her grupta en son ilerlemeyi yansıtan kayıt tutulacak, geri kalanı silinecek.}}'**
  String duplicateCleanupIntro(int count);

  /// No description provided for @duplicateCleanupGroupSummary.
  ///
  /// In tr, this message translates to:
  /// **'{day} • {total} kayıt, {toDelete} silinecek'**
  String duplicateCleanupGroupSummary(String day, int total, int toDelete);

  /// No description provided for @duplicateCleanupCleaned.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} dizi/film için mükerrer kayıtlar temizlendi.}}'**
  String duplicateCleanupCleaned(int count);

  /// No description provided for @duplicateCleanupPartial.
  ///
  /// In tr, this message translates to:
  /// **'{cleaned} temizlendi, {failed} tanesi başarısız oldu.'**
  String duplicateCleanupPartial(int cleaned, int failed);

  /// No description provided for @duplicateCleanupAction.
  ///
  /// In tr, this message translates to:
  /// **'Seçilenleri Temizle ({count})'**
  String duplicateCleanupAction(int count);

  /// No description provided for @duplicateCleanupLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlar yüklenemedi: {error}'**
  String duplicateCleanupLoadError(String error);

  /// No description provided for @notificationChannelName.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Hatırlatıcıları'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listendeki film ve dizilerin çıkış günü hatırlatıcıları.'**
  String get notificationChannelDescription;

  /// No description provided for @notificationReleaseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün Çıkıyor! 🎬'**
  String get notificationReleaseTitle;

  /// No description provided for @notificationEpisodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Bölüm! 🎬'**
  String get notificationEpisodeTitle;

  /// No description provided for @notificationWatchlistFallbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Listendeki Yapım'**
  String get notificationWatchlistFallbackTitle;

  /// No description provided for @notificationShowFallbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip Ettiğin Dizi'**
  String get notificationShowFallbackTitle;

  /// No description provided for @notificationReleaseBodyMovie.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listendeki \"{title}\" filmi bugün yayınlanıyor.'**
  String notificationReleaseBodyMovie(String title);

  /// Deliberately a separate message from the movie one rather than a swapped-in noun: the two sentences do not share a grammatical shape across languages.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listendeki \"{title}\" yeni bölümü bugün yayınlanıyor.'**
  String notificationReleaseBodyShow(String title);

  /// No description provided for @searchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Film veya dizi ara...'**
  String get searchHint;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç Bulunamadı'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir kelime aramayı deneyin.'**
  String get searchNoResultsHint;

  /// No description provided for @searchStartTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfetmeye Başlayın'**
  String get searchStartTitle;

  /// No description provided for @searchStartHint.
  ///
  /// In tr, this message translates to:
  /// **'Milyonlarca film arasından arama yapın.'**
  String get searchStartHint;

  /// No description provided for @searchErrorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'TMDb\'ye ulaşılamadı. Bağlantını kontrol edip tekrar dene.'**
  String get searchErrorNetwork;

  /// No description provided for @searchErrorInvalidApiKey.
  ///
  /// In tr, this message translates to:
  /// **'TMDb API anahtarı geçersiz. Ayarlar\'dan kontrol edebilirsin.'**
  String get searchErrorInvalidApiKey;

  /// No description provided for @searchErrorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Arama tamamlanamadı. Lütfen tekrar dene.'**
  String get searchErrorUnknown;

  /// No description provided for @discoverFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get discoverFilterAll;

  /// No description provided for @discoverFilterMovies.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get discoverFilterMovies;

  /// No description provided for @discoverFilterShows.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get discoverFilterShows;

  /// No description provided for @discoverCategoryTrend.
  ///
  /// In tr, this message translates to:
  /// **'Trend'**
  String get discoverCategoryTrend;

  /// No description provided for @discoverCategoryPopular.
  ///
  /// In tr, this message translates to:
  /// **'Popüler'**
  String get discoverCategoryPopular;

  /// No description provided for @discoverCategoryTopRated.
  ///
  /// In tr, this message translates to:
  /// **'En Çok Oy Alan'**
  String get discoverCategoryTopRated;

  /// No description provided for @discoverWindowThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get discoverWindowThisWeek;

  /// No description provided for @discoverWindowToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get discoverWindowToday;

  /// No description provided for @discoverGenreAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get discoverGenreAll;

  /// No description provided for @discoverHeadingTrendToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün Trend Film/Dizileri'**
  String get discoverHeadingTrendToday;

  /// No description provided for @discoverHeadingTrendThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta Trend Film/Dizileri'**
  String get discoverHeadingTrendThisWeek;

  /// No description provided for @discoverHeadingPopular.
  ///
  /// In tr, this message translates to:
  /// **'Popüler Film/Dizileri'**
  String get discoverHeadingPopular;

  /// No description provided for @discoverHeadingTopRated.
  ///
  /// In tr, this message translates to:
  /// **'En Çok Oy Alan Film/Dizileri'**
  String get discoverHeadingTopRated;

  /// Shown when a media-type filter matches nothing. Deliberately does not name the filter: the old wording spliced 'Film'/'Dizi'/'Hepsi' into the sentence, which does not survive translation.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride sonuç bulunamadı'**
  String get discoverFilterEmpty;

  /// No description provided for @swipeDiscoverTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydır & Keşfet'**
  String get swipeDiscoverTitle;

  /// No description provided for @swipeDiscoverEntryHint.
  ///
  /// In tr, this message translates to:
  /// **'İlgini çekenleri İzleme Listesi\'ne ekle'**
  String get swipeDiscoverEntryHint;

  /// No description provided for @swipeDiscoverHint.
  ///
  /// In tr, this message translates to:
  /// **'Sağa kaydır: İzleme Listesi\'ne ekle • Sola kaydır: geç'**
  String get swipeDiscoverHint;

  /// No description provided for @swipeInterested.
  ///
  /// In tr, this message translates to:
  /// **'Listeme Ekle'**
  String get swipeInterested;

  /// No description provided for @swipeNotInterested.
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get swipeNotInterested;

  /// No description provided for @swipeWatched.
  ///
  /// In tr, this message translates to:
  /// **'İzledim'**
  String get swipeWatched;

  /// No description provided for @swipeAddedToWatchlist.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Listesi\'ne eklendi'**
  String get swipeAddedToWatchlist;

  /// No description provided for @swipePassed.
  ///
  /// In tr, this message translates to:
  /// **'Bu yapımı geçtin'**
  String get swipePassed;

  /// No description provided for @swipeWhy.
  ///
  /// In tr, this message translates to:
  /// **'Neden?'**
  String get swipeWhy;

  /// No description provided for @swipeSkipReasonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neden geçtin?'**
  String get swipeSkipReasonTitle;

  /// No description provided for @swipeSkipReasonHint.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlıdır ve önerilerini iyileştirir.'**
  String get swipeSkipReasonHint;

  /// No description provided for @swipeSkipReasonGenre.
  ///
  /// In tr, this message translates to:
  /// **'Bu tür bana göre değil'**
  String get swipeSkipReasonGenre;

  /// No description provided for @swipeSkipReasonTitleSpecific.
  ///
  /// In tr, this message translates to:
  /// **'Bu yapım ilgimi çekmedi'**
  String get swipeSkipReasonTitleSpecific;

  /// No description provided for @swipeSkipReasonNotNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik istemiyorum'**
  String get swipeSkipReasonNotNow;

  /// No description provided for @swipeSkipReasonSaved.
  ///
  /// In tr, this message translates to:
  /// **'Tercihin önerilerine yansıtılacak'**
  String get swipeSkipReasonSaved;

  /// No description provided for @swipeTasteProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydırmalardan Öğrenilen Zevkin'**
  String get swipeTasteProfileTitle;

  /// No description provided for @swipeTasteProfileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu sinyaller kişisel önerilerini şekillendiriyor'**
  String get swipeTasteProfileSubtitle;

  /// No description provided for @swipeTasteProfileCounts.
  ///
  /// In tr, this message translates to:
  /// **'{liked} beğeni • {passed} geçiş'**
  String swipeTasteProfileCounts(int liked, int passed);

  /// No description provided for @swipeTasteProfileGenreFeedback.
  ///
  /// In tr, this message translates to:
  /// **'{count} tür geri bildirimi önerilerini hassaslaştırdı'**
  String swipeTasteProfileGenreFeedback(int count);

  /// No description provided for @swipeUndo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get swipeUndo;

  /// No description provided for @swipeViewDetails.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Detayları Gör'**
  String get swipeViewDetails;

  /// No description provided for @swipeSeasonCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Sezon'**
  String swipeSeasonCount(int count);

  /// No description provided for @swipeSessionSummary.
  ///
  /// In tr, this message translates to:
  /// **'Bu Oturumda'**
  String get swipeSessionSummary;

  /// No description provided for @swipeSessionAdded.
  ///
  /// In tr, this message translates to:
  /// **'Listeye'**
  String get swipeSessionAdded;

  /// No description provided for @swipeSessionPassed.
  ///
  /// In tr, this message translates to:
  /// **'Geçildi'**
  String get swipeSessionPassed;

  /// No description provided for @swipeSessionWatched.
  ///
  /// In tr, this message translates to:
  /// **'İzlendi'**
  String get swipeSessionWatched;

  /// No description provided for @swipeSessionTasteHint.
  ///
  /// In tr, this message translates to:
  /// **'{genres} seçimlerin sonraki önerilerini güçlendirecek'**
  String swipeSessionTasteHint(String genres);

  /// No description provided for @swipeSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Tercihin kaydedilemedi. Lütfen tekrar dene.'**
  String get swipeSaveFailed;

  /// No description provided for @swipeDeckFinished.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik hepsi bu!'**
  String get swipeDeckFinished;

  /// No description provided for @swipeDeckFinishedHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni öneriler geldiğinde burada seni bekliyor olacak.'**
  String get swipeDeckFinishedHint;

  /// No description provided for @swipeMoreOptions.
  ///
  /// In tr, this message translates to:
  /// **'Diğer seçenekler'**
  String get swipeMoreOptions;

  /// No description provided for @swipeResetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydırma tercihleri sıfırlansın mı?'**
  String get swipeResetTitle;

  /// No description provided for @swipeResetMessage.
  ///
  /// In tr, this message translates to:
  /// **'İlgilenmediğin içerikler yeniden önerilebilir. İzleme Listen ve izleme geçmişin değişmez.'**
  String get swipeResetMessage;

  /// No description provided for @swipeResetAction.
  ///
  /// In tr, this message translates to:
  /// **'Tercihleri sıfırla'**
  String get swipeResetAction;

  /// No description provided for @swipeResetDone.
  ///
  /// In tr, this message translates to:
  /// **'Kaydırma tercihlerin sıfırlandı'**
  String get swipeResetDone;

  /// No description provided for @swipeRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count} öneri kaldı'**
  String swipeRemaining(int count);

  /// No description provided for @swipeLoadMore.
  ///
  /// In tr, this message translates to:
  /// **'Yeni öneriler getir'**
  String get swipeLoadMore;

  /// No description provided for @swipeRefreshFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yeni öneriler yüklenemedi. Lütfen tekrar dene.'**
  String get swipeRefreshFailed;

  /// Replaces a sentence that was split around an inline TMDB logo image — the two halves could not be reordered for another language.
  ///
  /// In tr, this message translates to:
  /// **'Veriler TMDB tarafından sağlanmaktadır.'**
  String get searchTmdbAttribution;

  /// No description provided for @recommendationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sana Özel Öneriler'**
  String get recommendationsTitle;

  /// No description provided for @recommendationReasonPopular.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukta Popüler'**
  String get recommendationReasonPopular;

  /// No description provided for @recommendationReasonGenre.
  ///
  /// In tr, this message translates to:
  /// **'{genre} Sevenlere'**
  String recommendationReasonGenre(String genre);

  /// No description provided for @recommendationReasonDirector.
  ///
  /// In tr, this message translates to:
  /// **'{director} Yönettiği İçin'**
  String recommendationReasonDirector(String director);

  /// No description provided for @recommendationReasonActor.
  ///
  /// In tr, this message translates to:
  /// **'{actor} Rol Alıyor'**
  String recommendationReasonActor(String actor);

  /// No description provided for @titleUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Yapım'**
  String get titleUnknown;

  /// No description provided for @searchDemoModeBanner.
  ///
  /// In tr, this message translates to:
  /// **'TMDb API anahtarı girilmedi. Şu an deneme modundasınız (\"dune\", \"interstellar\", \"inception\" veya \"dark\" aramalarını test edebilirsiniz).'**
  String get searchDemoModeBanner;

  /// No description provided for @detailNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Film detayları bulunamadı.'**
  String get detailNotFound;

  /// No description provided for @detailNoOverview.
  ///
  /// In tr, this message translates to:
  /// **'Özet bulunmuyor.'**
  String get detailNoOverview;

  /// No description provided for @detailOverview.
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get detailOverview;

  /// No description provided for @detailCast.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncular'**
  String get detailCast;

  /// No description provided for @detailDirector.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen'**
  String get detailDirector;

  /// No description provided for @detailMyRating.
  ///
  /// In tr, this message translates to:
  /// **'Puanım'**
  String get detailMyRating;

  /// No description provided for @detailPlace.
  ///
  /// In tr, this message translates to:
  /// **'Ortam'**
  String get detailPlace;

  /// No description provided for @detailAddToDiary.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğe Ekle'**
  String get detailAddToDiary;

  /// No description provided for @detailAddToList.
  ///
  /// In tr, this message translates to:
  /// **'Listeye Ekle'**
  String get detailAddToList;

  /// No description provided for @detailShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get detailShare;

  /// No description provided for @detailAddToMyDiary.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğüme Ekle'**
  String get detailAddToMyDiary;

  /// No description provided for @detailSetRank.
  ///
  /// In tr, this message translates to:
  /// **'Sıra Belirle'**
  String get detailSetRank;

  /// No description provided for @detailTmdbAttribution.
  ///
  /// In tr, this message translates to:
  /// **'Veriler TMDB tarafından sağlanmaktadır.'**
  String get detailTmdbAttribution;

  /// No description provided for @directorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get directorUnknown;

  /// No description provided for @detailFavoriteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Favori durumu güncellenemedi. Lütfen tekrar deneyin.'**
  String get detailFavoriteFailed;

  /// No description provided for @detailWatchlistFailed.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listesi güncellenemedi. Lütfen tekrar deneyin.'**
  String get detailWatchlistFailed;

  /// No description provided for @detailRecordDeleted.
  ///
  /// In tr, this message translates to:
  /// **'İzleme kaydı silindi.'**
  String get detailRecordDeleted;

  /// No description provided for @detailRecordDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'İzleme kaydı silinemedi. Lütfen tekrar deneyin.'**
  String get detailRecordDeleteFailed;

  /// No description provided for @detailLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar yüklenemedi. Lütfen tekrar deneyin.'**
  String get detailLoadFailed;

  /// No description provided for @timelineTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Geçmişim'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu filmi henüz izlemediniz.'**
  String get timelineEmpty;

  /// No description provided for @timelineLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'İzleme geçmişi yüklenemedi.'**
  String get timelineLoadFailed;

  /// No description provided for @timelineMood.
  ///
  /// In tr, this message translates to:
  /// **'Mod: {mood}'**
  String timelineMood(String mood);

  /// No description provided for @timelineDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı Sil?'**
  String get timelineDeleteTitle;

  /// No description provided for @timelineDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu izleme kaydını günlüğünüzden kalıcı olarak silmek istediğinize emin misiniz?'**
  String get timelineDeleteConfirm;

  /// No description provided for @commonDiscard.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonDiscard;

  /// No description provided for @watchStatusCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get watchStatusCompleted;

  /// No description provided for @watchStatusWatchingOf.
  ///
  /// In tr, this message translates to:
  /// **'İzleniyor ({watched}/{total})'**
  String watchStatusWatchingOf(int watched, int total);

  /// No description provided for @watchStatusWatchingEpisode.
  ///
  /// In tr, this message translates to:
  /// **'İzleniyor (Bölüm {episode})'**
  String watchStatusWatchingEpisode(int episode);

  /// No description provided for @rankDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Favori Sırası Belirle'**
  String get rankDialogTitle;

  /// No description provided for @rankDialogField.
  ///
  /// In tr, this message translates to:
  /// **'Sıra Numarası'**
  String get rankDialogField;

  /// No description provided for @rankSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sıra kaydedilemedi.'**
  String get rankSaveFailed;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @addRecordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğe İzleme Kaydı Ekle'**
  String get addRecordTitle;

  /// No description provided for @addRecordSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı Günlüğe Ekle'**
  String get addRecordSubmit;

  /// No description provided for @addRecordSignInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen önce giriş yapın.'**
  String get addRecordSignInRequired;

  /// No description provided for @addRecordSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt kaydedilirken hata oluştu.'**
  String get addRecordSaveFailed;

  /// No description provided for @addRecordMoodLabel.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Modu / Ruh Hali:'**
  String get addRecordMoodLabel;

  /// No description provided for @addRecordRatingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Senin Puanın:'**
  String get addRecordRatingLabel;

  /// No description provided for @addRecordPlaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Nerede İzledin?'**
  String get addRecordPlaceLabel;

  /// No description provided for @addRecordPlaceHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Kadıköy Sineması, Ev...'**
  String get addRecordPlaceHint;

  /// No description provided for @addRecordCompanionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kiminle İzledin?'**
  String get addRecordCompanionLabel;

  /// No description provided for @addRecordCompanionHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Tek başıma, Ahmet, Ailem...'**
  String get addRecordCompanionHint;

  /// No description provided for @addRecordNotesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Notların:'**
  String get addRecordNotesLabel;

  /// No description provided for @addRecordNotesHint.
  ///
  /// In tr, this message translates to:
  /// **'Film hakkında ne düşünüyorsun? Akılda kalıcı sahneler...'**
  String get addRecordNotesHint;

  /// No description provided for @addRecordTagsLabel.
  ///
  /// In tr, this message translates to:
  /// **'Özel Etiketler (#tag):'**
  String get addRecordTagsLabel;

  /// No description provided for @addRecordTagsHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: #nostalji, #sinemada, #yalnız (Virgülle ayırın)...'**
  String get addRecordTagsHint;

  /// No description provided for @addRecordVisibilityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Profilimde Göster'**
  String get addRecordVisibilityLabel;

  /// No description provided for @addRecordVisibilityHint.
  ///
  /// In tr, this message translates to:
  /// **'Açarsan bu kayıt profilindeki \"Son İzlediklerim\" bölümünde herkese görünür.'**
  String get addRecordVisibilityHint;

  /// No description provided for @addRecordContentSection.
  ///
  /// In tr, this message translates to:
  /// **'İçerik'**
  String get addRecordContentSection;

  /// No description provided for @placeHome.
  ///
  /// In tr, this message translates to:
  /// **'Ev'**
  String get placeHome;

  /// No description provided for @placeCinema.
  ///
  /// In tr, this message translates to:
  /// **'Sinema'**
  String get placeCinema;

  /// No description provided for @placeFriendsHouse.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşın Evi'**
  String get placeFriendsHouse;

  /// No description provided for @placeTravelling.
  ///
  /// In tr, this message translates to:
  /// **'Yolculukta'**
  String get placeTravelling;

  /// No description provided for @placeHotel.
  ///
  /// In tr, this message translates to:
  /// **'Otelde'**
  String get placeHotel;

  /// No description provided for @placePlane.
  ///
  /// In tr, this message translates to:
  /// **'Uçakta'**
  String get placePlane;

  /// No description provided for @placeGarden.
  ///
  /// In tr, this message translates to:
  /// **'Bahçede'**
  String get placeGarden;

  /// No description provided for @placeCamping.
  ///
  /// In tr, this message translates to:
  /// **'Kampta'**
  String get placeCamping;

  /// No description provided for @placeWork.
  ///
  /// In tr, this message translates to:
  /// **'İş Yerinde'**
  String get placeWork;

  /// No description provided for @companionAlone.
  ///
  /// In tr, this message translates to:
  /// **'Tek Başına'**
  String get companionAlone;

  /// No description provided for @companionFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarla'**
  String get companionFriends;

  /// No description provided for @companionFamily.
  ///
  /// In tr, this message translates to:
  /// **'Ailemle'**
  String get companionFamily;

  /// No description provided for @companionPartner.
  ///
  /// In tr, this message translates to:
  /// **'Sevgilimle'**
  String get companionPartner;

  /// No description provided for @companionSpouse.
  ///
  /// In tr, this message translates to:
  /// **'Eşimle'**
  String get companionSpouse;

  /// No description provided for @companionSibling.
  ///
  /// In tr, this message translates to:
  /// **'Kardeşimle'**
  String get companionSibling;

  /// No description provided for @companionKids.
  ///
  /// In tr, this message translates to:
  /// **'Çocuklarla'**
  String get companionKids;

  /// No description provided for @companionColleagues.
  ///
  /// In tr, this message translates to:
  /// **'İş Arkadaşlarımla'**
  String get companionColleagues;

  /// No description provided for @episodeTrackingActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif İzliyorum'**
  String get episodeTrackingActive;

  /// No description provided for @episodeTrackingWholeSeason.
  ///
  /// In tr, this message translates to:
  /// **'Tüm sezonu bitirdim'**
  String get episodeTrackingWholeSeason;

  /// No description provided for @episodeTrackingSpecificCount.
  ///
  /// In tr, this message translates to:
  /// **'Belirli sayıda bölüm'**
  String get episodeTrackingSpecificCount;

  /// No description provided for @episodeTrackingCountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kaç bölüm izledin?'**
  String get episodeTrackingCountLabel;

  /// No description provided for @episodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {episode}'**
  String episodeLabel(int episode);

  /// No description provided for @episodeLabelOf.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {episode} / {total}'**
  String episodeLabelOf(int episode, int total);

  /// No description provided for @episodeGuideTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm Rehberi'**
  String get episodeGuideTitle;

  /// No description provided for @episodeGuideEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu sezona ait bölüm bulunamadı.'**
  String get episodeGuideEmpty;

  /// No description provided for @episodeGuideLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bölümler yüklenemedi. Lütfen tekrar deneyin.'**
  String get episodeGuideLoadFailed;

  /// No description provided for @episodeNoOverview.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm özeti bulunmuyor.'**
  String get episodeNoOverview;

  /// No description provided for @episodeMarkSeasonWatched.
  ///
  /// In tr, this message translates to:
  /// **'Bu Sezonu İzledim'**
  String get episodeMarkSeasonWatched;

  /// No description provided for @episodeMarkFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm işaretlenemedi.'**
  String get episodeMarkFailed;

  /// No description provided for @episodeAddShowPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Bu diziyi günlüğüne eklemek ister misin?'**
  String get episodeAddShowPrompt;

  /// No description provided for @episodeAddShowExplain.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğe eklersen \"Aktif İzliyorum\" listende görünür ve istatistiklerine yansır.'**
  String get episodeAddShowExplain;

  /// No description provided for @episodeFollowOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Takip Et'**
  String get episodeFollowOnly;

  /// No description provided for @episodeConfirmWatchedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölümleri İzledin mi?'**
  String get episodeConfirmWatchedTitle;

  /// No description provided for @episodeUndoProgressTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme İlerlemesini Geri Al?'**
  String get episodeUndoProgressTitle;

  /// No description provided for @commonYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get commonYes;

  /// No description provided for @offlineOverviewUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı mod: Özet yüklenemedi.'**
  String get offlineOverviewUnavailable;

  /// No description provided for @offlineContentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı İçerik'**
  String get offlineContentTitle;

  /// No description provided for @offlineFallbackOverview.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı sorunu nedeniyle film detayları tam yüklenemedi. Ancak bu içeriği hala günlüğünüze veya listelerinize ekleyebilirsiniz.'**
  String get offlineFallbackOverview;

  /// No description provided for @journalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğüm'**
  String get journalTitle;

  /// No description provided for @journalTabDiary.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get journalTabDiary;

  /// No description provided for @journalTabLists.
  ///
  /// In tr, this message translates to:
  /// **'Listeler'**
  String get journalTabLists;

  /// No description provided for @journalTabInsights.
  ///
  /// In tr, this message translates to:
  /// **'Analiz'**
  String get journalTabInsights;

  /// No description provided for @journalSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Film, yönetmen, not, mekan...'**
  String get journalSearchHint;

  /// No description provided for @journalFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get journalFilterAll;

  /// No description provided for @journalFilterFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get journalFilterFavorites;

  /// No description provided for @journalFilterCinema.
  ///
  /// In tr, this message translates to:
  /// **'Sinemada'**
  String get journalFilterCinema;

  /// No description provided for @journalFilterWithNotes.
  ///
  /// In tr, this message translates to:
  /// **'Notlu Olanlar'**
  String get journalFilterWithNotes;

  /// No description provided for @journalStatThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get journalStatThisMonth;

  /// No description provided for @journalStatAvgRating.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Puan'**
  String get journalStatAvgRating;

  /// No description provided for @journalStatFavoriteGenre.
  ///
  /// In tr, this message translates to:
  /// **'Favori Tür'**
  String get journalStatFavoriteGenre;

  /// No description provided for @journalStatTotalTime.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get journalStatTotalTime;

  /// No description provided for @journalStatUndetermined.
  ///
  /// In tr, this message translates to:
  /// **'Belirsiz'**
  String get journalStatUndetermined;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Bulunamadı'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyFiltered.
  ///
  /// In tr, this message translates to:
  /// **'Arama kriterlerinize veya filtrelere uyan bir günlük kaydı bulunmamaktadır.'**
  String get journalEmptyFiltered;

  /// No description provided for @journalEmptyNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğünüz henüz boş. Keşfet sekmesinden yeni izleme kayıtları ekleyebilirsiniz.'**
  String get journalEmptyNoRecords;

  /// No description provided for @journalLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Günlük yüklenemedi. Lütfen tekrar deneyin.'**
  String get journalLoadFailed;

  /// No description provided for @journalReorderFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama kaydedilemedi. Lütfen tekrar deneyin.'**
  String get journalReorderFailed;

  /// No description provided for @journalColumnRank.
  ///
  /// In tr, this message translates to:
  /// **'Sıra'**
  String get journalColumnRank;

  /// No description provided for @journalColumnTitle.
  ///
  /// In tr, this message translates to:
  /// **'Film Adı'**
  String get journalColumnTitle;

  /// No description provided for @journalColumnWatchDate.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Tarihi'**
  String get journalColumnWatchDate;

  /// No description provided for @journalColumnWatch.
  ///
  /// In tr, this message translates to:
  /// **'İzleme'**
  String get journalColumnWatch;

  /// No description provided for @journalColumnWatchOrder.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Sırası'**
  String get journalColumnWatchOrder;

  /// No description provided for @collectionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonlarım'**
  String get collectionsTitle;

  /// No description provided for @watchlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Listem'**
  String get watchlistTitle;

  /// No description provided for @watchlistItemCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} yapım'**
  String watchlistItemCount(int count);

  /// No description provided for @watchlistEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Listen Boş'**
  String get watchlistEmptyTitle;

  /// No description provided for @watchlistEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Kaydır & Keşfet\'te sağa kaydırdığın veya detay sayfasından kaydettiğin yapımlar burada görünür.'**
  String get watchlistEmptyHint;

  /// No description provided for @watchlistRemove.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listesinden çıkar'**
  String get watchlistRemove;

  /// No description provided for @watchlistRemoved.
  ///
  /// In tr, this message translates to:
  /// **'İzleme listesinden çıkarıldı'**
  String get watchlistRemoved;

  /// No description provided for @collectionsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hiç Koleksiyonunuz Yok'**
  String get collectionsEmptyTitle;

  /// No description provided for @collectionsCreate.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon Oluştur'**
  String get collectionsCreate;

  /// No description provided for @collectionsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonlar yüklenemedi.'**
  String get collectionsLoadFailed;

  /// No description provided for @collectionAddTo.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyona Ekle'**
  String get collectionAddTo;

  /// No description provided for @collectionNewList.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Liste'**
  String get collectionNewList;

  /// No description provided for @collectionNoneYet.
  ///
  /// In tr, this message translates to:
  /// **'Hiç koleksiyonunuz yok.'**
  String get collectionNoneYet;

  /// No description provided for @collectionNoneYetHint.
  ///
  /// In tr, this message translates to:
  /// **'Eklemek için sağ üstteki \"+ Yeni Liste\" butonuna basın.'**
  String get collectionNoneYetHint;

  /// No description provided for @collectionUpdateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Liste güncellenemedi, tekrar deneyin.'**
  String get collectionUpdateFailed;

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// Heading of the streaming-availability section on a title's detail screen.
  ///
  /// In tr, this message translates to:
  /// **'Nerede İzlenir?'**
  String get detailWhereToWatch;

  /// Included in a subscription the user may already pay for.
  ///
  /// In tr, this message translates to:
  /// **'Abonelikle'**
  String get detailWatchCategoryFlatrate;

  /// Free to watch, possibly with ads. Covers TMDb's 'free' and 'ads' buckets.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz'**
  String get detailWatchCategoryFree;

  /// Available to rent for a single viewing period.
  ///
  /// In tr, this message translates to:
  /// **'Kirala'**
  String get detailWatchCategoryRent;

  /// Available to buy outright.
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get detailWatchCategoryBuy;

  /// Required credit: TMDb sources watch-provider data from JustWatch and their terms require attributing it.
  ///
  /// In tr, this message translates to:
  /// **'Yayın platformu bilgileri JustWatch tarafından sağlanmaktadır.'**
  String get detailWatchProvidersJustWatchAttribution;

  /// Settings row for the country streaming availability is looked up for.
  ///
  /// In tr, this message translates to:
  /// **'Yayın Bölgesi'**
  String get settingsWatchRegionLabel;

  /// Title of the region picker dialog.
  ///
  /// In tr, this message translates to:
  /// **'Bölge Seçin'**
  String get settingsWatchRegionTitle;

  /// Shown when the region follows the device. Names the country it resolved to, so 'Automatic' isn't a mystery.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik ({region})'**
  String settingsWatchRegionAutoWith(String region);

  /// Shown where a failed load renders its raw error text.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {detail}'**
  String commonErrorWithDetail(String detail);

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileBioLabel.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get profileBioLabel;

  /// No description provided for @profileBioHint.
  ///
  /// In tr, this message translates to:
  /// **'Kendinden bahset...'**
  String get profileBioHint;

  /// No description provided for @collectionEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonu Düzenle'**
  String get collectionEditTitle;

  /// No description provided for @collectionCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Koleksiyon Oluştur'**
  String get collectionCreateTitle;

  /// No description provided for @collectionEditExplain.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonunuzun adı, açıklaması ve maraton tarihini güncelleyin.'**
  String get collectionEditExplain;

  /// No description provided for @collectionCreateExplain.
  ///
  /// In tr, this message translates to:
  /// **'Film maratonlarınızı takip etmek veya tematik listeler oluşturmak için bilgileri girin.'**
  String get collectionCreateExplain;

  /// No description provided for @collectionNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon Adı'**
  String get collectionNameLabel;

  /// No description provided for @collectionNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Marvel Maratonu, Başyapıtlar...'**
  String get collectionNameHint;

  /// No description provided for @collectionDescriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (İsteğe Bağlı)'**
  String get collectionDescriptionLabel;

  /// No description provided for @collectionDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonunuza dair kısa bir açıklama yazın...'**
  String get collectionDescriptionHint;

  /// No description provided for @collectionTargetDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Maraton Hedef Tarihi'**
  String get collectionTargetDateLabel;

  /// No description provided for @collectionTargetDatePick.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tarih Seçin (İsteğe Bağlı)'**
  String get collectionTargetDatePick;

  /// No description provided for @commonCreate.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get commonCreate;

  /// No description provided for @collectionEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu Koleksiyon Boş'**
  String get collectionEmptyTitle;

  /// No description provided for @collectionEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet sekmesinden filmler arayarak veya detay sayfalarından bu koleksiyona filmler ekleyebilirsiniz.'**
  String get collectionEmptyHint;

  /// No description provided for @collectionRemovedMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film koleksiyondan çıkarıldı.'**
  String get collectionRemovedMovie;

  /// No description provided for @collectionDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonu Sil?'**
  String get collectionDeleteTitle;

  /// No description provided for @collectionShared.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukla paylaşılıyor'**
  String get collectionShared;

  /// No description provided for @collectionStopSharing.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımı Durdur'**
  String get collectionStopSharing;

  /// No description provided for @collectionStopSharingFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım durdurulamadı, tekrar deneyin.'**
  String get collectionStopSharingFailed;

  /// No description provided for @collectionReorderFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama kaydedilemedi, tekrar deneyin.'**
  String get collectionReorderFailed;

  /// No description provided for @marathonExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süre Doldu! ⚠️'**
  String get marathonExpired;

  /// No description provided for @marathonDaysLeft.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe ulaşmak için {days} gün kaldı.'**
  String marathonDaysLeft(int days);

  /// No description provided for @marathonCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler, maratonu tamamladınız! 🎉'**
  String get marathonCompleted;

  /// No description provided for @marathonRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan: {count} film.'**
  String marathonRemaining(int count);

  /// No description provided for @recordMood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali: {mood}'**
  String recordMood(String mood);

  /// No description provided for @recordWatchDate.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Tarihi'**
  String get recordWatchDate;

  /// No description provided for @recordEpisodesWatched.
  ///
  /// In tr, this message translates to:
  /// **'İzlenen Bölüm Sayısı'**
  String get recordEpisodesWatched;

  /// No description provided for @recordEpisodeCount.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm Sayısı'**
  String get recordEpisodeCount;

  /// No description provided for @recordEpisodeCountHint.
  ///
  /// In tr, this message translates to:
  /// **'Kaç bölüm izlendi?'**
  String get recordEpisodeCountHint;

  /// No description provided for @recordWatchPlace.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Mekanı'**
  String get recordWatchPlace;

  /// No description provided for @recordCompanions.
  ///
  /// In tr, this message translates to:
  /// **'Eşlik Edenler'**
  String get recordCompanions;

  /// No description provided for @recordVisibilityFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım durumu güncellenemedi.'**
  String get recordVisibilityFailed;

  /// No description provided for @recordMyRank.
  ///
  /// In tr, this message translates to:
  /// **'Favori Sıram: '**
  String get recordMyRank;

  /// No description provided for @recordRemoveRank.
  ///
  /// In tr, this message translates to:
  /// **'Sıradan Çıkar'**
  String get recordRemoveRank;

  /// No description provided for @recordMyNotes.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Notlarım:'**
  String get recordMyNotes;

  /// No description provided for @recordNoNotes.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt eklenirken not yazılmamış.'**
  String get recordNoNotes;

  /// No description provided for @recordDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Emin misiniz?'**
  String get recordDeleteConfirmTitle;

  /// No description provided for @recordDeleteConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu izleme kaydı silinecek.'**
  String get recordDeleteConfirmBody;

  /// No description provided for @recordDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt silinemedi. Lütfen tekrar deneyin.'**
  String get recordDeleteFailed;

  /// No description provided for @recordDelete.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı Sil'**
  String get recordDelete;

  /// No description provided for @insightsInsufficientData.
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz Veri'**
  String get insightsInsufficientData;

  /// No description provided for @insightsSummaryTotalWatches.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İzleme'**
  String get insightsSummaryTotalWatches;

  /// No description provided for @insightsSummaryUniqueTitles.
  ///
  /// In tr, this message translates to:
  /// **'Tekil İçerik'**
  String get insightsSummaryUniqueTitles;

  /// No description provided for @insightsSummaryTotalTime.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Süre'**
  String get insightsSummaryTotalTime;

  /// No description provided for @insightsSummaryAvgRating.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Puan'**
  String get insightsSummaryAvgRating;

  /// No description provided for @insightsGenreChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'En Popüler Türler (Tür Dağılımı)'**
  String get insightsGenreChartTitle;

  /// No description provided for @insightsGenreOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get insightsGenreOther;

  /// No description provided for @insightsRatingChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Puan Dağılımı'**
  String get insightsRatingChartTitle;

  /// No description provided for @insightsCriticProfile.
  ///
  /// In tr, this message translates to:
  /// **'Eleştirmen Profilin'**
  String get insightsCriticProfile;

  /// No description provided for @insightsTopDirectors.
  ///
  /// In tr, this message translates to:
  /// **'En Çok İzlenen Yönetmenler'**
  String get insightsTopDirectors;

  /// No description provided for @insightsTopActors.
  ///
  /// In tr, this message translates to:
  /// **'En Çok İzlenen Oyuncular'**
  String get insightsTopActors;

  /// No description provided for @insightsNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bulunamadı.'**
  String get insightsNoRecords;

  /// No description provided for @insightsTimeOfDayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün Hangi Saatlerinde İzliyorsun?'**
  String get insightsTimeOfDayTitle;

  /// No description provided for @insightsTimeMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get insightsTimeMorning;

  /// No description provided for @insightsTimeNoon.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get insightsTimeNoon;

  /// No description provided for @insightsTimeEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get insightsTimeEvening;

  /// No description provided for @insightsTimeNight.
  ///
  /// In tr, this message translates to:
  /// **'Gece'**
  String get insightsTimeNight;

  /// No description provided for @insightsSeasonWinter.
  ///
  /// In tr, this message translates to:
  /// **'Kış'**
  String get insightsSeasonWinter;

  /// No description provided for @insightsSeasonSpring.
  ///
  /// In tr, this message translates to:
  /// **'İlkbahar'**
  String get insightsSeasonSpring;

  /// No description provided for @insightsSeasonSummer.
  ///
  /// In tr, this message translates to:
  /// **'Yaz'**
  String get insightsSeasonSummer;

  /// No description provided for @insightsSeasonAutumn.
  ///
  /// In tr, this message translates to:
  /// **'Sonbahar'**
  String get insightsSeasonAutumn;

  /// No description provided for @insightsMonthlyChartTitle.
  ///
  /// In tr, this message translates to:
  /// **'{year} Aylık İzleme Grafiği'**
  String insightsMonthlyChartTitle(int year);

  /// No description provided for @insightsWatchesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} İzleme'**
  String insightsWatchesCount(int count);

  /// No description provided for @insightsGoldenDay.
  ///
  /// In tr, this message translates to:
  /// **'Altın Gün: {day} 🏆'**
  String insightsGoldenDay(String day);

  /// No description provided for @heatmapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık İzleme Sıklığı'**
  String get heatmapTitle;

  /// No description provided for @heatmapFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get heatmapFilterAll;

  /// No description provided for @heatmapFilterMovies.
  ///
  /// In tr, this message translates to:
  /// **'Filmler'**
  String get heatmapFilterMovies;

  /// No description provided for @heatmapFilterShows.
  ///
  /// In tr, this message translates to:
  /// **'Diziler'**
  String get heatmapFilterShows;

  /// No description provided for @heatmapLegendLess.
  ///
  /// In tr, this message translates to:
  /// **'Az'**
  String get heatmapLegendLess;

  /// No description provided for @heatmapLegendMore.
  ///
  /// In tr, this message translates to:
  /// **'Çok'**
  String get heatmapLegendMore;

  /// No description provided for @heatmapLegendMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get heatmapLegendMovie;

  /// No description provided for @heatmapLegendShow.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get heatmapLegendShow;

  /// No description provided for @heatmapLegendBoth.
  ///
  /// In tr, this message translates to:
  /// **'İkisi'**
  String get heatmapLegendBoth;

  /// No description provided for @heatmapActiveDays.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Gün'**
  String get heatmapActiveDays;

  /// No description provided for @heatmapCurrentStreak.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Seri'**
  String get heatmapCurrentStreak;

  /// No description provided for @heatmapPeakHour.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun Saat'**
  String get heatmapPeakHour;

  /// No description provided for @heatmapNoRecordOnDay.
  ///
  /// In tr, this message translates to:
  /// **'tarihinde izleme kaydı yok.'**
  String get heatmapNoRecordOnDay;

  /// No description provided for @weeklyGoalSetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Hedefi Ayarla'**
  String get weeklyGoalSetTitle;

  /// No description provided for @weeklyGoalQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Haftada kaç film/dizi izlemek istersiniz?'**
  String get weeklyGoalQuestion;

  /// No description provided for @weeklyGoalThisWeekPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta '**
  String get weeklyGoalThisWeekPrefix;

  /// No description provided for @weeklyGoalReached.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler, bu haftaki hedefinize ulaştınız! 🎉'**
  String get weeklyGoalReached;

  /// No description provided for @weeklyGoalRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe ulaşmak için {count} film daha izlemelisiniz.'**
  String weeklyGoalRemaining(int count);

  /// No description provided for @achievementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Rozet & Başarım Koleksiyonu'**
  String get achievementsTitle;

  /// No description provided for @achievementsNeedRecords.
  ///
  /// In tr, this message translates to:
  /// **'Rozetlerin yüklenmesi için günlüğünüze en az 1 izleme kaydı eklemelisiniz.'**
  String get achievementsNeedRecords;

  /// No description provided for @achievementsCurrentRank.
  ///
  /// In tr, this message translates to:
  /// **'MEVCUT UNVAN'**
  String get achievementsCurrentRank;

  /// No description provided for @achievementsProgress.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon İlerlemesi'**
  String get achievementsProgress;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılanlar'**
  String get achievementsUnlocked;

  /// No description provided for @achievementsNoneForFilter.
  ///
  /// In tr, this message translates to:
  /// **'Seçili filtreye uygun rozet bulunamadı.'**
  String get achievementsNoneForFilter;

  /// No description provided for @achievementsAllCount.
  ///
  /// In tr, this message translates to:
  /// **'Tümü ({count})'**
  String achievementsAllCount(int count);

  /// No description provided for @achievementsRankNoviceSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sinema yolculuğuna yeni başladın'**
  String get achievementsRankNoviceSubtitle;

  /// No description provided for @achievementsRankTicketBuddy.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Bilet Ortağı 🎬'**
  String get achievementsRankTicketBuddy;

  /// No description provided for @achievementsRankTicketBuddySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli izleyici'**
  String get achievementsRankTicketBuddySubtitle;

  /// No description provided for @achievementsRankConnoisseurSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sinematik hafızası yüksek'**
  String get achievementsRankConnoisseurSubtitle;

  /// No description provided for @achievementsRankGuruSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek bir kültür abidesi'**
  String get achievementsRankGuruSubtitle;

  /// No description provided for @badgeMaxLevel.
  ///
  /// In tr, this message translates to:
  /// **'Maksimum Seviye! 👑'**
  String get badgeMaxLevel;

  /// No description provided for @badgeNextLevelProgress.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Seviye İlerlemesi'**
  String get badgeNextLevelProgress;

  /// No description provided for @badgeUnlockProgress.
  ///
  /// In tr, this message translates to:
  /// **'Kilit İlerlemesi'**
  String get badgeUnlockProgress;

  /// No description provided for @badgeShare.
  ///
  /// In tr, this message translates to:
  /// **'Başarımı Paylaş'**
  String get badgeShare;

  /// No description provided for @badgeCategoryMilestone.
  ///
  /// In tr, this message translates to:
  /// **'Hacim & Maraton'**
  String get badgeCategoryMilestone;

  /// No description provided for @badgeCategoryTime.
  ///
  /// In tr, this message translates to:
  /// **'Zaman & Atmosfer'**
  String get badgeCategoryTime;

  /// No description provided for @badgeCategoryDirectors.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmenler & Auteurs'**
  String get badgeCategoryDirectors;

  /// No description provided for @badgeCategoryGenres.
  ///
  /// In tr, this message translates to:
  /// **'Türler & Temalar'**
  String get badgeCategoryGenres;

  /// No description provided for @badgeCategoryCritic.
  ///
  /// In tr, this message translates to:
  /// **'Eleştirmen & Günlük'**
  String get badgeCategoryCritic;

  /// No description provided for @badgeCategorySeries.
  ///
  /// In tr, this message translates to:
  /// **'Dizi & Sezon'**
  String get badgeCategorySeries;

  /// No description provided for @badgeFirstWatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk Adımlar'**
  String get badgeFirstWatchTitle;

  /// No description provided for @badgeFirstWatchT1.
  ///
  /// In tr, this message translates to:
  /// **'İlk Adım'**
  String get badgeFirstWatchT1;

  /// No description provided for @badgeFirstWatchT2.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Tutkusu'**
  String get badgeFirstWatchT2;

  /// No description provided for @badgeFirstWatchT3.
  ///
  /// In tr, this message translates to:
  /// **'Sıkı Takipçi'**
  String get badgeFirstWatchT3;

  /// No description provided for @badgeSinefilTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sinefil Serisi'**
  String get badgeSinefilTitle;

  /// No description provided for @badgeSinefilT1.
  ///
  /// In tr, this message translates to:
  /// **'Sinefil'**
  String get badgeSinefilT1;

  /// No description provided for @badgeSinefilT2.
  ///
  /// In tr, this message translates to:
  /// **'Kültür Mantarı'**
  String get badgeSinefilT2;

  /// No description provided for @badgeSinefilT3.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Efsanesi'**
  String get badgeSinefilT3;

  /// No description provided for @badgeSinefilT4.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Gurusu'**
  String get badgeSinefilT4;

  /// No description provided for @badgeStreakTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seri İzleyici'**
  String get badgeStreakTitle;

  /// No description provided for @badgeStreakT1.
  ///
  /// In tr, this message translates to:
  /// **'Kısa Maraton'**
  String get badgeStreakT1;

  /// No description provided for @badgeStreakT2.
  ///
  /// In tr, this message translates to:
  /// **'Seri İzleyici'**
  String get badgeStreakT2;

  /// No description provided for @badgeStreakT3.
  ///
  /// In tr, this message translates to:
  /// **'Ateşli İzleyici'**
  String get badgeStreakT3;

  /// No description provided for @badgeStreakT4.
  ///
  /// In tr, this message translates to:
  /// **'Durdurulamaz Maratoncu'**
  String get badgeStreakT4;

  /// No description provided for @badgeNightOwlTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gece Kuşu Serisi'**
  String get badgeNightOwlTitle;

  /// No description provided for @badgeNightOwlT1.
  ///
  /// In tr, this message translates to:
  /// **'Gece Kuşu'**
  String get badgeNightOwlT1;

  /// No description provided for @badgeNightOwlT2.
  ///
  /// In tr, this message translates to:
  /// **'Gece Bekçisi'**
  String get badgeNightOwlT2;

  /// No description provided for @badgeNightOwlT3.
  ///
  /// In tr, this message translates to:
  /// **'Karanlıklar Prensi'**
  String get badgeNightOwlT3;

  /// No description provided for @badgeEarlyBirdTitle.
  ///
  /// In tr, this message translates to:
  /// **'Erken Kuş Serisi'**
  String get badgeEarlyBirdTitle;

  /// No description provided for @badgeEarlyBirdT1.
  ///
  /// In tr, this message translates to:
  /// **'Gün Doğumu İzleyicisi'**
  String get badgeEarlyBirdT1;

  /// No description provided for @badgeEarlyBirdT2.
  ///
  /// In tr, this message translates to:
  /// **'Erken Kuş'**
  String get badgeEarlyBirdT2;

  /// No description provided for @badgeEarlyBirdT3.
  ///
  /// In tr, this message translates to:
  /// **'Şafak Bekçisi'**
  String get badgeEarlyBirdT3;

  /// No description provided for @badgeSundayTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pazar Sineması'**
  String get badgeSundayTitle;

  /// No description provided for @badgeSundayT1.
  ///
  /// In tr, this message translates to:
  /// **'Pazar Keyfi'**
  String get badgeSundayT1;

  /// No description provided for @badgeSundayT2.
  ///
  /// In tr, this message translates to:
  /// **'Pazar Sineması'**
  String get badgeSundayT2;

  /// No description provided for @badgeSundayT3.
  ///
  /// In tr, this message translates to:
  /// **'Pazar Üstadı'**
  String get badgeSundayT3;

  /// No description provided for @badgeWeekendTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sonu Maratonu'**
  String get badgeWeekendTitle;

  /// No description provided for @badgeWeekendT1.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sonu Başlangıcı'**
  String get badgeWeekendT1;

  /// No description provided for @badgeWeekendT2.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sonu Maratoncusu'**
  String get badgeWeekendT2;

  /// No description provided for @badgeWeekendT3.
  ///
  /// In tr, this message translates to:
  /// **'Hafta Sonu Canavarı'**
  String get badgeWeekendT3;

  /// No description provided for @badgeWinterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kışlık Battaniye & Film'**
  String get badgeWinterTitle;

  /// No description provided for @badgeWinterT1.
  ///
  /// In tr, this message translates to:
  /// **'Mevsimlik İzleyici'**
  String get badgeWinterT1;

  /// No description provided for @badgeWinterT2.
  ///
  /// In tr, this message translates to:
  /// **'Kışlık Battaniye & Film'**
  String get badgeWinterT2;

  /// No description provided for @badgeWinterT3.
  ///
  /// In tr, this message translates to:
  /// **'Dört Mevsim Sinefil'**
  String get badgeWinterT3;

  /// No description provided for @badgeTimeTravelerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Gezgini'**
  String get badgeTimeTravelerTitle;

  /// No description provided for @badgeTimeTravelerT1.
  ///
  /// In tr, this message translates to:
  /// **'Nostalji Meraklısı'**
  String get badgeTimeTravelerT1;

  /// No description provided for @badgeTimeTravelerT2.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Gezgini'**
  String get badgeTimeTravelerT2;

  /// No description provided for @badgeTimeTravelerT3.
  ///
  /// In tr, this message translates to:
  /// **'Klasikler Arşivcisi'**
  String get badgeTimeTravelerT3;

  /// No description provided for @badgeNolanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Nolanist Serisi'**
  String get badgeNolanTitle;

  /// No description provided for @badgeNolanT1.
  ///
  /// In tr, this message translates to:
  /// **'Nolan Meraklısı'**
  String get badgeNolanT1;

  /// No description provided for @badgeNolanT2.
  ///
  /// In tr, this message translates to:
  /// **'Zaman Büken Nolanist'**
  String get badgeNolanT2;

  /// No description provided for @badgeNolanT3.
  ///
  /// In tr, this message translates to:
  /// **'Rüya İçinde Rüya Mimarı'**
  String get badgeNolanT3;

  /// No description provided for @badgeTarantinoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarantino Sever'**
  String get badgeTarantinoTitle;

  /// No description provided for @badgeTarantinoT1.
  ///
  /// In tr, this message translates to:
  /// **'Ucuz Roman Sever'**
  String get badgeTarantinoT1;

  /// No description provided for @badgeTarantinoT2.
  ///
  /// In tr, this message translates to:
  /// **'Kanlı İntikam Ustası'**
  String get badgeTarantinoT2;

  /// No description provided for @badgeTarantinoT3.
  ///
  /// In tr, this message translates to:
  /// **'Sinematik Auteur'**
  String get badgeTarantinoT3;

  /// No description provided for @badgeSpielbergTitle.
  ///
  /// In tr, this message translates to:
  /// **'Spielberg Hayranı'**
  String get badgeSpielbergTitle;

  /// No description provided for @badgeSpielbergT1.
  ///
  /// In tr, this message translates to:
  /// **'Macera Çırağı'**
  String get badgeSpielbergT1;

  /// No description provided for @badgeSpielbergT2.
  ///
  /// In tr, this message translates to:
  /// **'Spielberg Hayranı'**
  String get badgeSpielbergT2;

  /// No description provided for @badgeSpielbergT3.
  ///
  /// In tr, this message translates to:
  /// **'Blockbuster Efsanesi'**
  String get badgeSpielbergT3;

  /// No description provided for @badgeScorseseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Scorsese Müptelası'**
  String get badgeScorseseTitle;

  /// No description provided for @badgeScorseseT1.
  ///
  /// In tr, this message translates to:
  /// **'Mafya & Suç Sever'**
  String get badgeScorseseT1;

  /// No description provided for @badgeScorseseT2.
  ///
  /// In tr, this message translates to:
  /// **'Scorsese Müptelası'**
  String get badgeScorseseT2;

  /// No description provided for @badgeScorseseT3.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Sanatçısı'**
  String get badgeScorseseT3;

  /// No description provided for @badgeKubrickTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kubrick Ustalığı'**
  String get badgeKubrickTitle;

  /// No description provided for @badgeKubrickT1.
  ///
  /// In tr, this message translates to:
  /// **'Kubrick Çırağı'**
  String get badgeKubrickT1;

  /// No description provided for @badgeKubrickT2.
  ///
  /// In tr, this message translates to:
  /// **'Kubrick Ustalığı'**
  String get badgeKubrickT2;

  /// No description provided for @badgeKubrickT3.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Vizyoner'**
  String get badgeKubrickT3;

  /// No description provided for @badgeWesternTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vahşi Batı Serisi'**
  String get badgeWesternTitle;

  /// No description provided for @badgeWesternT1.
  ///
  /// In tr, this message translates to:
  /// **'Vahşi Batı Kaşifi'**
  String get badgeWesternT1;

  /// No description provided for @badgeWesternT2.
  ///
  /// In tr, this message translates to:
  /// **'Kovboy & Şerif'**
  String get badgeWesternT2;

  /// No description provided for @badgeWesternT3.
  ///
  /// In tr, this message translates to:
  /// **'İyi, Kötü ve Çirkin Efsanesi'**
  String get badgeWesternT3;

  /// No description provided for @badgeScifiTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sci-Fi Kaşifi'**
  String get badgeScifiTitle;

  /// No description provided for @badgeScifiT1.
  ///
  /// In tr, this message translates to:
  /// **'Uzay Yolcusu'**
  String get badgeScifiT1;

  /// No description provided for @badgeScifiT2.
  ///
  /// In tr, this message translates to:
  /// **'Galaksi Kaşifi'**
  String get badgeScifiT2;

  /// No description provided for @badgeScifiT3.
  ///
  /// In tr, this message translates to:
  /// **'Evrenin Hakimi'**
  String get badgeScifiT3;

  /// No description provided for @badgeHorrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Korku & Gerilim'**
  String get badgeHorrorTitle;

  /// No description provided for @badgeHorrorT1.
  ///
  /// In tr, this message translates to:
  /// **'Korkusuz İzleyici'**
  String get badgeHorrorT1;

  /// No description provided for @badgeHorrorT2.
  ///
  /// In tr, this message translates to:
  /// **'Gerilim Üstadı'**
  String get badgeHorrorT2;

  /// No description provided for @badgeHorrorT3.
  ///
  /// In tr, this message translates to:
  /// **'Kabusların Efendisi'**
  String get badgeHorrorT3;

  /// No description provided for @badgeDramaTitle.
  ///
  /// In tr, this message translates to:
  /// **'Drama Tutkunu'**
  String get badgeDramaTitle;

  /// No description provided for @badgeDramaT1.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal İzleyici'**
  String get badgeDramaT1;

  /// No description provided for @badgeDramaT2.
  ///
  /// In tr, this message translates to:
  /// **'Drama Tutkunu'**
  String get badgeDramaT2;

  /// No description provided for @badgeDramaT3.
  ///
  /// In tr, this message translates to:
  /// **'Duygu Üstadı'**
  String get badgeDramaT3;

  /// No description provided for @badgeCrimeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Suç & Gizem Ajanı'**
  String get badgeCrimeTitle;

  /// No description provided for @badgeCrimeT1.
  ///
  /// In tr, this message translates to:
  /// **'Amatör Dedektif'**
  String get badgeCrimeT1;

  /// No description provided for @badgeCrimeT2.
  ///
  /// In tr, this message translates to:
  /// **'Suç & Gizem Ajanı'**
  String get badgeCrimeT2;

  /// No description provided for @badgeCrimeT3.
  ///
  /// In tr, this message translates to:
  /// **'Sherlock Seviyesi'**
  String get badgeCrimeT3;

  /// No description provided for @badgeAnimationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Animasyon & Çizgi Düşler'**
  String get badgeAnimationTitle;

  /// No description provided for @badgeAnimationT1.
  ///
  /// In tr, this message translates to:
  /// **'Çizgi Sever'**
  String get badgeAnimationT1;

  /// No description provided for @badgeAnimationT2.
  ///
  /// In tr, this message translates to:
  /// **'Hayal Perdesi'**
  String get badgeAnimationT2;

  /// No description provided for @badgeAnimationT3.
  ///
  /// In tr, this message translates to:
  /// **'Anime & Animasyon Üstadı'**
  String get badgeAnimationT3;

  /// No description provided for @badgeTurkishTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yerli Sinema'**
  String get badgeTurkishTitle;

  /// No description provided for @badgeTurkishT1.
  ///
  /// In tr, this message translates to:
  /// **'Yerli Sinema Dostu'**
  String get badgeTurkishT1;

  /// No description provided for @badgeTurkishT2.
  ///
  /// In tr, this message translates to:
  /// **'Yeşilçam Sevdalısı'**
  String get badgeTurkishT2;

  /// No description provided for @badgeTurkishT3.
  ///
  /// In tr, this message translates to:
  /// **'Yerli Sinema Muhafızı'**
  String get badgeTurkishT3;

  /// No description provided for @badgeCriticTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eleştirmen Serisi'**
  String get badgeCriticTitle;

  /// No description provided for @badgeCriticT1.
  ///
  /// In tr, this message translates to:
  /// **'Not Tutucu'**
  String get badgeCriticT1;

  /// No description provided for @badgeCriticT2.
  ///
  /// In tr, this message translates to:
  /// **'Ciddi Eleştirmen'**
  String get badgeCriticT2;

  /// No description provided for @badgeCriticT3.
  ///
  /// In tr, this message translates to:
  /// **'Köşe Yazarı'**
  String get badgeCriticT3;

  /// No description provided for @badgeGenerousTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cömert Puanlayıcı'**
  String get badgeGenerousTitle;

  /// No description provided for @badgeGenerousT1.
  ///
  /// In tr, this message translates to:
  /// **'Tam Puan Sever'**
  String get badgeGenerousT1;

  /// No description provided for @badgeGenerousT2.
  ///
  /// In tr, this message translates to:
  /// **'Cömert Puanlayıcı'**
  String get badgeGenerousT2;

  /// No description provided for @badgeGenerousT3.
  ///
  /// In tr, this message translates to:
  /// **'Başyapıt Avcısı'**
  String get badgeGenerousT3;

  /// No description provided for @badgeStrictTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zor Beğenen'**
  String get badgeStrictTitle;

  /// No description provided for @badgeStrictT1.
  ///
  /// In tr, this message translates to:
  /// **'Sert Eleştirmen'**
  String get badgeStrictT1;

  /// No description provided for @badgeStrictT2.
  ///
  /// In tr, this message translates to:
  /// **'Zor Beğenen'**
  String get badgeStrictT2;

  /// No description provided for @badgeStrictT3.
  ///
  /// In tr, this message translates to:
  /// **'Affetmeyen Jüri'**
  String get badgeStrictT3;

  /// No description provided for @badgeRewatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sadık İzleyici'**
  String get badgeRewatchTitle;

  /// No description provided for @badgeRewatchT1.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar İzleyen'**
  String get badgeRewatchT1;

  /// No description provided for @badgeRewatchT2.
  ///
  /// In tr, this message translates to:
  /// **'Sadık İzleyici'**
  String get badgeRewatchT2;

  /// No description provided for @badgeRewatchT3.
  ///
  /// In tr, this message translates to:
  /// **'Fanatik Tekrarcı'**
  String get badgeRewatchT3;

  /// No description provided for @badgeTagMasterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Etiket Ustası'**
  String get badgeTagMasterTitle;

  /// No description provided for @badgeTagMasterT1.
  ///
  /// In tr, this message translates to:
  /// **'Etiket Çırağı'**
  String get badgeTagMasterT1;

  /// No description provided for @badgeTagMasterT2.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Ustası'**
  String get badgeTagMasterT2;

  /// No description provided for @badgeTagMasterT3.
  ///
  /// In tr, this message translates to:
  /// **'Etiket Koleksiyoneri'**
  String get badgeTagMasterT3;

  /// No description provided for @badgeTvTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dizi Kolik Serisi'**
  String get badgeTvTitle;

  /// No description provided for @badgeTvT1.
  ///
  /// In tr, this message translates to:
  /// **'Dizi Meraklısı'**
  String get badgeTvT1;

  /// No description provided for @badgeTvT2.
  ///
  /// In tr, this message translates to:
  /// **'Dizi Kolik'**
  String get badgeTvT2;

  /// No description provided for @badgeTvT3.
  ///
  /// In tr, this message translates to:
  /// **'Dizi Müptelası'**
  String get badgeTvT3;

  /// No description provided for @badgeSeasonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sezon Canavarı'**
  String get badgeSeasonTitle;

  /// No description provided for @badgeSeasonT1.
  ///
  /// In tr, this message translates to:
  /// **'Sezon Bitişi'**
  String get badgeSeasonT1;

  /// No description provided for @badgeSeasonT2.
  ///
  /// In tr, this message translates to:
  /// **'Sezon Canavarı'**
  String get badgeSeasonT2;

  /// No description provided for @badgeSeasonT3.
  ///
  /// In tr, this message translates to:
  /// **'Maraton Ustası'**
  String get badgeSeasonT3;

  /// No description provided for @badgeDescLogEntries.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğe {n} izleme kaydı ekle.'**
  String badgeDescLogEntries(int n);

  /// No description provided for @badgeDescWatchAtLeast.
  ///
  /// In tr, this message translates to:
  /// **'En az {n} film veya dizi izle.'**
  String badgeDescWatchAtLeast(int n);

  /// No description provided for @badgeDescStreak.
  ///
  /// In tr, this message translates to:
  /// **'Üst üste {n} gün boyunca kayıt gir.'**
  String badgeDescStreak(int n);

  /// No description provided for @badgeDescNightWatch.
  ///
  /// In tr, this message translates to:
  /// **'Gece 00:00 - 05:00 arasında {n} izleme yap.'**
  String badgeDescNightWatch(int n);

  /// No description provided for @badgeDescEarlyWatch.
  ///
  /// In tr, this message translates to:
  /// **'Sabah 06:00 - 09:00 arasında {n} izleme yap.'**
  String badgeDescEarlyWatch(int n);

  /// No description provided for @badgeDescSunday.
  ///
  /// In tr, this message translates to:
  /// **'Pazar günleri {n} film/dizi izle.'**
  String badgeDescSunday(int n);

  /// No description provided for @badgeDescSingleDay.
  ///
  /// In tr, this message translates to:
  /// **'Tek günde en az {n} film/dizi izle.'**
  String badgeDescSingleDay(int n);

  /// No description provided for @badgeDescWinter.
  ///
  /// In tr, this message translates to:
  /// **'Kış aylarında {n} yapım izle.'**
  String badgeDescWinter(int n);

  /// No description provided for @badgeDescRetro.
  ///
  /// In tr, this message translates to:
  /// **'1980 öncesi çekilmiş {n} film izle.'**
  String badgeDescRetro(int n);

  /// Director names are proper nouns and stay as they are.
  ///
  /// In tr, this message translates to:
  /// **'{n} {director} filmi izle.'**
  String badgeDescDirector(int n, String director);

  /// No description provided for @badgeDescWestern.
  ///
  /// In tr, this message translates to:
  /// **'{n} Western filmi izle.'**
  String badgeDescWestern(int n);

  /// No description provided for @badgeDescScifi.
  ///
  /// In tr, this message translates to:
  /// **'{n} Bilim Kurgu yapımı izle.'**
  String badgeDescScifi(int n);

  /// No description provided for @badgeDescHorror.
  ///
  /// In tr, this message translates to:
  /// **'{n} Korku/Gerilim yapımı izle.'**
  String badgeDescHorror(int n);

  /// No description provided for @badgeDescDrama.
  ///
  /// In tr, this message translates to:
  /// **'{n} Drama yapımı izle.'**
  String badgeDescDrama(int n);

  /// No description provided for @badgeDescCrime.
  ///
  /// In tr, this message translates to:
  /// **'{n} Suç veya Gizem yapımı izle.'**
  String badgeDescCrime(int n);

  /// No description provided for @badgeDescAnimation.
  ///
  /// In tr, this message translates to:
  /// **'{n} Animasyon yapımı izle.'**
  String badgeDescAnimation(int n);

  /// No description provided for @badgeDescTurkish.
  ///
  /// In tr, this message translates to:
  /// **'{n} Türk yapımı izle.'**
  String badgeDescTurkish(int n);

  /// No description provided for @badgeDescNotes.
  ///
  /// In tr, this message translates to:
  /// **'{n} filme kişisel not yaz.'**
  String badgeDescNotes(int n);

  /// No description provided for @badgeDescPerfectScore.
  ///
  /// In tr, this message translates to:
  /// **'{n} yapıma 10/10 tam puan ver.'**
  String badgeDescPerfectScore(int n);

  /// No description provided for @badgeDescLowScore.
  ///
  /// In tr, this message translates to:
  /// **'{n} yapıma 5.0 altı puan ver.'**
  String badgeDescLowScore(int n);

  /// No description provided for @badgeDescRewatchNth.
  ///
  /// In tr, this message translates to:
  /// **'Aynı içeriği {n}. kez izle.'**
  String badgeDescRewatchNth(int n);

  /// No description provided for @badgeDescRewatchTimes.
  ///
  /// In tr, this message translates to:
  /// **'Aynı içeriği {n} kez tekrar izle.'**
  String badgeDescRewatchTimes(int n);

  /// No description provided for @badgeDescRewatchRecords.
  ///
  /// In tr, this message translates to:
  /// **'{n} tekrar izleme kaydı yap.'**
  String badgeDescRewatchRecords(int n);

  /// No description provided for @badgeDescTags.
  ///
  /// In tr, this message translates to:
  /// **'{n} farklı kişisel etiket kullan.'**
  String badgeDescTags(int n);

  /// No description provided for @badgeDescEpisodes.
  ///
  /// In tr, this message translates to:
  /// **'{n} dizi bölümü izle.'**
  String badgeDescEpisodes(int n);

  /// No description provided for @badgeDescSeasons.
  ///
  /// In tr, this message translates to:
  /// **'{n} dizinin tüm sezonunu tamamla.'**
  String badgeDescSeasons(int n);

  /// No description provided for @timeJustNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} dk önce'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} sa önce'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün önce'**
  String timeDaysAgo(int n);

  /// No description provided for @communityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk Akışı'**
  String get communityTitle;

  /// No description provided for @communityFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get communityFilterAll;

  /// No description provided for @communityFilterFollowing.
  ///
  /// In tr, this message translates to:
  /// **'Takip Ettiklerim'**
  String get communityFilterFollowing;

  /// No description provided for @communityComposeHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler paylaş...'**
  String get communityComposeHint;

  /// No description provided for @communityFeedLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Akış yüklenemedi. Lütfen tekrar deneyin.'**
  String get communityFeedLoadFailed;

  /// No description provided for @communityEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir gönderi yok'**
  String get communityEmptyTitle;

  /// No description provided for @communityEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım kutusunu kullanarak ilk gönderini oluştur!'**
  String get communityEmptyHint;

  /// No description provided for @communityNotFollowingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kimseyi takip etmiyorsunuz'**
  String get communityNotFollowingTitle;

  /// No description provided for @communityNotFollowingHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kişiler keşfedin'**
  String get communityNotFollowingHint;

  /// No description provided for @communityFollowingEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Takip ettikleriniz henüz paylaşım yapmadı'**
  String get communityFollowingEmpty;

  /// No description provided for @communitySignInToLike.
  ///
  /// In tr, this message translates to:
  /// **'Beğenmek için lütfen giriş yapın.'**
  String get communitySignInToLike;

  /// No description provided for @communityPostMood.
  ///
  /// In tr, this message translates to:
  /// **'Mod: {mood}'**
  String communityPostMood(String mood);

  /// No description provided for @communityPostLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi yüklenemedi.'**
  String get communityPostLoadFailed;

  /// No description provided for @communityShowLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get communityShowLabel;

  /// No description provided for @userSearchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Ara'**
  String get userSearchTitle;

  /// No description provided for @userSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adına göre ara...'**
  String get userSearchHint;

  /// No description provided for @userSearchPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adına göre arama yapın.'**
  String get userSearchPrompt;

  /// No description provided for @userSearchNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Bulunamadı'**
  String get userSearchNotFound;

  /// No description provided for @userSearchFailed.
  ///
  /// In tr, this message translates to:
  /// **'Arama tamamlanamadı. Lütfen tekrar deneyin.'**
  String get userSearchFailed;

  /// No description provided for @userUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Kullanıcı'**
  String get userUnknown;

  /// No description provided for @followFollow.
  ///
  /// In tr, this message translates to:
  /// **'Takip Et'**
  String get followFollow;

  /// No description provided for @followUnfollow.
  ///
  /// In tr, this message translates to:
  /// **'Takibi Bırak'**
  String get followUnfollow;

  /// No description provided for @followFailed.
  ///
  /// In tr, this message translates to:
  /// **'Takip durumu güncellenemedi. Lütfen tekrar deneyin.'**
  String get followFailed;

  /// No description provided for @cineTwinSeeMatch.
  ///
  /// In tr, this message translates to:
  /// **'CineTwin Uyumunu Gör'**
  String get cineTwinSeeMatch;

  /// No description provided for @commentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get commentsTitle;

  /// No description provided for @commentsTitleWithCount.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar ({count})'**
  String commentsTitleWithCount(int count);

  /// No description provided for @commentsLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar yüklenemedi.'**
  String get commentsLoadFailed;

  /// No description provided for @commentsEmpty.
  ///
  /// In tr, this message translates to:
  /// **'İlk yorumu sen yaz!'**
  String get commentsEmpty;

  /// No description provided for @commentsHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz...'**
  String get commentsHint;

  /// No description provided for @commentsSignInHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yazmak için giriş yapın'**
  String get commentsSignInHint;

  /// No description provided for @commentsDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorumu Sil?'**
  String get commentsDeleteTitle;

  /// No description provided for @commentsDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu yorumu silmek istediğinize emin misiniz?'**
  String get commentsDeleteConfirm;

  /// No description provided for @shareOptionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne Paylaşmak İstersin?'**
  String get shareOptionsTitle;

  /// No description provided for @shareMovieTitle.
  ///
  /// In tr, this message translates to:
  /// **'Film Paylaş'**
  String get shareMovieTitle;

  /// No description provided for @shareMovieSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin tek bir film veya diziyi paylaş.'**
  String get shareMovieSubtitle;

  /// No description provided for @shareDiaryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğünü Paylaş'**
  String get shareDiaryTitle;

  /// No description provided for @shareDiarySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşacağın kayıtları toplu olarak seç.'**
  String get shareDiarySubtitle;

  /// No description provided for @shareCollectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon Paylaş'**
  String get shareCollectionTitle;

  /// No description provided for @shareCollectionSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyonunu canlı olarak paylaş.'**
  String get shareCollectionSubtitle;

  /// No description provided for @shareCollectionWebUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu özellik web\'de kullanılamıyor.'**
  String get shareCollectionWebUnavailable;

  /// No description provided for @shareCollectionPickPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukla paylaşmak istediğin koleksiyonu seç.'**
  String get shareCollectionPickPrompt;

  /// No description provided for @shareCollectionNone.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir koleksiyonun yok.'**
  String get shareCollectionNone;

  /// No description provided for @shareMoviePickPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukla paylaşmak istediğin bir film/dizi seç.'**
  String get shareMoviePickPrompt;

  /// No description provided for @shareDiaryPickPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderide paylaşmak istediğin kayıtları işaretle.'**
  String get shareDiaryPickPrompt;

  /// No description provided for @shareNoRecords.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir izleme kaydın yok.'**
  String get shareNoRecords;

  /// No description provided for @shareContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get shareContinue;

  /// No description provided for @shareSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get shareSubmit;

  /// No description provided for @shareComposeMovieHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu film hakkında ne düşünüyorsun?'**
  String get shareComposeMovieHint;

  /// No description provided for @shareComposeDiaryHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu günlük hakkında bir şeyler yaz...'**
  String get shareComposeDiaryHint;

  /// No description provided for @shareComposeCollectionHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu koleksiyon hakkında bir şeyler yaz...'**
  String get shareComposeCollectionHint;

  /// No description provided for @shareSignInRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen önce giriş yapın.'**
  String get shareSignInRequired;

  /// No description provided for @shareSucceeded.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşıldı.'**
  String get shareSucceeded;

  /// No description provided for @shareFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılamadı. Lütfen tekrar deneyin.'**
  String get shareFailed;

  /// No description provided for @sharedCollectionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon'**
  String get sharedCollectionTitle;

  /// No description provided for @sharedCollectionUnshared.
  ///
  /// In tr, this message translates to:
  /// **'Bu koleksiyon artık paylaşılmıyor'**
  String get sharedCollectionUnshared;

  /// No description provided for @sharedCollectionEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu koleksiyonda henüz film yok.'**
  String get sharedCollectionEmpty;

  /// No description provided for @sharedCollectionLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Koleksiyon yüklenemedi.'**
  String get sharedCollectionLoadFailed;

  /// No description provided for @publicDiaryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılmış bir kayıt yok.'**
  String get publicDiaryEmpty;

  /// No description provided for @userSearchNoMatch.
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" ile eşleşen bir kullanıcı yok.'**
  String userSearchNoMatch(String query);

  /// No description provided for @userFollowerCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} takipçi'**
  String userFollowerCount(int count);

  /// No description provided for @communityDiaryEntriesLink.
  ///
  /// In tr, this message translates to:
  /// **'{count} film/dizi · Günlüğü gör'**
  String communityDiaryEntriesLink(int count);

  /// No description provided for @shareEntriesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kayıt paylaşılacak'**
  String shareEntriesCount(int count);

  /// No description provided for @graphTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlişki Ağı'**
  String get graphTitle;

  /// No description provided for @graphLoading.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar analiz ediliyor…'**
  String get graphLoading;

  /// No description provided for @graphLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılar yüklenemedi. İnternet bağlantını kontrol edip tekrar dene.'**
  String get graphLoadFailed;

  /// No description provided for @graphEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlişki Ağı henüz boş'**
  String get graphEmptyTitle;

  /// No description provided for @graphEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Ortak oyuncu veya yönetmeni olan en az iki yapımı günlüğüne ekleyince, aralarındaki gizli bağlantılar burada otomatik olarak belirmeye başlar.'**
  String get graphEmptyBody;

  /// No description provided for @graphNoPathFound.
  ///
  /// In tr, this message translates to:
  /// **'Seçilen iki öğe arasında bağlantı bulunamadı.'**
  String get graphNoPathFound;

  /// No description provided for @graphPositionsReset.
  ///
  /// In tr, this message translates to:
  /// **'Düğüm konumları otomatik dizilime sıfırlandı.'**
  String get graphPositionsReset;

  /// No description provided for @graphProfileLookupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil aranırken bir hata oluştu.'**
  String get graphProfileLookupFailed;

  /// No description provided for @graphClusterUnconnected.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantısız'**
  String get graphClusterUnconnected;

  /// No description provided for @graphNodeMovie.
  ///
  /// In tr, this message translates to:
  /// **'Film'**
  String get graphNodeMovie;

  /// No description provided for @graphNodeShow.
  ///
  /// In tr, this message translates to:
  /// **'Dizi'**
  String get graphNodeShow;

  /// No description provided for @graphNodeActor.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get graphNodeActor;

  /// No description provided for @graphNodeDirector.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen'**
  String get graphNodeDirector;

  /// No description provided for @graphNodeWriter.
  ///
  /// In tr, this message translates to:
  /// **'Senarist'**
  String get graphNodeWriter;

  /// No description provided for @graphNodeProducer.
  ///
  /// In tr, this message translates to:
  /// **'Yapımcı'**
  String get graphNodeProducer;

  /// No description provided for @graphNodeCompany.
  ///
  /// In tr, this message translates to:
  /// **'Yapım Şirketi'**
  String get graphNodeCompany;

  /// No description provided for @graphNodeGenre.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get graphNodeGenre;

  /// No description provided for @graphFilterActors.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncular'**
  String get graphFilterActors;

  /// No description provided for @graphFilterDirectors.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmenler'**
  String get graphFilterDirectors;

  /// No description provided for @graphDepthLeads.
  ///
  /// In tr, this message translates to:
  /// **'Başroller'**
  String get graphDepthLeads;

  /// No description provided for @graphDepthFeatured.
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkanlar'**
  String get graphDepthFeatured;

  /// No description provided for @graphDepthFullCast.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kadro'**
  String get graphDepthFullCast;

  /// No description provided for @graphCastDepth.
  ///
  /// In tr, this message translates to:
  /// **'Kadro derinliği'**
  String get graphCastDepth;

  /// No description provided for @graphSearch.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get graphSearch;

  /// No description provided for @graphSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara…'**
  String get graphSearchHint;

  /// No description provided for @graphSearchInGraphHint.
  ///
  /// In tr, this message translates to:
  /// **'Graf içerisinde ara…'**
  String get graphSearchInGraphHint;

  /// No description provided for @graphFindConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı bul'**
  String get graphFindConnection;

  /// No description provided for @graphResetPositions.
  ///
  /// In tr, this message translates to:
  /// **'Konumları sıfırla'**
  String get graphResetPositions;

  /// No description provided for @graphFitToScreen.
  ///
  /// In tr, this message translates to:
  /// **'Ekrana sığdır'**
  String get graphFitToScreen;

  /// No description provided for @graphAddPerson.
  ///
  /// In tr, this message translates to:
  /// **'Kişi Ekle'**
  String get graphAddPerson;

  /// No description provided for @graphAddPersonHint.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu / yönetmen adı…'**
  String get graphAddPersonHint;

  /// No description provided for @graphAddPersonRole.
  ///
  /// In tr, this message translates to:
  /// **'Rol:'**
  String get graphAddPersonRole;

  /// No description provided for @graphAddPersonSearchPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Aramak için yazmaya başla.'**
  String get graphAddPersonSearchPrompt;

  /// No description provided for @graphHideFromGraph.
  ///
  /// In tr, this message translates to:
  /// **'Grafta Gizle'**
  String get graphHideFromGraph;

  /// No description provided for @graphOpenDetail.
  ///
  /// In tr, this message translates to:
  /// **'Detaya git'**
  String get graphOpenDetail;

  /// No description provided for @graphOpenProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili aç'**
  String get graphOpenProfile;

  /// No description provided for @graphWhyConnected.
  ///
  /// In tr, this message translates to:
  /// **'Neden bağlı?'**
  String get graphWhyConnected;

  /// No description provided for @graphWhyConnectedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neden Bağlı?'**
  String get graphWhyConnectedTitle;

  /// No description provided for @graphRemoveConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bu bağlantıyı kaldır'**
  String get graphRemoveConnection;

  /// No description provided for @graphDiscoverRecommendations.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet (Öneriler)'**
  String get graphDiscoverRecommendations;

  /// No description provided for @graphInsightsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İçgörüler'**
  String get graphInsightsTitle;

  /// No description provided for @graphInsightMostCentral.
  ///
  /// In tr, this message translates to:
  /// **'En merkezi: {name} ({count} yapım)'**
  String graphInsightMostCentral(String name, int count);

  /// No description provided for @pathFinderTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Yolunu Bul'**
  String get pathFinderTitle;

  /// No description provided for @pathFinderHeader.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Köprüsü Bul (6 Derece)'**
  String get pathFinderHeader;

  /// No description provided for @pathFinderExplain.
  ///
  /// In tr, this message translates to:
  /// **'Seçeceğin iki yapım veya kişi arasındaki en kısa ortak oyuncu/yönetmen zincirini bulur.'**
  String get pathFinderExplain;

  /// No description provided for @discoverRecommendationsFailed.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler yüklenemedi.'**
  String get discoverRecommendationsFailed;

  /// No description provided for @discoverSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin yapımlar ve kaçırmaman gereken öneriler'**
  String get discoverSubtitle;

  /// No description provided for @discoverWatchedCount.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanendeki Yapımlar ({count})'**
  String discoverWatchedCount(int count);

  /// No description provided for @discoverAllWatched.
  ///
  /// In tr, this message translates to:
  /// **'Bu oyuncunun öne çıkan diğer tüm ana projelerini zaten izlemişsin! Bravo! 🎉'**
  String get discoverAllWatched;

  /// No description provided for @cineDnaTitle.
  ///
  /// In tr, this message translates to:
  /// **'CineDNA Analitiği'**
  String get cineDnaTitle;

  /// No description provided for @cineDnaAnchorSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanendeki {count} farklı yapımı birbirine bağlıyor.'**
  String cineDnaAnchorSubtitle(int count);

  /// No description provided for @cineDnaPersonaAuteurTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen Odaklı'**
  String get cineDnaPersonaAuteurTitle;

  /// No description provided for @cineDnaPersonaAuteurDescription.
  ///
  /// In tr, this message translates to:
  /// **'Favori yönetmenlerinin tüm filmografisini eksiksiz takip ediyorsun.'**
  String get cineDnaPersonaAuteurDescription;

  /// No description provided for @cineDnaPersonaActorHunterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Takipçisi'**
  String get cineDnaPersonaActorHunterTitle;

  /// No description provided for @cineDnaPersonaActorHunterDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sevdiğin oyuncuların izini sürerek yeni yapımlara yelken açıyorsun.'**
  String get cineDnaPersonaActorHunterDescription;

  /// No description provided for @cineDnaPersonaFranchiseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Evren Kaşifi'**
  String get cineDnaPersonaFranchiseTitle;

  /// No description provided for @cineDnaPersonaFranchiseDescription.
  ///
  /// In tr, this message translates to:
  /// **'Devam yapımları ve sinematik evrenleri eksiksiz tamamlıyorsun.'**
  String get cineDnaPersonaFranchiseDescription;

  /// No description provided for @cineDnaPersonaCriticTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seçici Eleştirmen'**
  String get cineDnaPersonaCriticTitle;

  /// No description provided for @cineDnaPersonaCriticDescription.
  ///
  /// In tr, this message translates to:
  /// **'Puan ortalaman çok yüksek; sadece en kaliteli yapımları kütüphanene alıyorsun.'**
  String get cineDnaPersonaCriticDescription;

  /// No description provided for @cineTwinTitle.
  ///
  /// In tr, this message translates to:
  /// **'CineTwin Uyum Analizi'**
  String get cineTwinTitle;

  /// No description provided for @cineTwinYou.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get cineTwinYou;

  /// No description provided for @cineTwinMatchLabel.
  ///
  /// In tr, this message translates to:
  /// **'UYUM'**
  String get cineTwinMatchLabel;

  /// No description provided for @cineTwinNotEnoughData.
  ///
  /// In tr, this message translates to:
  /// **'Uyum hesabı için henüz yeterli izleme verisi bulunmuyor.'**
  String get cineTwinNotEnoughData;

  /// No description provided for @cineTwinSwipeTasteIncluded.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılan kaydırma zevki uyum hesabına dahil edildi.'**
  String get cineTwinSwipeTasteIncluded;

  /// No description provided for @cineTwinSharedTitles.
  ///
  /// In tr, this message translates to:
  /// **'Ortak Film'**
  String get cineTwinSharedTitles;

  /// No description provided for @cineTwinRatingGap.
  ///
  /// In tr, this message translates to:
  /// **'Farklı Puan'**
  String get cineTwinRatingGap;

  /// No description provided for @cineTwinSharedRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Ortak Öneri'**
  String get cineTwinSharedRecommendation;

  /// No description provided for @cineTwinShareCard.
  ///
  /// In tr, this message translates to:
  /// **'Uyum Kartını Paylaş'**
  String get cineTwinShareCard;

  /// No description provided for @cineTwinWhatToWatch.
  ///
  /// In tr, this message translates to:
  /// **'Bu Akşam Birlikte Ne İzlemelisiniz?'**
  String get cineTwinWhatToWatch;

  /// No description provided for @cineTwinCopied.
  ///
  /// In tr, this message translates to:
  /// **'CineTwin Uyum Skoru (%{percentage}) panoya kopyalandı!'**
  String cineTwinCopied(int percentage);

  /// No description provided for @cineTwinBadgeSoulmatesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sinematik Ruh İkizi'**
  String get cineTwinBadgeSoulmatesTitle;

  /// No description provided for @cineTwinBadgeSoulmatesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Film zevkleriniz ve puanlarınız neredeyse %100 birebir örtüşüyor!'**
  String get cineTwinBadgeSoulmatesDescription;

  /// No description provided for @cineTwinBadgeBuddiesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Bilet Ortağı'**
  String get cineTwinBadgeBuddiesTitle;

  /// No description provided for @cineTwinBadgeBuddiesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Birlikte harika film akşamları yapabileceğiniz yüksek uyum.'**
  String get cineTwinBadgeBuddiesDescription;

  /// No description provided for @cineTwinBadgeGenreMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tür Kardeşi'**
  String get cineTwinBadgeGenreMatchTitle;

  /// No description provided for @cineTwinBadgeGenreMatchDescription.
  ///
  /// In tr, this message translates to:
  /// **'Benzer türdeki yapımlardan hoşlanıyorsunuz.'**
  String get cineTwinBadgeGenreMatchDescription;

  /// No description provided for @cineTwinBadgeComplementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Karşıt Zevkler'**
  String get cineTwinBadgeComplementsTitle;

  /// No description provided for @cineTwinBadgeComplementsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Birbirinizi farklı film türleriyle besleyen harika bir denge.'**
  String get cineTwinBadgeComplementsDescription;

  /// No description provided for @cineTwinBadgeOppositesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Farklı Dünyaların İnsanları'**
  String get cineTwinBadgeOppositesTitle;

  /// No description provided for @cineTwinBadgeOppositesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Zevkleriniz çok farklı veya henüz yeterli ortak veri yok.'**
  String get cineTwinBadgeOppositesDescription;

  /// No description provided for @cineTwinReasonRated.
  ///
  /// In tr, this message translates to:
  /// **'{name} bu filme {rating} puan verdi'**
  String cineTwinReasonRated(String name, String rating);

  /// No description provided for @cineTwinReasonRatedHighly.
  ///
  /// In tr, this message translates to:
  /// **'{name} bu filme yüksek puan verdi'**
  String cineTwinReasonRatedHighly(String name);

  /// No description provided for @graphClusterNamed.
  ///
  /// In tr, this message translates to:
  /// **'{name} kümesi'**
  String graphClusterNamed(String name);

  /// No description provided for @graphPathFound.
  ///
  /// In tr, this message translates to:
  /// **'{steps} Adımda Bağlantı Bulundu'**
  String graphPathFound(int steps);

  /// No description provided for @graphSearchingProfile.
  ///
  /// In tr, this message translates to:
  /// **'{name} profili aranıyor…'**
  String graphSearchingProfile(String name);

  /// No description provided for @graphProfileNotFound.
  ///
  /// In tr, this message translates to:
  /// **'{name} için profil bulunamadı.'**
  String graphProfileNotFound(String name);

  /// No description provided for @graphSummary.
  ///
  /// In tr, this message translates to:
  /// **'{titles} yapım · {people} köprü'**
  String graphSummary(int titles, int people);

  /// No description provided for @graphInsightBiggestCluster.
  ///
  /// In tr, this message translates to:
  /// **' · en büyük: {name}'**
  String graphInsightBiggestCluster(String name);

  /// No description provided for @graphInsightStrongestPair.
  ///
  /// In tr, this message translates to:
  /// **'En bağlı: {a} ↔ {b} ({weight})'**
  String graphInsightStrongestPair(String a, String b, int weight);

  /// No description provided for @graphConnectedByPeople.
  ///
  /// In tr, this message translates to:
  /// **'{count} ortak kişi ile bağlı'**
  String graphConnectedByPeople(int count);

  /// No description provided for @graphConnectsTitles.
  ///
  /// In tr, this message translates to:
  /// **'{count} yapımı birbirine bağlıyor'**
  String graphConnectsTitles(int count);

  /// No description provided for @graphSharedPeopleCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} ortak kişi'**
  String graphSharedPeopleCount(int count);

  /// No description provided for @graphPersonAdded.
  ///
  /// In tr, this message translates to:
  /// **'{name}, \"{title}\" yapımına eklendi.'**
  String graphPersonAdded(String name, String title);

  /// No description provided for @graphAddPersonPrompt.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" yapımına bağlanacak kişiyi ara.'**
  String graphAddPersonPrompt(String title);

  /// No description provided for @graphExplainDirector.
  ///
  /// In tr, this message translates to:
  /// **'{person}, {title} projesine yönetmen koltuğunda imza atmıştır.'**
  String graphExplainDirector(String person, String title);

  /// No description provided for @graphExplainActor.
  ///
  /// In tr, this message translates to:
  /// **'{person}, {title} projesinin kadrosunda oyuncu olarak yer almaktadır.'**
  String graphExplainActor(String person, String title);

  /// No description provided for @pathFinderStart.
  ///
  /// In tr, this message translates to:
  /// **'1. Başlangıç (Yapım veya Kişi)'**
  String get pathFinderStart;

  /// No description provided for @pathFinderTarget.
  ///
  /// In tr, this message translates to:
  /// **'2. Hedef (Yapım veya Kişi)'**
  String get pathFinderTarget;

  /// No description provided for @discoverEngineTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} — Keşif Motoru'**
  String discoverEngineTitle(String name);

  /// No description provided for @discoverUnwatchedPopular.
  ///
  /// In tr, this message translates to:
  /// **'⭐ Henüz İzlemediğin Popüler Yapımları'**
  String get discoverUnwatchedPopular;

  /// No description provided for @cineDnaBackbone.
  ///
  /// In tr, this message translates to:
  /// **'👑 Kütüphanenin Omurgası'**
  String get cineDnaBackbone;

  /// No description provided for @cineDnaTotalTitles.
  ///
  /// In tr, this message translates to:
  /// **'🎬 Toplam Yapım'**
  String get cineDnaTotalTitles;

  /// No description provided for @cineDnaConnectionNetwork.
  ///
  /// In tr, this message translates to:
  /// **'🔗 Bağlantı Ağı'**
  String get cineDnaConnectionNetwork;

  /// No description provided for @cineDnaTopBridges.
  ///
  /// In tr, this message translates to:
  /// **'🌉 En Etkili Bağlantı Köprüleri'**
  String get cineDnaTopBridges;

  /// No description provided for @cineDnaConnectionCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Bağlantı'**
  String cineDnaConnectionCount(int count);

  /// No description provided for @cineTwinSharedFavorites.
  ///
  /// In tr, this message translates to:
  /// **'❤️ İkinizin de Sevdiği Yapımlar'**
  String get cineTwinSharedFavorites;

  /// No description provided for @cineTwinBigDisputes.
  ///
  /// In tr, this message translates to:
  /// **'⚡ Büyük Puan Ayrılıkları'**
  String get cineTwinBigDisputes;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navDiscover;

  /// No description provided for @navDiary.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get navDiary;

  /// No description provided for @navCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get navCommunity;

  /// No description provided for @navGraph.
  ///
  /// In tr, this message translates to:
  /// **'Ağ'**
  String get navGraph;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın, ☀️'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingDay.
  ///
  /// In tr, this message translates to:
  /// **'İyi Günler, 👋'**
  String get homeGreetingDay;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi Akşamlar, 🌙'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingNight.
  ///
  /// In tr, this message translates to:
  /// **'İyi Geceler, 🌌'**
  String get homeGreetingNight;

  /// No description provided for @homeRecentlyAdded.
  ///
  /// In tr, this message translates to:
  /// **'Son Eklediklerim'**
  String get homeRecentlyAdded;

  /// No description provided for @homeNothingAdded.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kütüphanene film eklemedin.'**
  String get homeNothingAdded;

  /// No description provided for @homeSeeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get homeSeeAll;

  /// No description provided for @homeHeroLastWatched.
  ///
  /// In tr, this message translates to:
  /// **'SON İZLEDİĞİN'**
  String get homeHeroLastWatched;

  /// No description provided for @homeHeroWhatToWatch.
  ///
  /// In tr, this message translates to:
  /// **'BU HAFTA NE İZLESEM?'**
  String get homeHeroWhatToWatch;

  /// No description provided for @homeHeroMovieBadge.
  ///
  /// In tr, this message translates to:
  /// **'FİLM'**
  String get homeHeroMovieBadge;

  /// No description provided for @homeHeroShowBadge.
  ///
  /// In tr, this message translates to:
  /// **'DİZİ'**
  String get homeHeroShowBadge;

  /// No description provided for @homeHeroDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detayları İncele'**
  String get homeHeroDetails;

  /// No description provided for @homeContinueWatching.
  ///
  /// In tr, this message translates to:
  /// **'İZLEMEYE DEVAM ET'**
  String get homeContinueWatching;

  /// No description provided for @homeContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get homeContinue;

  /// No description provided for @homeNextEpisode.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki: Bölüm {episode}'**
  String homeNextEpisode(int episode);

  /// No description provided for @homeNextEpisodeOf.
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki: Bölüm {episode} / {total}'**
  String homeNextEpisodeOf(int episode, int total);

  /// No description provided for @homeStatsHeader.
  ///
  /// In tr, this message translates to:
  /// **'ÖZET & İSTATİSTİKLER'**
  String get homeStatsHeader;

  /// No description provided for @homeStatsTotalWatches.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İzleme'**
  String get homeStatsTotalWatches;

  /// No description provided for @homeStatsTitlesUnit.
  ///
  /// In tr, this message translates to:
  /// **'yapım'**
  String get homeStatsTitlesUnit;

  /// No description provided for @homeStatsAverageRating.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Puan'**
  String get homeStatsAverageRating;

  /// No description provided for @homeStatsWeeklyGoal.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Hedef'**
  String get homeStatsWeeklyGoal;

  /// No description provided for @homeStatsWeeklyGoalCaps.
  ///
  /// In tr, this message translates to:
  /// **'HAFTALIK HEDEF'**
  String get homeStatsWeeklyGoalCaps;

  /// No description provided for @homeStatsGoalDoneCaps.
  ///
  /// In tr, this message translates to:
  /// **'HEDEF TAMAM'**
  String get homeStatsGoalDoneCaps;

  /// No description provided for @homeStatsAddFirst.
  ///
  /// In tr, this message translates to:
  /// **'İlk izlemeni kütüphanene ekle!'**
  String get homeStatsAddFirst;

  /// No description provided for @homeStatsGoalReached.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler, haftalık hedefine ulaştın! 🎉'**
  String get homeStatsGoalReached;

  /// No description provided for @homeStatsGoalRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta {count} film/dizi daha izlemelisin.'**
  String homeStatsGoalRemaining(int count);

  /// No description provided for @activelyWatchingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif İzlediklerin'**
  String get activelyWatchingTitle;

  /// No description provided for @homeStreakDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} Gün'**
  String homeStreakDays(int count);

  /// No description provided for @homeAddOneEpisode.
  ///
  /// In tr, this message translates to:
  /// **'+1 Bölüm'**
  String get homeAddOneEpisode;

  /// No description provided for @episodeOf.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {episode} / {total}'**
  String episodeOf(int episode, int total);

  /// No description provided for @episodeSingle.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {episode}'**
  String episodeSingle(int episode);

  /// No description provided for @datePickerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seçin'**
  String get datePickerTitle;

  /// No description provided for @commonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get commonConfirm;

  /// No description provided for @tierLocked.
  ///
  /// In tr, this message translates to:
  /// **'Kilitli'**
  String get tierLocked;

  /// No description provided for @tierBronze.
  ///
  /// In tr, this message translates to:
  /// **'Bronz'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In tr, this message translates to:
  /// **'Gümüş'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In tr, this message translates to:
  /// **'Platin'**
  String get tierPlatinum;

  /// No description provided for @badgeTierLevel.
  ///
  /// In tr, this message translates to:
  /// **'{symbol} {tier} (Seviye {current}/{max})'**
  String badgeTierLevel(String symbol, String tier, int current, int max);

  /// No description provided for @achievementsCategoryCount.
  ///
  /// In tr, this message translates to:
  /// **'{category} ({count})'**
  String achievementsCategoryCount(String category, int count);

  /// No description provided for @insightsEmptyBody.
  ///
  /// In tr, this message translates to:
  /// **'Grafiklerin ve istatistiklerin oluşturulabilmesi için günlüğünüze en az 1 adet izleme kaydı eklemelisiniz.'**
  String get insightsEmptyBody;

  /// No description provided for @achievementsShowing.
  ///
  /// In tr, this message translates to:
  /// **'{count} Başarım Gösteriliyor'**
  String achievementsShowing(int count);

  /// No description provided for @badgeLockedLabel.
  ///
  /// In tr, this message translates to:
  /// **'🔒 Kilitli'**
  String get badgeLockedLabel;

  /// No description provided for @badgeCurrentCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Yapım'**
  String badgeCurrentCount(int count);

  /// No description provided for @badgeNextTier.
  ///
  /// In tr, this message translates to:
  /// **'{remaining} yapım daha ➔ \"{tier}\" seviyesine yüksel!'**
  String badgeNextTier(int remaining, String tier);

  /// No description provided for @badgeCopied.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" başarımı panoya kopyalandı! Sosyal medyada paylaşabilirsiniz.'**
  String badgeCopied(String title);

  /// No description provided for @heatmapYearTotal.
  ///
  /// In tr, this message translates to:
  /// **'{year} içinde {count} İzleme'**
  String heatmapYearTotal(int year, int count);

  /// No description provided for @heatmapEpisodesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Dizi Bölümü'**
  String heatmapEpisodesCount(int count);

  /// No description provided for @insightsBadgesTitle.
  ///
  /// In tr, this message translates to:
  /// **'🏆 Başarılar & Rozetler'**
  String get insightsBadgesTitle;

  /// No description provided for @insightsBadgesEarned.
  ///
  /// In tr, this message translates to:
  /// **'{unlocked} / {total} Kazanıldı'**
  String insightsBadgesEarned(int unlocked, int total);

  /// No description provided for @insightsTopTagsTitle.
  ///
  /// In tr, this message translates to:
  /// **'🏷️ En Sık Kullanılan Etiketler'**
  String get insightsTopTagsTitle;

  /// No description provided for @insightsDistinctTags.
  ///
  /// In tr, this message translates to:
  /// **'{count} Farklı Etiket'**
  String insightsDistinctTags(int count);

  /// No description provided for @insightsWatchesWithPercent.
  ///
  /// In tr, this message translates to:
  /// **'{count} İzleme ({percent}%)'**
  String insightsWatchesWithPercent(int count, String percent);

  /// No description provided for @insightsSeasonalTitle.
  ///
  /// In tr, this message translates to:
  /// **'📅 Mevsimsel Dağılım'**
  String get insightsSeasonalTitle;

  /// No description provided for @insightsSeasonWinterLong.
  ///
  /// In tr, this message translates to:
  /// **'❄️ Kış (Ara-Oca-Şub)'**
  String get insightsSeasonWinterLong;

  /// No description provided for @insightsSeasonSpringLong.
  ///
  /// In tr, this message translates to:
  /// **'🌱 İlkbahar (Mar-Nis-May)'**
  String get insightsSeasonSpringLong;

  /// No description provided for @insightsSeasonSummerLong.
  ///
  /// In tr, this message translates to:
  /// **'☀️ Yaz (Haz-Tem-Ağu)'**
  String get insightsSeasonSummerLong;

  /// No description provided for @insightsSeasonAutumnLong.
  ///
  /// In tr, this message translates to:
  /// **'🍂 Sonbahar (Eyl-Eki-Kas)'**
  String get insightsSeasonAutumnLong;

  /// No description provided for @weeklyGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'🎯 Haftalık İzleme Hedefi'**
  String get weeklyGoalTitle;

  /// No description provided for @weeklyGoalProgress.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta {count} film/dizi izlediniz. (Hedef: {goal})'**
  String weeklyGoalProgress(int count, int goal);

  /// No description provided for @weeklyGoalItemsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} İçerik'**
  String weeklyGoalItemsCount(int count);

  /// No description provided for @timeVisualizerTitle.
  ///
  /// In tr, this message translates to:
  /// **'🍿 Bu Sürede Neler Yapabilirdin?'**
  String get timeVisualizerTitle;

  /// No description provided for @timeVisualizerFooter.
  ///
  /// In tr, this message translates to:
  /// **'Ama film/dizi izlemek de harika bir tercih! 🎬'**
  String get timeVisualizerFooter;

  /// No description provided for @timeCompareLotr.
  ///
  /// In tr, this message translates to:
  /// **'Yüzüklerin Efendisi (Uzatılmış Versiyon) Üçlemesi\'ni aralıksız {n} kez baştan sona izleyebilirdin!'**
  String timeCompareLotr(String n);

  /// No description provided for @timeCompareFlight.
  ///
  /// In tr, this message translates to:
  /// **'İstanbul - Londra arası uçakla tam {n} kez gidiş-dönüş seyahat edebilirdin!'**
  String timeCompareFlight(String n);

  /// No description provided for @timeCompareBreakingBad.
  ///
  /// In tr, this message translates to:
  /// **'Kült dizi Breaking Bad\'i baştan sona tam {n} kez maraton yapabilirdin!'**
  String timeCompareBreakingBad(String n);

  /// No description provided for @timeCompareWalk.
  ///
  /// In tr, this message translates to:
  /// **'Hiç durmadan yürüyerek İstanbul\'dan Ankara\'ya tam {n} kez gidip gelebilirdin!'**
  String timeCompareWalk(String n);

  /// No description provided for @timeCompareBooks.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama 8 saatlik okuma süresiyle tam {n} adet kitap bitirebilirdin!'**
  String timeCompareBooks(String n);

  /// No description provided for @timeCompareFood.
  ///
  /// In tr, this message translates to:
  /// **'Arka arkaya hiç durmadan tam {n} lahmacun yiyebilirdin! (Afiyet olsun)'**
  String timeCompareFood(String n);

  /// No description provided for @timeCompareIss.
  ///
  /// In tr, this message translates to:
  /// **'Uluslararası Uzay İstasyonu (ISS) Dünya\'nın etrafında tam {n} tur atardı!'**
  String timeCompareIss(String n);

  /// No description provided for @timeCompareLight.
  ///
  /// In tr, this message translates to:
  /// **'Bu sürede ışık uzay boşluğunda tam {n} milyon kilometre yol alırdı!'**
  String timeCompareLight(String n);

  /// No description provided for @timeCompareMinecraft.
  ///
  /// In tr, this message translates to:
  /// **'Minecraft\'ta hiç durmadan tam {n} blok yerleştirebilirdin!'**
  String timeCompareMinecraft(String n);

  /// No description provided for @timeCompareCoffee.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarınla sohbet edip tam {n} fincan kahve içebilirdin!'**
  String timeCompareCoffee(String n);

  /// No description provided for @timeCompareMusic.
  ///
  /// In tr, this message translates to:
  /// **'Spotify\'da favori çalma listenden tam {n} şarkı dinleyebilirdin!'**
  String timeCompareMusic(String n);

  /// No description provided for @timeCompareMonopoly.
  ///
  /// In tr, this message translates to:
  /// **'Hiç bitmeyecekmiş gibi hissettiren tam {n} Monopoly partisi yapabilirdin!'**
  String timeCompareMonopoly(String n);

  /// No description provided for @timeCompareSleep.
  ///
  /// In tr, this message translates to:
  /// **'Deliksiz ve huzurlu bir şekilde tam {n} gece uykusu çekebilirdin!'**
  String timeCompareSleep(String n);

  /// No description provided for @timeCompareHair.
  ///
  /// In tr, this message translates to:
  /// **'Bu sürede saç tellerin toplamda tam {n} milimetre uzardı!'**
  String timeCompareHair(String n);

  /// No description provided for @timeCompareCells.
  ///
  /// In tr, this message translates to:
  /// **'Vücudun sen ekran karşısındayken tam {n} milyon yeni hücre üretti!'**
  String timeCompareCells(String n);

  /// No description provided for @timeCompareOrbit.
  ///
  /// In tr, this message translates to:
  /// **'Dünya güneşin etrafındaki yörüngesinde tam {n} bin kilometre yol katetti!'**
  String timeCompareOrbit(String n);

  /// No description provided for @recordEpisodesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Bölüm'**
  String recordEpisodesCount(int count);

  /// No description provided for @recordYearDirector.
  ///
  /// In tr, this message translates to:
  /// **'{year} • {director}'**
  String recordYearDirector(String year, String director);

  /// No description provided for @yearUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Yıl'**
  String get yearUnknown;

  /// No description provided for @directorMissing.
  ///
  /// In tr, this message translates to:
  /// **'Yönetmen Yok'**
  String get directorMissing;

  /// No description provided for @watchNumber.
  ///
  /// In tr, this message translates to:
  /// **'{number}. İzleme'**
  String watchNumber(int number);

  /// No description provided for @journalMoviesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Film'**
  String journalMoviesCount(int count);

  /// No description provided for @durationDays.
  ///
  /// In tr, this message translates to:
  /// **'{days}g'**
  String durationDays(int days);

  /// No description provided for @durationHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours}s'**
  String durationHours(int hours);

  /// No description provided for @durationMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{minutes}dk'**
  String durationMinutes(int minutes);

  /// No description provided for @collectionTotalWatched.
  ///
  /// In tr, this message translates to:
  /// **'{total} Film • {watched} İzlenen'**
  String collectionTotalWatched(int total, int watched);

  /// No description provided for @collectionProgressPercent.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} İzlendi'**
  String collectionProgressPercent(int percent);

  /// No description provided for @collectionsEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Kendinize özel film listeleri oluşturarak (Örn: En İyi Nolan Filmleri, İzlenecek Animeler) sinema keyfinizi kişiselleştirebilirsiniz.'**
  String get collectionsEmptyHint;

  /// No description provided for @collectionDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu koleksiyonu silmek istediğinize emin misiniz? İçindeki filmler ve sıralamanız tamamen silinecektir. (Veritabanındaki filmleriniz kaybolmaz).'**
  String get collectionDeleteConfirm;

  /// No description provided for @marathonTitle.
  ///
  /// In tr, this message translates to:
  /// **'🏁 Maraton Mücadelesi'**
  String get marathonTitle;

  /// No description provided for @journalTotalTimeSpent.
  ///
  /// In tr, this message translates to:
  /// **'Bu listedeki filmleri izlemek için toplam {hours} Saat {minutes} Dakika harcadınız.'**
  String journalTotalTimeSpent(int hours, int minutes);

  /// No description provided for @addRecordSuccess.
  ///
  /// In tr, this message translates to:
  /// **'{title} günlüğünüze başarıyla eklendi!'**
  String addRecordSuccess(String title);

  /// No description provided for @rankDialogExplain.
  ///
  /// In tr, this message translates to:
  /// **'Bu film için favori sıralama numarasını girin (Örn: 1, 2, 5). Boş bırakırsanız sıralamadan çıkarılır.'**
  String get rankDialogExplain;

  /// No description provided for @castSearching.
  ///
  /// In tr, this message translates to:
  /// **'{name} profili aranıyor...'**
  String castSearching(String name);

  /// No description provided for @castNotFound.
  ///
  /// In tr, this message translates to:
  /// **'{name} için profil bulunamadı.'**
  String castNotFound(String name);

  /// No description provided for @episodeNumbered.
  ///
  /// In tr, this message translates to:
  /// **'{episode}. Bölüm'**
  String episodeNumbered(int episode);

  /// No description provided for @episodeUpNext.
  ///
  /// In tr, this message translates to:
  /// **'▶ SIRADAKİ'**
  String get episodeUpNext;

  /// No description provided for @episodeMarkedWatched.
  ///
  /// In tr, this message translates to:
  /// **'{episode}. Bölüm izlendi olarak işaretlendi.'**
  String episodeMarkedWatched(int episode);

  /// No description provided for @episodeMarkedUnwatched.
  ///
  /// In tr, this message translates to:
  /// **'{episode}. Bölüm izlenmedi olarak işaretlendi.'**
  String episodeMarkedUnwatched(int episode);

  /// No description provided for @episodeBulkWatchConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölümü izlendi olarak işaretlemek, önceki tüm bölümleri de ({from} - {to}) izlendi sayacaktır. Devam etmek istiyor musunuz?'**
  String episodeBulkWatchConfirm(int from, int to);

  /// No description provided for @episodeBulkUnwatchConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölümü izlenmedi olarak işaretlemek, sonraki tüm bölümleri de ({from} - {to}) izlenmedi sayacaktır. Devam etmek istiyor musunuz?'**
  String episodeBulkUnwatchConfirm(int from, int to);

  /// No description provided for @tagNostalgia.
  ///
  /// In tr, this message translates to:
  /// **'#nostalji'**
  String get tagNostalgia;

  /// No description provided for @tagAtTheCinema.
  ///
  /// In tr, this message translates to:
  /// **'#sinemada'**
  String get tagAtTheCinema;

  /// No description provided for @tagAlone.
  ///
  /// In tr, this message translates to:
  /// **'#yalnız'**
  String get tagAlone;

  /// No description provided for @tagAction.
  ///
  /// In tr, this message translates to:
  /// **'#aksiyon'**
  String get tagAction;

  /// No description provided for @tagRomance.
  ///
  /// In tr, this message translates to:
  /// **'#romantizm'**
  String get tagRomance;

  /// No description provided for @tagThriller.
  ///
  /// In tr, this message translates to:
  /// **'#gerilim'**
  String get tagThriller;

  /// No description provided for @tagComedy.
  ///
  /// In tr, this message translates to:
  /// **'#komedi'**
  String get tagComedy;

  /// No description provided for @tagDrama.
  ///
  /// In tr, this message translates to:
  /// **'#drama'**
  String get tagDrama;

  /// No description provided for @tagSciFi.
  ///
  /// In tr, this message translates to:
  /// **'#bilimkurgu'**
  String get tagSciFi;

  /// No description provided for @tagHorror.
  ///
  /// In tr, this message translates to:
  /// **'#korku'**
  String get tagHorror;

  /// No description provided for @tagClassic.
  ///
  /// In tr, this message translates to:
  /// **'#klasik'**
  String get tagClassic;

  /// No description provided for @tagNewDiscovery.
  ///
  /// In tr, this message translates to:
  /// **'#yenikesif'**
  String get tagNewDiscovery;

  /// No description provided for @notificationEpisodeBody.
  ///
  /// In tr, this message translates to:
  /// **'\"{show}\" dizisinin {season}. sezon {episode}. bölümü bugün yayınlanıyor.'**
  String notificationEpisodeBody(String show, int season, int episode);

  /// No description provided for @onboardingTitleWelcome.
  ///
  /// In tr, this message translates to:
  /// **'CineFile\'a Hoş Geldin'**
  String get onboardingTitleWelcome;

  /// No description provided for @onboardingSubtitleWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel izleme günlüğünü ve sinema zevkini yapılandırarak başla.'**
  String get onboardingSubtitleWelcome;

  /// No description provided for @onboardingStepPreferences.
  ///
  /// In tr, this message translates to:
  /// **'1. Tercihler'**
  String get onboardingStepPreferences;

  /// No description provided for @onboardingStepFavorites.
  ///
  /// In tr, this message translates to:
  /// **'2. İlk Favoriler'**
  String get onboardingStepFavorites;

  /// No description provided for @onboardingStepTour.
  ///
  /// In tr, this message translates to:
  /// **'3. Özellikler ve Gizlilik'**
  String get onboardingStepTour;

  /// No description provided for @onboardingNext.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingNext;

  /// No description provided for @onboardingSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get onboardingSkip;

  /// No description provided for @onboardingFinish.
  ///
  /// In tr, this message translates to:
  /// **'CineFile\'a Başla'**
  String get onboardingFinish;

  /// No description provided for @onboardingFavoritesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzlediğin veya sevdiğin birkaç yapımı arayarak favorilerine ekle.'**
  String get onboardingFavoritesSubtitle;

  /// No description provided for @onboardingFavoritesSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Film veya dizi ara...'**
  String get onboardingFavoritesSearchHint;

  /// No description provided for @onboardingFeature1Title.
  ///
  /// In tr, this message translates to:
  /// **'Çoklu İzleme ve Sezon Takibi'**
  String get onboardingFeature1Title;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Aynı filmi tekrar izlesen bile ayrı kaydet. Dizilerde kaldığın bölümü tek dokunuşla ilerlet.'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2Title.
  ///
  /// In tr, this message translates to:
  /// **'İçgörüler ve Rozetler'**
  String get onboardingFeature2Title;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In tr, this message translates to:
  /// **'GitHub tarzı izleme yoğunluğu haritanı, puan dağılımını ve en sevdiğin oyuncuları keşfet.'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3Title.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Önce Gelir'**
  String get onboardingFeature3Title;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In tr, this message translates to:
  /// **'İzleme kayıtların varsayılan olarak gizlidir. İstediğin zaman JSON olarak dışa aktar veya toplulukta paylaş.'**
  String get onboardingFeature3Desc;

  /// No description provided for @settingsRerunOnboarding.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Turunu Başlat'**
  String get settingsRerunOnboarding;

  /// No description provided for @journalAddFirstRecordCTA.
  ///
  /// In tr, this message translates to:
  /// **'İlk Kaydını Ekle'**
  String get journalAddFirstRecordCTA;

  /// No description provided for @journalClearFiltersCTA.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri Temizle'**
  String get journalClearFiltersCTA;

  /// No description provided for @collectionAddMoviesCTA.
  ///
  /// In tr, this message translates to:
  /// **'Film/Dizi Ekle'**
  String get collectionAddMoviesCTA;

  /// No description provided for @communityFollowingEmptyHint.
  ///
  /// In tr, this message translates to:
  /// **'Takip ettiğin kullanıcılar henüz izleme kaydı paylaşmadı. Yeni arkadaşlar keşfedebilirsin.'**
  String get communityFollowingEmptyHint;

  /// No description provided for @checklistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldin! Başlangıç Rehberi'**
  String get checklistTitle;

  /// No description provided for @checklistProgress.
  ///
  /// In tr, this message translates to:
  /// **'{completed}/{total} Tamamlandı'**
  String checklistProgress(int completed, int total);

  /// No description provided for @checklistStep1.
  ///
  /// In tr, this message translates to:
  /// **'İzleme bölgeni ve dilini belirle'**
  String get checklistStep1;

  /// No description provided for @checklistStep2.
  ///
  /// In tr, this message translates to:
  /// **'İlk film veya dizi kaydını ekle'**
  String get checklistStep2;

  /// No description provided for @checklistStep3.
  ///
  /// In tr, this message translates to:
  /// **'En sevdiğin yapımı favorilerine ekle'**
  String get checklistStep3;

  /// No description provided for @checklistStep4.
  ///
  /// In tr, this message translates to:
  /// **'İlk koleksiyonunu oluştur veya arkadaş edin'**
  String get checklistStep4;

  /// No description provided for @quickActionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı İşlemler'**
  String get quickActionTitle;

  /// No description provided for @quickActionAddRecord.
  ///
  /// In tr, this message translates to:
  /// **'İzleme Kaydı Ekle'**
  String get quickActionAddRecord;

  /// No description provided for @quickActionToggleFavorite.
  ///
  /// In tr, this message translates to:
  /// **'Favorilere Ekle / Çıkar'**
  String get quickActionToggleFavorite;

  /// No description provided for @quickActionViewDetail.
  ///
  /// In tr, this message translates to:
  /// **'Detayları Gör'**
  String get quickActionViewDetail;

  /// No description provided for @errorOfflineTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışısınız'**
  String get errorOfflineTitle;

  /// No description provided for @errorOfflineSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İzleme kayıtların cihazında güvende. İnternet bağlandığında toplulukla senkronize edilecek.'**
  String get errorOfflineSubtitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hata Oluştu'**
  String get errorGenericTitle;

  /// No description provided for @errorRetryCTA.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Deneyin'**
  String get errorRetryCTA;

  /// No description provided for @privacyCenterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Merkezi'**
  String get privacyCenterTitle;

  /// No description provided for @privacyCenterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinin nerede saklandığını ve nasıl yönetildiğini şeffafça gör.'**
  String get privacyCenterSubtitle;

  /// No description provided for @privacyLocalSection.
  ///
  /// In tr, this message translates to:
  /// **'Yerel Veriler (Cihaz İçi)'**
  String get privacyLocalSection;

  /// No description provided for @privacyLocalDesc.
  ///
  /// In tr, this message translates to:
  /// **'İzleme günlüğün, notların ve puanların cihazındaki yerel SQLite veritabanında saklanır. İnternet olmadan da erişilebilir.'**
  String get privacyLocalDesc;

  /// No description provided for @privacyCloudSection.
  ///
  /// In tr, this message translates to:
  /// **'Bulut Senkronizasyonu'**
  String get privacyCloudSection;

  /// No description provided for @privacyCloudDesc.
  ///
  /// In tr, this message translates to:
  /// **'Favori listelerin ve profil bilgilerin Firebase Firestore ile cihazların arasında güvenle senkronize edilir.'**
  String get privacyCloudDesc;

  /// No description provided for @privacyAnalyticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Anonim kullanım ölçümüne izin ver'**
  String get privacyAnalyticsTitle;

  /// No description provided for @privacyAnalyticsDesc.
  ///
  /// In tr, this message translates to:
  /// **'CineFile\'ı geliştirmemize yardımcı olan sınırlı ürün olaylarını gönderir. Film/dizi adı, arama, not, yorum veya kullanıcı kimliği gönderilmez. Varsayılan olarak kapalıdır.'**
  String get privacyAnalyticsDesc;

  /// No description provided for @privacyAnalyticsEnabled.
  ///
  /// In tr, this message translates to:
  /// **'Anonim kullanım ölçümü açıldı'**
  String get privacyAnalyticsEnabled;

  /// No description provided for @privacyAnalyticsDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Anonim kullanım ölçümü kapatıldı'**
  String get privacyAnalyticsDisabled;

  /// No description provided for @privacyPublicSection.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk ve Gizlilik Modelimiz'**
  String get privacyPublicSection;

  /// No description provided for @privacyPublicDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtların varsayılan olarak GİZLİDİR. Sadece açık paylaşmayı seçtiğin gönderiler toplulukta görünür.'**
  String get privacyPublicDesc;

  /// No description provided for @privacySwipeMatchingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydırma zevkimi CineTwin\'de kullan'**
  String get privacySwipeMatchingTitle;

  /// No description provided for @privacySwipeMatchingDesc.
  ///
  /// In tr, this message translates to:
  /// **'Açarsan yalnızca en güçlü üç türün eşleşme için paylaşılır. Film seçimlerin ve sağ/sol hareketlerin gizli kalır.'**
  String get privacySwipeMatchingDesc;

  /// No description provided for @privacySwipeMatchingEnabled.
  ///
  /// In tr, this message translates to:
  /// **'CineTwin tür paylaşımı açıldı'**
  String get privacySwipeMatchingEnabled;

  /// No description provided for @privacySwipeMatchingDisabled.
  ///
  /// In tr, this message translates to:
  /// **'CineTwin tür paylaşımı kapatıldı ve özet silindi'**
  String get privacySwipeMatchingDisabled;

  /// No description provided for @privacyExportCTA.
  ///
  /// In tr, this message translates to:
  /// **'Verilerimi JSON Olarak İndir'**
  String get privacyExportCTA;

  /// No description provided for @wrappedTitle.
  ///
  /// In tr, this message translates to:
  /// **'CineFile Özet'**
  String get wrappedTitle;

  /// No description provided for @wrappedIntro.
  ///
  /// In tr, this message translates to:
  /// **'Sinema Yolculuğun'**
  String get wrappedIntro;

  /// No description provided for @wrappedTotalTime.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İzleme Süresi'**
  String get wrappedTotalTime;

  /// No description provided for @wrappedTotalHours.
  ///
  /// In tr, this message translates to:
  /// **'{hours} Saat'**
  String wrappedTotalHours(int hours);

  /// No description provided for @wrappedTopGenres.
  ///
  /// In tr, this message translates to:
  /// **'En Çok İzlediğin Türler'**
  String get wrappedTopGenres;

  /// No description provided for @wrappedTopDirector.
  ///
  /// In tr, this message translates to:
  /// **'Favori Yönetmenin'**
  String get wrappedTopDirector;

  /// No description provided for @wrappedTopActor.
  ///
  /// In tr, this message translates to:
  /// **'Favori Oyuncun'**
  String get wrappedTopActor;

  /// No description provided for @wrappedShareCTA.
  ///
  /// In tr, this message translates to:
  /// **'Özet Kartını Paylaş'**
  String get wrappedShareCTA;

  /// No description provided for @wrappedPostCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukta Paylaş'**
  String get wrappedPostCommunity;

  /// No description provided for @wrappedCopiedToast.
  ///
  /// In tr, this message translates to:
  /// **'Özet metni panoya kopyalandı!'**
  String get wrappedCopiedToast;

  /// No description provided for @insightsFilterAllYears.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Yıllar'**
  String get insightsFilterAllYears;

  /// No description provided for @insightsFilterAllTypes.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Yapımlar'**
  String get insightsFilterAllTypes;

  /// No description provided for @insightsFilterMoviesOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Filmler'**
  String get insightsFilterMoviesOnly;

  /// No description provided for @insightsFilterTvOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece Diziler'**
  String get insightsFilterTvOnly;

  /// No description provided for @privacyDeleteAccountCTA.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Verilerimi Cihazdan Sil'**
  String get privacyDeleteAccountCTA;

  /// No description provided for @privacyDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Veriler Silinecek'**
  String get privacyDeleteConfirmTitle;

  /// No description provided for @privacyDeleteConfirmDesc.
  ///
  /// In tr, this message translates to:
  /// **'Cihazınızdaki tüm izleme günlükleri, notlar ve yerel veriler kalıcı olarak sıfırlanacaktır. Bu işlem geri alınamaz.'**
  String get privacyDeleteConfirmDesc;
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

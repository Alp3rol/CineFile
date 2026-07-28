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

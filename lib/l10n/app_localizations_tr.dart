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

  @override
  String get genreAction => 'Aksiyon';

  @override
  String get genreAdventure => 'Macera';

  @override
  String get genreAnimation => 'Animasyon';

  @override
  String get genreComedy => 'Komedi';

  @override
  String get genreCrime => 'Suç';

  @override
  String get genreDocumentary => 'Belgesel';

  @override
  String get genreDrama => 'Dram';

  @override
  String get genreFamily => 'Aile';

  @override
  String get genreFantasy => 'Fantastik';

  @override
  String get genreHistory => 'Tarih';

  @override
  String get genreHorror => 'Korku';

  @override
  String get genreMusic => 'Müzik';

  @override
  String get genreMystery => 'Gizem';

  @override
  String get genreRomance => 'Romantik';

  @override
  String get genreScienceFiction => 'Bilim Kurgu';

  @override
  String get genreThriller => 'Gerilim';

  @override
  String get genreWar => 'Savaş';

  @override
  String get genreWestern => 'Vahşi Batı';

  @override
  String get genreActionAdventure => 'Aksiyon & Macera';

  @override
  String get genreKids => 'Çocuk';

  @override
  String get genreNews => 'Haberler';

  @override
  String get genreReality => 'Realite';

  @override
  String get genreSciFiFantasy => 'Bilim Kurgu & Fantazi';

  @override
  String get genreSoap => 'Pembe Dizi';

  @override
  String get genreTalk => 'Talk Show';

  @override
  String get genreWarPolitics => 'Savaş & Politika';

  @override
  String get genreUnknown => 'Bilinmiyor';

  @override
  String get authErrorUsernameEmpty => 'Kullanıcı adı boş olamaz.';

  @override
  String get authErrorAccountCreationFailed =>
      'Hesap oluşturulamadı, lütfen tekrar deneyin.';

  @override
  String get authErrorUsernameTaken => 'Bu kullanıcı adı zaten alınmış.';

  @override
  String get authErrorEmailInUse => 'Bu e-posta adresi zaten kullanılıyor.';

  @override
  String get authErrorWeakPassword => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get authErrorInvalidEmail => 'Geçersiz bir e-posta adresi girdiniz.';

  @override
  String get authErrorInvalidCredentials => 'E-posta veya şifre hatalı.';

  @override
  String get authErrorNotSignedIn => 'Kullanıcı oturumu bulunamadı.';

  @override
  String get authErrorUserDataMissing => 'Kullanıcı verisi bulunamadı.';

  @override
  String get authErrorUnknown => 'Bir hata oluştu.';

  @override
  String get authGateErrorTitle => 'Kimlik Doğrulama Hatası';

  @override
  String get authGateErrorMessage =>
      'Oturum bilgisi alınamadı. Lütfen tekrar deneyin.';

  @override
  String get authTagline => 'Topluluğa katılın, günlüklerinizi paylaşın.';

  @override
  String get authSignIn => 'Giriş Yap';

  @override
  String get authSignUp => 'Kayıt Ol';

  @override
  String get authEmailHint => 'E-posta';

  @override
  String get authEmailRequired => 'Lütfen e-posta adresinizi girin.';

  @override
  String get authEmailInvalid => 'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get authPasswordHint => 'Şifre';

  @override
  String get authPasswordRequired => 'Lütfen şifrenizi girin.';

  @override
  String get authPasswordTooShort => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get authUsernameLabel => 'Kullanıcı Adı';

  @override
  String get authUsernameRequired => 'Lütfen kullanıcı adı girin.';

  @override
  String get authUsernameTooShort =>
      'Kullanıcı adı en az 3 karakter olmalıdır.';

  @override
  String get authUsernameNoSpaces => 'Kullanıcı adı boşluk içeremez.';

  @override
  String get authNoAccountPrompt => 'Hesabınız yok mu? ';

  @override
  String get authSignUpLink => 'Kayıt Olun';

  @override
  String get authHasAccountPrompt => 'Zaten bir hesabınız var mı? ';

  @override
  String get authSignInLink => 'Giriş Yapın';

  @override
  String get authRegisterSuccess => 'Kayıt başarılı! Giriş yapabilirsiniz.';

  @override
  String get authSignInRequired => 'Lütfen giriş yapın.';

  @override
  String get authUserNotFound => 'Kullanıcı bulunamadı.';

  @override
  String get profileEdit => 'Profili Düzenle';

  @override
  String get profilePresetAvatars => 'Hazır Avatarlar';

  @override
  String get profileUsernameHint => 'Kullanıcı adı girin';

  @override
  String get profileShowcaseTitle =>
      'Profil Vitrini (En Fazla 5 Öne Çıkan Film)';

  @override
  String get profileShowcaseEdit => 'Vitrini Düzenle';

  @override
  String get profileShowcasePickTitle => 'Öne Çıkarılacak Filmleri Seç';

  @override
  String get profileShowcaseNone => 'Henüz öne çıkarılan film seçilmedi.';

  @override
  String get profileShowcaseLimit => 'En fazla 5 film seçebilirsiniz.';

  @override
  String profileShowcaseSelected(int count) {
    return 'Öne Çıkarılan Filmleri Seç ($count/5)';
  }

  @override
  String profileShowcasePickCount(int count) {
    return 'En fazla 5 favori seçin ($count/5)';
  }

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi.';

  @override
  String get profileNoWatchRecords => 'Henüz hiç izleme kaydınız yok.';

  @override
  String get profileRecentWatches => 'Son İzlediklerim';

  @override
  String get profileNoRecentWatches => 'Henüz hiç izleme kaydı eklenmemiş.';

  @override
  String get profileBadgesTitle => 'Kazanılan Rozetler';

  @override
  String get profileBadgesEmpty =>
      'Henüz kazanılmış bir rozet yok. Film izledikçe kilitler açılacaktır! Tümünü incelemek için tıklayın.';

  @override
  String profileBadgesSeeAll(int unlocked, int total) {
    return 'Tümünü Gör ($unlocked/$total)';
  }

  @override
  String get profileSignOut => 'Çıkış Yap';

  @override
  String get profileSignOutConfirm =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get profileFollowers => 'Takipçi';

  @override
  String get profileFollowing => 'Takip';

  @override
  String get profileRankNovice => 'Çaylak Sinefil 🍿';

  @override
  String get profileRankTicketBuddy => 'Bilet Ortağı 🎬';

  @override
  String get profileRankConnoisseur => 'Kültür Üstadı 🏛️';

  @override
  String get profileRankGuru => 'Sinema Gurusu 👑';
}

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

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonDelete => 'Sil';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsPreferences => 'Tercihler';

  @override
  String get settingsReleaseReminders => 'Çıkış Hatırlatıcıları';

  @override
  String get settingsDynamicBackground => 'Dinamik Arka Plan';

  @override
  String get settingsNotificationPermissionDenied =>
      'Bildirim izni reddedildi. Sistem ayarlarından açabilirsiniz.';

  @override
  String get settingsDataSection => 'Veri Yönetimi & Yedekleme';

  @override
  String get settingsBackupTitle => 'Günlük Yedekleme';

  @override
  String get settingsBackupDescription =>
      'Tüm izleme geçmişinizi, koleksiyonlarınızı, favorilerinizi ve notlarınızı JSON formatında yedekleyebilir ve istediğiniz cihazda geri yükleyebilirsiniz. Geri yükleme mevcut verilerin üzerine yazar.';

  @override
  String get settingsExport => 'Dışa Aktar';

  @override
  String get settingsRestore => 'Geri Yükle';

  @override
  String get settingsCleanDuplicates => 'Mükerrer Kayıtları Temizle';

  @override
  String get settingsDataProvider => 'Veri Sağlayıcı';

  @override
  String get settingsTmdbAttribution =>
      'Bu uygulama TMDB API\'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get backupCopiedTitle => 'Yedek Panoya Kopyalandı!';

  @override
  String get backupCopiedMessage =>
      'Yedekleme verileriniz kopyalandı. Bu veriyi bir dosyaya kaydederek veya başka bir cihaza göndererek saklayabilirsiniz.';

  @override
  String get backupRestoreTitle => 'Yedekten Geri Yükle';

  @override
  String get backupRestoreWarning =>
      'Daha önce kopyaladığınız JSON yedek kodunu aşağıdaki alana yapıştırın. Bu işlem koleksiyonlarınızın VE hesabınızdaki tüm izleme geçmişinizin üzerine yazacaktır!';

  @override
  String get backupRestoreHint => 'JSON kodunu buraya yapıştırın...';

  @override
  String get backupRestoreConfirm => 'Yükle';

  @override
  String get backupRestoreSuccess => 'Verileriniz yedekten başarıyla yüklendi!';

  @override
  String backupExportError(String error) {
    return 'Yedekleme dosyası oluşturulurken hata: $error';
  }

  @override
  String backupRestoreInvalid(String error) {
    return 'Hata: Geçersiz yedek kodu formatı! ($error)';
  }

  @override
  String get duplicateCleanupTitle => 'Mükerrer Kayıtları Temizle';

  @override
  String get duplicateCleanupConfirmTitle => 'Mükerrer Kayıtları Sil';

  @override
  String get duplicateCleanupNone =>
      'Mükerrer kayıt bulunamadı. Günlüğün temiz görünüyor.';

  @override
  String duplicateCleanupConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count dizi/film için fazladan günlük kayıtları silinecek, sadece en son ilerlemeyi yansıtan kayıt tutulacak. Bu işlem geri alınamaz.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupIntro(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count dizi/film için aynı gün birden fazla kayıt bulundu. Her grupta en son ilerlemeyi yansıtan kayıt tutulacak, geri kalanı silinecek.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupGroupSummary(String day, int total, int toDelete) {
    return '$day • $total kayıt, $toDelete silinecek';
  }

  @override
  String duplicateCleanupCleaned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dizi/film için mükerrer kayıtlar temizlendi.',
    );
    return '$_temp0';
  }

  @override
  String duplicateCleanupPartial(int cleaned, int failed) {
    return '$cleaned temizlendi, $failed tanesi başarısız oldu.';
  }

  @override
  String duplicateCleanupAction(int count) {
    return 'Seçilenleri Temizle ($count)';
  }

  @override
  String duplicateCleanupLoadError(String error) {
    return 'Kayıtlar yüklenemedi: $error';
  }

  @override
  String get notificationChannelName => 'Çıkış Hatırlatıcıları';

  @override
  String get notificationChannelDescription =>
      'İzleme listendeki film ve dizilerin çıkış günü hatırlatıcıları.';

  @override
  String get notificationReleaseTitle => 'Bugün Çıkıyor! 🎬';

  @override
  String get notificationEpisodeTitle => 'Yeni Bölüm! 🎬';

  @override
  String get notificationWatchlistFallbackTitle => 'İzleme Listendeki Yapım';

  @override
  String get notificationShowFallbackTitle => 'Takip Ettiğin Dizi';

  @override
  String notificationReleaseBodyMovie(String title) {
    return 'İzleme listendeki \"$title\" filmi bugün yayınlanıyor.';
  }

  @override
  String notificationReleaseBodyShow(String title) {
    return 'İzleme listendeki \"$title\" yeni bölümü bugün yayınlanıyor.';
  }

  @override
  String get searchTitle => 'Keşfet';

  @override
  String get searchHint => 'Film veya dizi ara...';

  @override
  String get searchNoResultsTitle => 'Sonuç Bulunamadı';

  @override
  String get searchNoResultsHint => 'Farklı bir kelime aramayı deneyin.';

  @override
  String get searchStartTitle => 'Keşfetmeye Başlayın';

  @override
  String get searchStartHint => 'Milyonlarca film arasından arama yapın.';

  @override
  String get searchErrorNetwork =>
      'TMDb\'ye ulaşılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get searchErrorInvalidApiKey =>
      'TMDb API anahtarı geçersiz. Ayarlar\'dan kontrol edebilirsin.';

  @override
  String get searchErrorUnknown => 'Arama tamamlanamadı. Lütfen tekrar dene.';

  @override
  String get discoverFilterAll => 'Hepsi';

  @override
  String get discoverFilterMovies => 'Film';

  @override
  String get discoverFilterShows => 'Dizi';

  @override
  String get discoverCategoryTrend => 'Trend';

  @override
  String get discoverCategoryPopular => 'Popüler';

  @override
  String get discoverCategoryTopRated => 'En Çok Oy Alan';

  @override
  String get discoverWindowThisWeek => 'Bu Hafta';

  @override
  String get discoverWindowToday => 'Bugün';

  @override
  String get discoverGenreAll => 'Tümü';

  @override
  String get discoverHeadingTrendToday => 'Bugün Trend Film/Dizileri';

  @override
  String get discoverHeadingTrendThisWeek => 'Bu Hafta Trend Film/Dizileri';

  @override
  String get discoverHeadingPopular => 'Popüler Film/Dizileri';

  @override
  String get discoverHeadingTopRated => 'En Çok Oy Alan Film/Dizileri';

  @override
  String get discoverFilterEmpty => 'Bu kategoride sonuç bulunamadı';

  @override
  String get searchTmdbAttribution => 'Veriler TMDB tarafından sağlanmaktadır.';

  @override
  String get recommendationsTitle => 'Sana Özel Öneriler';

  @override
  String get recommendationReasonPopular => 'Toplulukta Popüler';

  @override
  String recommendationReasonGenre(String genre) {
    return '$genre Sevenlere';
  }

  @override
  String recommendationReasonDirector(String director) {
    return '$director Yönettiği İçin';
  }

  @override
  String recommendationReasonActor(String actor) {
    return '$actor Rol Alıyor';
  }

  @override
  String get titleUnknown => 'Bilinmeyen Yapım';

  @override
  String get searchDemoModeBanner =>
      'TMDb API anahtarı girilmedi. Şu an deneme modundasınız (\"dune\", \"interstellar\", \"inception\" veya \"dark\" aramalarını test edebilirsiniz).';

  @override
  String get detailNotFound => 'Film detayları bulunamadı.';

  @override
  String get detailNoOverview => 'Özet bulunmuyor.';

  @override
  String get detailOverview => 'Özet';

  @override
  String get detailCast => 'Oyuncular';

  @override
  String get detailDirector => 'Yönetmen';

  @override
  String get detailMyRating => 'Puanım';

  @override
  String get detailPlace => 'Ortam';

  @override
  String get detailAddToDiary => 'Günlüğe Ekle';

  @override
  String get detailAddToList => 'Listeye Ekle';

  @override
  String get detailShare => 'Paylaş';

  @override
  String get detailAddToMyDiary => 'Günlüğüme Ekle';

  @override
  String get detailSetRank => 'Sıra Belirle';

  @override
  String get detailTmdbAttribution => 'Veriler TMDB tarafından sağlanmaktadır.';

  @override
  String get directorUnknown => 'Bilinmiyor';

  @override
  String get detailFavoriteFailed =>
      'Favori durumu güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get detailWatchlistFailed =>
      'İzleme listesi güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get detailRecordDeleted => 'İzleme kaydı silindi.';

  @override
  String get detailRecordDeleteFailed =>
      'İzleme kaydı silinemedi. Lütfen tekrar deneyin.';

  @override
  String get detailLoadFailed => 'Detaylar yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get timelineTitle => 'İzleme Geçmişim';

  @override
  String get timelineEmpty => 'Bu filmi henüz izlemediniz.';

  @override
  String get timelineLoadFailed => 'İzleme geçmişi yüklenemedi.';

  @override
  String timelineMood(String mood) {
    return 'Mod: $mood';
  }

  @override
  String get timelineDeleteTitle => 'Kaydı Sil?';

  @override
  String get timelineDeleteConfirm =>
      'Bu izleme kaydını günlüğünüzden kalıcı olarak silmek istediğinize emin misiniz?';

  @override
  String get commonDiscard => 'Vazgeç';

  @override
  String get watchStatusCompleted => 'Tamamlandı';

  @override
  String watchStatusWatchingOf(int watched, int total) {
    return 'İzleniyor ($watched/$total)';
  }

  @override
  String watchStatusWatchingEpisode(int episode) {
    return 'İzleniyor (Bölüm $episode)';
  }

  @override
  String get rankDialogTitle => 'Favori Sırası Belirle';

  @override
  String get rankDialogField => 'Sıra Numarası';

  @override
  String get rankSaveFailed => 'Sıra kaydedilemedi.';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get addRecordTitle => 'Günlüğe İzleme Kaydı Ekle';

  @override
  String get addRecordSubmit => 'Kaydı Günlüğe Ekle';

  @override
  String get addRecordSignInRequired => 'Lütfen önce giriş yapın.';

  @override
  String get addRecordSaveFailed => 'Kayıt kaydedilirken hata oluştu.';

  @override
  String get addRecordMoodLabel => 'İzleme Modu / Ruh Hali:';

  @override
  String get addRecordRatingLabel => 'Senin Puanın:';

  @override
  String get addRecordPlaceLabel => 'Nerede İzledin?';

  @override
  String get addRecordPlaceHint => 'Örn: Kadıköy Sineması, Ev...';

  @override
  String get addRecordCompanionLabel => 'Kiminle İzledin?';

  @override
  String get addRecordCompanionHint => 'Örn: Tek başıma, Ahmet, Ailem...';

  @override
  String get addRecordNotesLabel => 'Kişisel Notların:';

  @override
  String get addRecordNotesHint =>
      'Film hakkında ne düşünüyorsun? Akılda kalıcı sahneler...';

  @override
  String get addRecordTagsLabel => 'Özel Etiketler (#tag):';

  @override
  String get addRecordTagsHint =>
      'Örn: #nostalji, #sinemada, #yalnız (Virgülle ayırın)...';

  @override
  String get addRecordVisibilityLabel => 'Profilimde Göster';

  @override
  String get addRecordVisibilityHint =>
      'Açarsan bu kayıt profilindeki \"Son İzlediklerim\" bölümünde herkese görünür.';

  @override
  String get addRecordContentSection => 'İçerik';

  @override
  String get placeHome => 'Ev';

  @override
  String get placeCinema => 'Sinema';

  @override
  String get placeFriendsHouse => 'Arkadaşın Evi';

  @override
  String get placeTravelling => 'Yolculukta';

  @override
  String get placeHotel => 'Otelde';

  @override
  String get placePlane => 'Uçakta';

  @override
  String get placeGarden => 'Bahçede';

  @override
  String get placeCamping => 'Kampta';

  @override
  String get placeWork => 'İş Yerinde';

  @override
  String get companionAlone => 'Tek Başına';

  @override
  String get companionFriends => 'Arkadaşlarla';

  @override
  String get companionFamily => 'Ailemle';

  @override
  String get companionPartner => 'Sevgilimle';

  @override
  String get companionSpouse => 'Eşimle';

  @override
  String get companionSibling => 'Kardeşimle';

  @override
  String get companionKids => 'Çocuklarla';

  @override
  String get companionColleagues => 'İş Arkadaşlarımla';

  @override
  String get episodeTrackingActive => 'Aktif İzliyorum';

  @override
  String get episodeTrackingWholeSeason => 'Tüm sezonu bitirdim';

  @override
  String get episodeTrackingSpecificCount => 'Belirli sayıda bölüm';

  @override
  String get episodeTrackingCountLabel => 'Kaç bölüm izledin?';

  @override
  String episodeLabel(int episode) {
    return 'Bölüm $episode';
  }

  @override
  String episodeLabelOf(int episode, int total) {
    return 'Bölüm $episode / $total';
  }

  @override
  String get episodeGuideTitle => 'Bölüm Rehberi';

  @override
  String get episodeGuideEmpty => 'Bu sezona ait bölüm bulunamadı.';

  @override
  String get episodeGuideLoadFailed =>
      'Bölümler yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get episodeNoOverview => 'Bölüm özeti bulunmuyor.';

  @override
  String get episodeMarkSeasonWatched => 'Bu Sezonu İzledim';

  @override
  String get episodeMarkFailed => 'Bölüm işaretlenemedi.';

  @override
  String get episodeAddShowPrompt => 'Bu diziyi günlüğüne eklemek ister misin?';

  @override
  String get episodeAddShowExplain =>
      'Günlüğe eklersen \"Aktif İzliyorum\" listende görünür ve istatistiklerine yansır.';

  @override
  String get episodeFollowOnly => 'Sadece Takip Et';

  @override
  String get episodeConfirmWatchedTitle => 'Bölümleri İzledin mi?';

  @override
  String get episodeUndoProgressTitle => 'İzleme İlerlemesini Geri Al?';

  @override
  String get commonYes => 'Evet';

  @override
  String get offlineOverviewUnavailable => 'Çevrimdışı mod: Özet yüklenemedi.';

  @override
  String get offlineContentTitle => 'Çevrimdışı İçerik';

  @override
  String get offlineFallbackOverview =>
      'Bağlantı sorunu nedeniyle film detayları tam yüklenemedi. Ancak bu içeriği hala günlüğünüze veya listelerinize ekleyebilirsiniz.';

  @override
  String addRecordSuccess(String title) {
    return '$title günlüğünüze başarıyla eklendi!';
  }

  @override
  String get rankDialogExplain =>
      'Bu film için favori sıralama numarasını girin (Örn: 1, 2, 5). Boş bırakırsanız sıralamadan çıkarılır.';

  @override
  String castSearching(String name) {
    return '$name profili aranıyor...';
  }

  @override
  String castNotFound(String name) {
    return '$name için profil bulunamadı.';
  }

  @override
  String episodeNumbered(int episode) {
    return '$episode. Bölüm';
  }

  @override
  String get episodeUpNext => '▶ SIRADAKİ';

  @override
  String episodeMarkedWatched(int episode) {
    return '$episode. Bölüm izlendi olarak işaretlendi.';
  }

  @override
  String episodeMarkedUnwatched(int episode) {
    return '$episode. Bölüm izlenmedi olarak işaretlendi.';
  }

  @override
  String episodeBulkWatchConfirm(int from, int to) {
    return 'Bu bölümü izlendi olarak işaretlemek, önceki tüm bölümleri de ($from - $to) izlendi sayacaktır. Devam etmek istiyor musunuz?';
  }

  @override
  String episodeBulkUnwatchConfirm(int from, int to) {
    return 'Bu bölümü izlenmedi olarak işaretlemek, sonraki tüm bölümleri de ($from - $to) izlenmedi sayacaktır. Devam etmek istiyor musunuz?';
  }

  @override
  String get tagNostalgia => '#nostalji';

  @override
  String get tagAtTheCinema => '#sinemada';

  @override
  String get tagAlone => '#yalnız';

  @override
  String get tagAction => '#aksiyon';

  @override
  String get tagRomance => '#romantizm';

  @override
  String get tagThriller => '#gerilim';

  @override
  String get tagComedy => '#komedi';

  @override
  String get tagDrama => '#drama';

  @override
  String get tagSciFi => '#bilimkurgu';

  @override
  String get tagHorror => '#korku';

  @override
  String get tagClassic => '#klasik';

  @override
  String get tagNewDiscovery => '#yenikesif';

  @override
  String notificationEpisodeBody(String show, int season, int episode) {
    return '\"$show\" dizisinin $season. sezon $episode. bölümü bugün yayınlanıyor.';
  }
}

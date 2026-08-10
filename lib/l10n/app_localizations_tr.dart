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
  String get swipeDiscoverTitle => 'Kaydır & Keşfet';

  @override
  String get swipeDiscoverEntryHint =>
      'İlgini çekenleri İzleme Listesi\'ne ekle';

  @override
  String get swipeDiscoverHint =>
      'Sağa kaydır: İzleme Listesi\'ne ekle • Sola kaydır: geç';

  @override
  String get swipeInterested => 'Listeme Ekle';

  @override
  String get swipeNotInterested => 'Geç';

  @override
  String get swipeWatched => 'İzledim';

  @override
  String get swipeAddedToWatchlist => 'İzleme Listesi\'ne eklendi';

  @override
  String get swipePassed => 'Bu yapımı geçtin';

  @override
  String get swipeWhy => 'Neden?';

  @override
  String get swipeSkipReasonTitle => 'Neden geçtin?';

  @override
  String get swipeSkipReasonHint =>
      'İsteğe bağlıdır ve önerilerini iyileştirir.';

  @override
  String get swipeSkipReasonGenre => 'Bu tür bana göre değil';

  @override
  String get swipeSkipReasonTitleSpecific => 'Bu yapım ilgimi çekmedi';

  @override
  String get swipeSkipReasonNotNow => 'Şimdilik istemiyorum';

  @override
  String get swipeSkipReasonSaved => 'Tercihin önerilerine yansıtılacak';

  @override
  String get swipeUndo => 'Geri al';

  @override
  String get swipeViewDetails => 'Tüm Detayları Gör';

  @override
  String swipeSeasonCount(int count) {
    return '$count Sezon';
  }

  @override
  String get swipeSessionSummary => 'Bu Oturumda';

  @override
  String get swipeSessionAdded => 'Listeye';

  @override
  String get swipeSessionPassed => 'Geçildi';

  @override
  String get swipeSessionWatched => 'İzlendi';

  @override
  String swipeSessionTasteHint(String genres) {
    return '$genres seçimlerin sonraki önerilerini güçlendirecek';
  }

  @override
  String get swipeSaveFailed => 'Tercihin kaydedilemedi. Lütfen tekrar dene.';

  @override
  String get swipeDeckFinished => 'Şimdilik hepsi bu!';

  @override
  String get swipeDeckFinishedHint =>
      'Yeni öneriler geldiğinde burada seni bekliyor olacak.';

  @override
  String get swipeMoreOptions => 'Diğer seçenekler';

  @override
  String get swipeResetTitle => 'Kaydırma tercihleri sıfırlansın mı?';

  @override
  String get swipeResetMessage =>
      'İlgilenmediğin içerikler yeniden önerilebilir. İzleme Listen ve izleme geçmişin değişmez.';

  @override
  String get swipeResetAction => 'Tercihleri sıfırla';

  @override
  String get swipeResetDone => 'Kaydırma tercihlerin sıfırlandı';

  @override
  String swipeRemaining(int count) {
    return '$count öneri kaldı';
  }

  @override
  String get swipeLoadMore => 'Yeni öneriler getir';

  @override
  String get swipeRefreshFailed =>
      'Yeni öneriler yüklenemedi. Lütfen tekrar dene.';

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
  String get journalTitle => 'Günlüğüm';

  @override
  String get journalTabDiary => 'Günlük';

  @override
  String get journalTabLists => 'Listeler';

  @override
  String get journalTabInsights => 'Analiz';

  @override
  String get journalSearchHint => 'Film, yönetmen, not, mekan...';

  @override
  String get journalFilterAll => 'Tümü';

  @override
  String get journalFilterFavorites => 'Favoriler';

  @override
  String get journalFilterCinema => 'Sinemada';

  @override
  String get journalFilterWithNotes => 'Notlu Olanlar';

  @override
  String get journalStatThisMonth => 'Bu Ay';

  @override
  String get journalStatAvgRating => 'Ort. Puan';

  @override
  String get journalStatFavoriteGenre => 'Favori Tür';

  @override
  String get journalStatTotalTime => 'Toplam Süre';

  @override
  String get journalStatUndetermined => 'Belirsiz';

  @override
  String get journalEmptyTitle => 'Kayıt Bulunamadı';

  @override
  String get journalEmptyFiltered =>
      'Arama kriterlerinize veya filtrelere uyan bir günlük kaydı bulunmamaktadır.';

  @override
  String get journalEmptyNoRecords =>
      'Günlüğünüz henüz boş. Keşfet sekmesinden yeni izleme kayıtları ekleyebilirsiniz.';

  @override
  String get journalLoadFailed => 'Günlük yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get journalReorderFailed =>
      'Sıralama kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get journalColumnRank => 'Sıra';

  @override
  String get journalColumnTitle => 'Film Adı';

  @override
  String get journalColumnWatchDate => 'İzleme Tarihi';

  @override
  String get journalColumnWatch => 'İzleme';

  @override
  String get journalColumnWatchOrder => 'İzleme Sırası';

  @override
  String get collectionsTitle => 'Koleksiyonlarım';

  @override
  String get collectionsEmptyTitle => 'Hiç Koleksiyonunuz Yok';

  @override
  String get collectionsCreate => 'Koleksiyon Oluştur';

  @override
  String get collectionsLoadFailed => 'Koleksiyonlar yüklenemedi.';

  @override
  String get collectionAddTo => 'Koleksiyona Ekle';

  @override
  String get collectionNewList => 'Yeni Liste';

  @override
  String get collectionNoneYet => 'Hiç koleksiyonunuz yok.';

  @override
  String get collectionNoneYetHint =>
      'Eklemek için sağ üstteki \"+ Yeni Liste\" butonuna basın.';

  @override
  String get collectionUpdateFailed => 'Liste güncellenemedi, tekrar deneyin.';

  @override
  String get commonOk => 'Tamam';

  @override
  String get detailWhereToWatch => 'Nerede İzlenir?';

  @override
  String get detailWatchCategoryFlatrate => 'Abonelikle';

  @override
  String get detailWatchCategoryFree => 'Ücretsiz';

  @override
  String get detailWatchCategoryRent => 'Kirala';

  @override
  String get detailWatchCategoryBuy => 'Satın Al';

  @override
  String get detailWatchProvidersJustWatchAttribution =>
      'Yayın platformu bilgileri JustWatch tarafından sağlanmaktadır.';

  @override
  String get settingsWatchRegionLabel => 'Yayın Bölgesi';

  @override
  String get settingsWatchRegionTitle => 'Bölge Seçin';

  @override
  String settingsWatchRegionAutoWith(String region) {
    return 'Otomatik ($region)';
  }

  @override
  String commonErrorWithDetail(String detail) {
    return 'Hata: $detail';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileBioLabel => 'Biyografi';

  @override
  String get profileBioHint => 'Kendinden bahset...';

  @override
  String get collectionEditTitle => 'Koleksiyonu Düzenle';

  @override
  String get collectionCreateTitle => 'Yeni Koleksiyon Oluştur';

  @override
  String get collectionEditExplain =>
      'Koleksiyonunuzun adı, açıklaması ve maraton tarihini güncelleyin.';

  @override
  String get collectionCreateExplain =>
      'Film maratonlarınızı takip etmek veya tematik listeler oluşturmak için bilgileri girin.';

  @override
  String get collectionNameLabel => 'Koleksiyon Adı';

  @override
  String get collectionNameHint => 'Örn: Marvel Maratonu, Başyapıtlar...';

  @override
  String get collectionDescriptionLabel => 'Açıklama (İsteğe Bağlı)';

  @override
  String get collectionDescriptionHint =>
      'Koleksiyonunuza dair kısa bir açıklama yazın...';

  @override
  String get collectionTargetDateLabel => 'Maraton Hedef Tarihi';

  @override
  String get collectionTargetDatePick => 'Hedef Tarih Seçin (İsteğe Bağlı)';

  @override
  String get commonCreate => 'Oluştur';

  @override
  String get collectionEmptyTitle => 'Bu Koleksiyon Boş';

  @override
  String get collectionEmptyHint =>
      'Keşfet sekmesinden filmler arayarak veya detay sayfalarından bu koleksiyona filmler ekleyebilirsiniz.';

  @override
  String get collectionRemovedMovie => 'Film koleksiyondan çıkarıldı.';

  @override
  String get collectionDeleteTitle => 'Koleksiyonu Sil?';

  @override
  String get collectionShared => 'Toplulukla paylaşılıyor';

  @override
  String get collectionStopSharing => 'Paylaşımı Durdur';

  @override
  String get collectionStopSharingFailed =>
      'Paylaşım durdurulamadı, tekrar deneyin.';

  @override
  String get collectionReorderFailed =>
      'Sıralama kaydedilemedi, tekrar deneyin.';

  @override
  String get marathonExpired => 'Süre Doldu! ⚠️';

  @override
  String marathonDaysLeft(int days) {
    return 'Hedefe ulaşmak için $days gün kaldı.';
  }

  @override
  String get marathonCompleted => 'Tebrikler, maratonu tamamladınız! 🎉';

  @override
  String marathonRemaining(int count) {
    return 'Kalan: $count film.';
  }

  @override
  String recordMood(String mood) {
    return 'Ruh Hali: $mood';
  }

  @override
  String get recordWatchDate => 'İzleme Tarihi';

  @override
  String get recordEpisodesWatched => 'İzlenen Bölüm Sayısı';

  @override
  String get recordEpisodeCount => 'Bölüm Sayısı';

  @override
  String get recordEpisodeCountHint => 'Kaç bölüm izlendi?';

  @override
  String get recordWatchPlace => 'İzleme Mekanı';

  @override
  String get recordCompanions => 'Eşlik Edenler';

  @override
  String get recordVisibilityFailed => 'Paylaşım durumu güncellenemedi.';

  @override
  String get recordMyRank => 'Favori Sıram: ';

  @override
  String get recordRemoveRank => 'Sıradan Çıkar';

  @override
  String get recordMyNotes => 'Kişisel Notlarım:';

  @override
  String get recordNoNotes => 'Kayıt eklenirken not yazılmamış.';

  @override
  String get recordDeleteConfirmTitle => 'Emin misiniz?';

  @override
  String get recordDeleteConfirmBody => 'Bu izleme kaydı silinecek.';

  @override
  String get recordDeleteFailed => 'Kayıt silinemedi. Lütfen tekrar deneyin.';

  @override
  String get recordDelete => 'Kaydı Sil';

  @override
  String get insightsInsufficientData => 'Yetersiz Veri';

  @override
  String get insightsSummaryTotalWatches => 'Toplam İzleme';

  @override
  String get insightsSummaryUniqueTitles => 'Tekil İçerik';

  @override
  String get insightsSummaryTotalTime => 'Toplam Süre';

  @override
  String get insightsSummaryAvgRating => 'Ort. Puan';

  @override
  String get insightsGenreChartTitle => 'En Popüler Türler (Tür Dağılımı)';

  @override
  String get insightsGenreOther => 'Diğer';

  @override
  String get insightsRatingChartTitle => 'Kişisel Puan Dağılımı';

  @override
  String get insightsCriticProfile => 'Eleştirmen Profilin';

  @override
  String get insightsTopDirectors => 'En Çok İzlenen Yönetmenler';

  @override
  String get insightsTopActors => 'En Çok İzlenen Oyuncular';

  @override
  String get insightsNoRecords => 'Kayıt bulunamadı.';

  @override
  String get insightsTimeOfDayTitle => 'Günün Hangi Saatlerinde İzliyorsun?';

  @override
  String get insightsTimeMorning => 'Sabah';

  @override
  String get insightsTimeNoon => 'Öğle';

  @override
  String get insightsTimeEvening => 'Akşam';

  @override
  String get insightsTimeNight => 'Gece';

  @override
  String get insightsSeasonWinter => 'Kış';

  @override
  String get insightsSeasonSpring => 'İlkbahar';

  @override
  String get insightsSeasonSummer => 'Yaz';

  @override
  String get insightsSeasonAutumn => 'Sonbahar';

  @override
  String insightsMonthlyChartTitle(int year) {
    return '$year Aylık İzleme Grafiği';
  }

  @override
  String insightsWatchesCount(int count) {
    return '$count İzleme';
  }

  @override
  String insightsGoldenDay(String day) {
    return 'Altın Gün: $day 🏆';
  }

  @override
  String get heatmapTitle => 'Yıllık İzleme Sıklığı';

  @override
  String get heatmapFilterAll => 'Tümü';

  @override
  String get heatmapFilterMovies => 'Filmler';

  @override
  String get heatmapFilterShows => 'Diziler';

  @override
  String get heatmapLegendLess => 'Az';

  @override
  String get heatmapLegendMore => 'Çok';

  @override
  String get heatmapLegendMovie => 'Film';

  @override
  String get heatmapLegendShow => 'Dizi';

  @override
  String get heatmapLegendBoth => 'İkisi';

  @override
  String get heatmapActiveDays => 'Aktif Gün';

  @override
  String get heatmapCurrentStreak => 'Mevcut Seri';

  @override
  String get heatmapPeakHour => 'Yoğun Saat';

  @override
  String get heatmapNoRecordOnDay => 'tarihinde izleme kaydı yok.';

  @override
  String get weeklyGoalSetTitle => 'Haftalık Hedefi Ayarla';

  @override
  String get weeklyGoalQuestion => 'Haftada kaç film/dizi izlemek istersiniz?';

  @override
  String get weeklyGoalThisWeekPrefix => 'Bu hafta ';

  @override
  String get weeklyGoalReached =>
      'Tebrikler, bu haftaki hedefinize ulaştınız! 🎉';

  @override
  String weeklyGoalRemaining(int count) {
    return 'Hedefe ulaşmak için $count film daha izlemelisiniz.';
  }

  @override
  String get achievementsTitle => 'Rozet & Başarım Koleksiyonu';

  @override
  String get achievementsNeedRecords =>
      'Rozetlerin yüklenmesi için günlüğünüze en az 1 izleme kaydı eklemelisiniz.';

  @override
  String get achievementsCurrentRank => 'MEVCUT UNVAN';

  @override
  String get achievementsProgress => 'Koleksiyon İlerlemesi';

  @override
  String get achievementsUnlocked => 'Kazanılanlar';

  @override
  String get achievementsNoneForFilter =>
      'Seçili filtreye uygun rozet bulunamadı.';

  @override
  String achievementsAllCount(int count) {
    return 'Tümü ($count)';
  }

  @override
  String get achievementsRankNoviceSubtitle =>
      'Sinema yolculuğuna yeni başladın';

  @override
  String get achievementsRankTicketBuddy => 'Sinema Bilet Ortağı 🎬';

  @override
  String get achievementsRankTicketBuddySubtitle => 'Düzenli izleyici';

  @override
  String get achievementsRankConnoisseurSubtitle => 'Sinematik hafızası yüksek';

  @override
  String get achievementsRankGuruSubtitle => 'Gerçek bir kültür abidesi';

  @override
  String get badgeMaxLevel => 'Maksimum Seviye! 👑';

  @override
  String get badgeNextLevelProgress => 'Sonraki Seviye İlerlemesi';

  @override
  String get badgeUnlockProgress => 'Kilit İlerlemesi';

  @override
  String get badgeShare => 'Başarımı Paylaş';

  @override
  String get badgeCategoryMilestone => 'Hacim & Maraton';

  @override
  String get badgeCategoryTime => 'Zaman & Atmosfer';

  @override
  String get badgeCategoryDirectors => 'Yönetmenler & Auteurs';

  @override
  String get badgeCategoryGenres => 'Türler & Temalar';

  @override
  String get badgeCategoryCritic => 'Eleştirmen & Günlük';

  @override
  String get badgeCategorySeries => 'Dizi & Sezon';

  @override
  String get badgeFirstWatchTitle => 'İlk Adımlar';

  @override
  String get badgeFirstWatchT1 => 'İlk Adım';

  @override
  String get badgeFirstWatchT2 => 'İzleme Tutkusu';

  @override
  String get badgeFirstWatchT3 => 'Sıkı Takipçi';

  @override
  String get badgeSinefilTitle => 'Sinefil Serisi';

  @override
  String get badgeSinefilT1 => 'Sinefil';

  @override
  String get badgeSinefilT2 => 'Kültür Mantarı';

  @override
  String get badgeSinefilT3 => 'Sinema Efsanesi';

  @override
  String get badgeSinefilT4 => 'Sinema Gurusu';

  @override
  String get badgeStreakTitle => 'Seri İzleyici';

  @override
  String get badgeStreakT1 => 'Kısa Maraton';

  @override
  String get badgeStreakT2 => 'Seri İzleyici';

  @override
  String get badgeStreakT3 => 'Ateşli İzleyici';

  @override
  String get badgeStreakT4 => 'Durdurulamaz Maratoncu';

  @override
  String get badgeNightOwlTitle => 'Gece Kuşu Serisi';

  @override
  String get badgeNightOwlT1 => 'Gece Kuşu';

  @override
  String get badgeNightOwlT2 => 'Gece Bekçisi';

  @override
  String get badgeNightOwlT3 => 'Karanlıklar Prensi';

  @override
  String get badgeEarlyBirdTitle => 'Erken Kuş Serisi';

  @override
  String get badgeEarlyBirdT1 => 'Gün Doğumu İzleyicisi';

  @override
  String get badgeEarlyBirdT2 => 'Erken Kuş';

  @override
  String get badgeEarlyBirdT3 => 'Şafak Bekçisi';

  @override
  String get badgeSundayTitle => 'Pazar Sineması';

  @override
  String get badgeSundayT1 => 'Pazar Keyfi';

  @override
  String get badgeSundayT2 => 'Pazar Sineması';

  @override
  String get badgeSundayT3 => 'Pazar Üstadı';

  @override
  String get badgeWeekendTitle => 'Hafta Sonu Maratonu';

  @override
  String get badgeWeekendT1 => 'Hafta Sonu Başlangıcı';

  @override
  String get badgeWeekendT2 => 'Hafta Sonu Maratoncusu';

  @override
  String get badgeWeekendT3 => 'Hafta Sonu Canavarı';

  @override
  String get badgeWinterTitle => 'Kışlık Battaniye & Film';

  @override
  String get badgeWinterT1 => 'Mevsimlik İzleyici';

  @override
  String get badgeWinterT2 => 'Kışlık Battaniye & Film';

  @override
  String get badgeWinterT3 => 'Dört Mevsim Sinefil';

  @override
  String get badgeTimeTravelerTitle => 'Zaman Gezgini';

  @override
  String get badgeTimeTravelerT1 => 'Nostalji Meraklısı';

  @override
  String get badgeTimeTravelerT2 => 'Zaman Gezgini';

  @override
  String get badgeTimeTravelerT3 => 'Klasikler Arşivcisi';

  @override
  String get badgeNolanTitle => 'Nolanist Serisi';

  @override
  String get badgeNolanT1 => 'Nolan Meraklısı';

  @override
  String get badgeNolanT2 => 'Zaman Büken Nolanist';

  @override
  String get badgeNolanT3 => 'Rüya İçinde Rüya Mimarı';

  @override
  String get badgeTarantinoTitle => 'Tarantino Sever';

  @override
  String get badgeTarantinoT1 => 'Ucuz Roman Sever';

  @override
  String get badgeTarantinoT2 => 'Kanlı İntikam Ustası';

  @override
  String get badgeTarantinoT3 => 'Sinematik Auteur';

  @override
  String get badgeSpielbergTitle => 'Spielberg Hayranı';

  @override
  String get badgeSpielbergT1 => 'Macera Çırağı';

  @override
  String get badgeSpielbergT2 => 'Spielberg Hayranı';

  @override
  String get badgeSpielbergT3 => 'Blockbuster Efsanesi';

  @override
  String get badgeScorseseTitle => 'Scorsese Müptelası';

  @override
  String get badgeScorseseT1 => 'Mafya & Suç Sever';

  @override
  String get badgeScorseseT2 => 'Scorsese Müptelası';

  @override
  String get badgeScorseseT3 => 'Sinema Sanatçısı';

  @override
  String get badgeKubrickTitle => 'Kubrick Ustalığı';

  @override
  String get badgeKubrickT1 => 'Kubrick Çırağı';

  @override
  String get badgeKubrickT2 => 'Kubrick Ustalığı';

  @override
  String get badgeKubrickT3 => 'Görsel Vizyoner';

  @override
  String get badgeWesternTitle => 'Vahşi Batı Serisi';

  @override
  String get badgeWesternT1 => 'Vahşi Batı Kaşifi';

  @override
  String get badgeWesternT2 => 'Kovboy & Şerif';

  @override
  String get badgeWesternT3 => 'İyi, Kötü ve Çirkin Efsanesi';

  @override
  String get badgeScifiTitle => 'Sci-Fi Kaşifi';

  @override
  String get badgeScifiT1 => 'Uzay Yolcusu';

  @override
  String get badgeScifiT2 => 'Galaksi Kaşifi';

  @override
  String get badgeScifiT3 => 'Evrenin Hakimi';

  @override
  String get badgeHorrorTitle => 'Korku & Gerilim';

  @override
  String get badgeHorrorT1 => 'Korkusuz İzleyici';

  @override
  String get badgeHorrorT2 => 'Gerilim Üstadı';

  @override
  String get badgeHorrorT3 => 'Kabusların Efendisi';

  @override
  String get badgeDramaTitle => 'Drama Tutkunu';

  @override
  String get badgeDramaT1 => 'Duygusal İzleyici';

  @override
  String get badgeDramaT2 => 'Drama Tutkunu';

  @override
  String get badgeDramaT3 => 'Duygu Üstadı';

  @override
  String get badgeCrimeTitle => 'Suç & Gizem Ajanı';

  @override
  String get badgeCrimeT1 => 'Amatör Dedektif';

  @override
  String get badgeCrimeT2 => 'Suç & Gizem Ajanı';

  @override
  String get badgeCrimeT3 => 'Sherlock Seviyesi';

  @override
  String get badgeAnimationTitle => 'Animasyon & Çizgi Düşler';

  @override
  String get badgeAnimationT1 => 'Çizgi Sever';

  @override
  String get badgeAnimationT2 => 'Hayal Perdesi';

  @override
  String get badgeAnimationT3 => 'Anime & Animasyon Üstadı';

  @override
  String get badgeTurkishTitle => 'Yerli Sinema';

  @override
  String get badgeTurkishT1 => 'Yerli Sinema Dostu';

  @override
  String get badgeTurkishT2 => 'Yeşilçam Sevdalısı';

  @override
  String get badgeTurkishT3 => 'Yerli Sinema Muhafızı';

  @override
  String get badgeCriticTitle => 'Eleştirmen Serisi';

  @override
  String get badgeCriticT1 => 'Not Tutucu';

  @override
  String get badgeCriticT2 => 'Ciddi Eleştirmen';

  @override
  String get badgeCriticT3 => 'Köşe Yazarı';

  @override
  String get badgeGenerousTitle => 'Cömert Puanlayıcı';

  @override
  String get badgeGenerousT1 => 'Tam Puan Sever';

  @override
  String get badgeGenerousT2 => 'Cömert Puanlayıcı';

  @override
  String get badgeGenerousT3 => 'Başyapıt Avcısı';

  @override
  String get badgeStrictTitle => 'Zor Beğenen';

  @override
  String get badgeStrictT1 => 'Sert Eleştirmen';

  @override
  String get badgeStrictT2 => 'Zor Beğenen';

  @override
  String get badgeStrictT3 => 'Affetmeyen Jüri';

  @override
  String get badgeRewatchTitle => 'Sadık İzleyici';

  @override
  String get badgeRewatchT1 => 'Tekrar İzleyen';

  @override
  String get badgeRewatchT2 => 'Sadık İzleyici';

  @override
  String get badgeRewatchT3 => 'Fanatik Tekrarcı';

  @override
  String get badgeTagMasterTitle => 'Etiket Ustası';

  @override
  String get badgeTagMasterT1 => 'Etiket Çırağı';

  @override
  String get badgeTagMasterT2 => 'Kategori Ustası';

  @override
  String get badgeTagMasterT3 => 'Etiket Koleksiyoneri';

  @override
  String get badgeTvTitle => 'Dizi Kolik Serisi';

  @override
  String get badgeTvT1 => 'Dizi Meraklısı';

  @override
  String get badgeTvT2 => 'Dizi Kolik';

  @override
  String get badgeTvT3 => 'Dizi Müptelası';

  @override
  String get badgeSeasonTitle => 'Sezon Canavarı';

  @override
  String get badgeSeasonT1 => 'Sezon Bitişi';

  @override
  String get badgeSeasonT2 => 'Sezon Canavarı';

  @override
  String get badgeSeasonT3 => 'Maraton Ustası';

  @override
  String badgeDescLogEntries(int n) {
    return 'Günlüğe $n izleme kaydı ekle.';
  }

  @override
  String badgeDescWatchAtLeast(int n) {
    return 'En az $n film veya dizi izle.';
  }

  @override
  String badgeDescStreak(int n) {
    return 'Üst üste $n gün boyunca kayıt gir.';
  }

  @override
  String badgeDescNightWatch(int n) {
    return 'Gece 00:00 - 05:00 arasında $n izleme yap.';
  }

  @override
  String badgeDescEarlyWatch(int n) {
    return 'Sabah 06:00 - 09:00 arasında $n izleme yap.';
  }

  @override
  String badgeDescSunday(int n) {
    return 'Pazar günleri $n film/dizi izle.';
  }

  @override
  String badgeDescSingleDay(int n) {
    return 'Tek günde en az $n film/dizi izle.';
  }

  @override
  String badgeDescWinter(int n) {
    return 'Kış aylarında $n yapım izle.';
  }

  @override
  String badgeDescRetro(int n) {
    return '1980 öncesi çekilmiş $n film izle.';
  }

  @override
  String badgeDescDirector(int n, String director) {
    return '$n $director filmi izle.';
  }

  @override
  String badgeDescWestern(int n) {
    return '$n Western filmi izle.';
  }

  @override
  String badgeDescScifi(int n) {
    return '$n Bilim Kurgu yapımı izle.';
  }

  @override
  String badgeDescHorror(int n) {
    return '$n Korku/Gerilim yapımı izle.';
  }

  @override
  String badgeDescDrama(int n) {
    return '$n Drama yapımı izle.';
  }

  @override
  String badgeDescCrime(int n) {
    return '$n Suç veya Gizem yapımı izle.';
  }

  @override
  String badgeDescAnimation(int n) {
    return '$n Animasyon yapımı izle.';
  }

  @override
  String badgeDescTurkish(int n) {
    return '$n Türk yapımı izle.';
  }

  @override
  String badgeDescNotes(int n) {
    return '$n filme kişisel not yaz.';
  }

  @override
  String badgeDescPerfectScore(int n) {
    return '$n yapıma 10/10 tam puan ver.';
  }

  @override
  String badgeDescLowScore(int n) {
    return '$n yapıma 5.0 altı puan ver.';
  }

  @override
  String badgeDescRewatchNth(int n) {
    return 'Aynı içeriği $n. kez izle.';
  }

  @override
  String badgeDescRewatchTimes(int n) {
    return 'Aynı içeriği $n kez tekrar izle.';
  }

  @override
  String badgeDescRewatchRecords(int n) {
    return '$n tekrar izleme kaydı yap.';
  }

  @override
  String badgeDescTags(int n) {
    return '$n farklı kişisel etiket kullan.';
  }

  @override
  String badgeDescEpisodes(int n) {
    return '$n dizi bölümü izle.';
  }

  @override
  String badgeDescSeasons(int n) {
    return '$n dizinin tüm sezonunu tamamla.';
  }

  @override
  String get timeJustNow => 'Şimdi';

  @override
  String timeMinutesAgo(int n) {
    return '$n dk önce';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n sa önce';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n gün önce';
  }

  @override
  String get communityTitle => 'Topluluk Akışı';

  @override
  String get communityFilterAll => 'Tümü';

  @override
  String get communityFilterFollowing => 'Takip Ettiklerim';

  @override
  String get communityComposeHint => 'Bir şeyler paylaş...';

  @override
  String get communityFeedLoadFailed =>
      'Akış yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get communityEmptyTitle => 'Henüz bir gönderi yok';

  @override
  String get communityEmptyHint =>
      'Paylaşım kutusunu kullanarak ilk gönderini oluştur!';

  @override
  String get communityNotFollowingTitle => 'Henüz kimseyi takip etmiyorsunuz';

  @override
  String get communityNotFollowingHint => 'Yeni kişiler keşfedin';

  @override
  String get communityFollowingEmpty =>
      'Takip ettikleriniz henüz paylaşım yapmadı';

  @override
  String get communitySignInToLike => 'Beğenmek için lütfen giriş yapın.';

  @override
  String communityPostMood(String mood) {
    return 'Mod: $mood';
  }

  @override
  String get communityPostLoadFailed => 'Gönderi yüklenemedi.';

  @override
  String get communityShowLabel => 'Dizi';

  @override
  String get userSearchTitle => 'Kullanıcı Ara';

  @override
  String get userSearchHint => 'Kullanıcı adına göre ara...';

  @override
  String get userSearchPrompt => 'Kullanıcı adına göre arama yapın.';

  @override
  String get userSearchNotFound => 'Kullanıcı Bulunamadı';

  @override
  String get userSearchFailed => 'Arama tamamlanamadı. Lütfen tekrar deneyin.';

  @override
  String get userUnknown => 'Bilinmeyen Kullanıcı';

  @override
  String get followFollow => 'Takip Et';

  @override
  String get followUnfollow => 'Takibi Bırak';

  @override
  String get followFailed =>
      'Takip durumu güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get cineTwinSeeMatch => 'CineTwin Uyumunu Gör';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String commentsTitleWithCount(int count) {
    return 'Yorumlar ($count)';
  }

  @override
  String get commentsLoadFailed => 'Yorumlar yüklenemedi.';

  @override
  String get commentsEmpty => 'İlk yorumu sen yaz!';

  @override
  String get commentsHint => 'Yorum yaz...';

  @override
  String get commentsSignInHint => 'Yorum yazmak için giriş yapın';

  @override
  String get commentsDeleteTitle => 'Yorumu Sil?';

  @override
  String get commentsDeleteConfirm =>
      'Bu yorumu silmek istediğinize emin misiniz?';

  @override
  String get shareOptionsTitle => 'Ne Paylaşmak İstersin?';

  @override
  String get shareMovieTitle => 'Film Paylaş';

  @override
  String get shareMovieSubtitle => 'İzlediğin tek bir film veya diziyi paylaş.';

  @override
  String get shareDiaryTitle => 'Günlüğünü Paylaş';

  @override
  String get shareDiarySubtitle => 'Paylaşacağın kayıtları toplu olarak seç.';

  @override
  String get shareCollectionTitle => 'Koleksiyon Paylaş';

  @override
  String get shareCollectionSubtitle => 'Koleksiyonunu canlı olarak paylaş.';

  @override
  String get shareCollectionWebUnavailable =>
      'Bu özellik web\'de kullanılamıyor.';

  @override
  String get shareCollectionPickPrompt =>
      'Toplulukla paylaşmak istediğin koleksiyonu seç.';

  @override
  String get shareCollectionNone => 'Henüz bir koleksiyonun yok.';

  @override
  String get shareMoviePickPrompt =>
      'Toplulukla paylaşmak istediğin bir film/dizi seç.';

  @override
  String get shareDiaryPickPrompt =>
      'Bu gönderide paylaşmak istediğin kayıtları işaretle.';

  @override
  String get shareNoRecords => 'Henüz bir izleme kaydın yok.';

  @override
  String get shareContinue => 'Devam Et';

  @override
  String get shareSubmit => 'Paylaş';

  @override
  String get shareComposeMovieHint => 'Bu film hakkında ne düşünüyorsun?';

  @override
  String get shareComposeDiaryHint => 'Bu günlük hakkında bir şeyler yaz...';

  @override
  String get shareComposeCollectionHint =>
      'Bu koleksiyon hakkında bir şeyler yaz...';

  @override
  String get shareSignInRequired => 'Lütfen önce giriş yapın.';

  @override
  String get shareSucceeded => 'Paylaşıldı.';

  @override
  String get shareFailed => 'Paylaşılamadı. Lütfen tekrar deneyin.';

  @override
  String get sharedCollectionTitle => 'Koleksiyon';

  @override
  String get sharedCollectionUnshared => 'Bu koleksiyon artık paylaşılmıyor';

  @override
  String get sharedCollectionEmpty => 'Bu koleksiyonda henüz film yok.';

  @override
  String get sharedCollectionLoadFailed => 'Koleksiyon yüklenemedi.';

  @override
  String get publicDiaryEmpty => 'Paylaşılmış bir kayıt yok.';

  @override
  String userSearchNoMatch(String query) {
    return '\"$query\" ile eşleşen bir kullanıcı yok.';
  }

  @override
  String userFollowerCount(int count) {
    return '$count takipçi';
  }

  @override
  String communityDiaryEntriesLink(int count) {
    return '$count film/dizi · Günlüğü gör';
  }

  @override
  String shareEntriesCount(int count) {
    return '$count kayıt paylaşılacak';
  }

  @override
  String get graphTitle => 'İlişki Ağı';

  @override
  String get graphLoading => 'Bağlantılar analiz ediliyor…';

  @override
  String get graphLoadFailed =>
      'Bağlantılar yüklenemedi. İnternet bağlantını kontrol edip tekrar dene.';

  @override
  String get graphEmptyTitle => 'İlişki Ağı henüz boş';

  @override
  String get graphEmptyBody =>
      'Ortak oyuncu veya yönetmeni olan en az iki yapımı günlüğüne ekleyince, aralarındaki gizli bağlantılar burada otomatik olarak belirmeye başlar.';

  @override
  String get graphNoPathFound =>
      'Seçilen iki öğe arasında bağlantı bulunamadı.';

  @override
  String get graphPositionsReset =>
      'Düğüm konumları otomatik dizilime sıfırlandı.';

  @override
  String get graphProfileLookupFailed => 'Profil aranırken bir hata oluştu.';

  @override
  String get graphClusterUnconnected => 'Bağlantısız';

  @override
  String get graphNodeMovie => 'Film';

  @override
  String get graphNodeShow => 'Dizi';

  @override
  String get graphNodeActor => 'Oyuncu';

  @override
  String get graphNodeDirector => 'Yönetmen';

  @override
  String get graphNodeWriter => 'Senarist';

  @override
  String get graphNodeProducer => 'Yapımcı';

  @override
  String get graphNodeCompany => 'Yapım Şirketi';

  @override
  String get graphNodeGenre => 'Tür';

  @override
  String get graphFilterActors => 'Oyuncular';

  @override
  String get graphFilterDirectors => 'Yönetmenler';

  @override
  String get graphDepthLeads => 'Başroller';

  @override
  String get graphDepthFeatured => 'Öne çıkanlar';

  @override
  String get graphDepthFullCast => 'Tüm kadro';

  @override
  String get graphCastDepth => 'Kadro derinliği';

  @override
  String get graphSearch => 'Ara';

  @override
  String get graphSearchHint => 'Ara…';

  @override
  String get graphSearchInGraphHint => 'Graf içerisinde ara…';

  @override
  String get graphFindConnection => 'Bağlantı bul';

  @override
  String get graphResetPositions => 'Konumları sıfırla';

  @override
  String get graphFitToScreen => 'Ekrana sığdır';

  @override
  String get graphAddPerson => 'Kişi Ekle';

  @override
  String get graphAddPersonHint => 'Oyuncu / yönetmen adı…';

  @override
  String get graphAddPersonRole => 'Rol:';

  @override
  String get graphAddPersonSearchPrompt => 'Aramak için yazmaya başla.';

  @override
  String get graphHideFromGraph => 'Grafta Gizle';

  @override
  String get graphOpenDetail => 'Detaya git';

  @override
  String get graphOpenProfile => 'Profili aç';

  @override
  String get graphWhyConnected => 'Neden bağlı?';

  @override
  String get graphWhyConnectedTitle => 'Neden Bağlı?';

  @override
  String get graphRemoveConnection => 'Bu bağlantıyı kaldır';

  @override
  String get graphDiscoverRecommendations => 'Keşfet (Öneriler)';

  @override
  String get graphInsightsTitle => 'İçgörüler';

  @override
  String graphInsightMostCentral(String name, int count) {
    return 'En merkezi: $name ($count yapım)';
  }

  @override
  String get pathFinderTitle => 'Bağlantı Yolunu Bul';

  @override
  String get pathFinderHeader => 'Bağlantı Köprüsü Bul (6 Derece)';

  @override
  String get pathFinderExplain =>
      'Seçeceğin iki yapım veya kişi arasındaki en kısa ortak oyuncu/yönetmen zincirini bulur.';

  @override
  String get discoverRecommendationsFailed => 'Öneriler yüklenemedi.';

  @override
  String get discoverSubtitle =>
      'İzlediğin yapımlar ve kaçırmaman gereken öneriler';

  @override
  String discoverWatchedCount(int count) {
    return 'Kütüphanendeki Yapımlar ($count)';
  }

  @override
  String get discoverAllWatched =>
      'Bu oyuncunun öne çıkan diğer tüm ana projelerini zaten izlemişsin! Bravo! 🎉';

  @override
  String get cineDnaTitle => 'CineDNA Analitiği';

  @override
  String cineDnaAnchorSubtitle(int count) {
    return 'Kütüphanendeki $count farklı yapımı birbirine bağlıyor.';
  }

  @override
  String get cineDnaPersonaAuteurTitle => 'Yönetmen Odaklı';

  @override
  String get cineDnaPersonaAuteurDescription =>
      'Favori yönetmenlerinin tüm filmografisini eksiksiz takip ediyorsun.';

  @override
  String get cineDnaPersonaActorHunterTitle => 'Oyuncu Takipçisi';

  @override
  String get cineDnaPersonaActorHunterDescription =>
      'Sevdiğin oyuncuların izini sürerek yeni yapımlara yelken açıyorsun.';

  @override
  String get cineDnaPersonaFranchiseTitle => 'Evren Kaşifi';

  @override
  String get cineDnaPersonaFranchiseDescription =>
      'Devam yapımları ve sinematik evrenleri eksiksiz tamamlıyorsun.';

  @override
  String get cineDnaPersonaCriticTitle => 'Seçici Eleştirmen';

  @override
  String get cineDnaPersonaCriticDescription =>
      'Puan ortalaman çok yüksek; sadece en kaliteli yapımları kütüphanene alıyorsun.';

  @override
  String get cineTwinTitle => 'CineTwin Uyum Analizi';

  @override
  String get cineTwinYou => 'Sen';

  @override
  String get cineTwinMatchLabel => 'UYUM';

  @override
  String get cineTwinNotEnoughData =>
      'Uyum hesabı için henüz yeterli izleme verisi bulunmuyor.';

  @override
  String get cineTwinSharedTitles => 'Ortak Film';

  @override
  String get cineTwinRatingGap => 'Farklı Puan';

  @override
  String get cineTwinSharedRecommendation => 'Ortak Öneri';

  @override
  String get cineTwinShareCard => 'Uyum Kartını Paylaş';

  @override
  String get cineTwinWhatToWatch => 'Bu Akşam Birlikte Ne İzlemelisiniz?';

  @override
  String cineTwinCopied(int percentage) {
    return 'CineTwin Uyum Skoru (%$percentage) panoya kopyalandı!';
  }

  @override
  String get cineTwinBadgeSoulmatesTitle => 'Sinematik Ruh İkizi';

  @override
  String get cineTwinBadgeSoulmatesDescription =>
      'Film zevkleriniz ve puanlarınız neredeyse %100 birebir örtüşüyor!';

  @override
  String get cineTwinBadgeBuddiesTitle => 'Sinema Bilet Ortağı';

  @override
  String get cineTwinBadgeBuddiesDescription =>
      'Birlikte harika film akşamları yapabileceğiniz yüksek uyum.';

  @override
  String get cineTwinBadgeGenreMatchTitle => 'Tür Kardeşi';

  @override
  String get cineTwinBadgeGenreMatchDescription =>
      'Benzer türdeki yapımlardan hoşlanıyorsunuz.';

  @override
  String get cineTwinBadgeComplementsTitle => 'Karşıt Zevkler';

  @override
  String get cineTwinBadgeComplementsDescription =>
      'Birbirinizi farklı film türleriyle besleyen harika bir denge.';

  @override
  String get cineTwinBadgeOppositesTitle => 'Farklı Dünyaların İnsanları';

  @override
  String get cineTwinBadgeOppositesDescription =>
      'Zevkleriniz çok farklı veya henüz yeterli ortak veri yok.';

  @override
  String cineTwinReasonRated(String name, String rating) {
    return '$name bu filme $rating puan verdi';
  }

  @override
  String cineTwinReasonRatedHighly(String name) {
    return '$name bu filme yüksek puan verdi';
  }

  @override
  String graphClusterNamed(String name) {
    return '$name kümesi';
  }

  @override
  String graphPathFound(int steps) {
    return '$steps Adımda Bağlantı Bulundu';
  }

  @override
  String graphSearchingProfile(String name) {
    return '$name profili aranıyor…';
  }

  @override
  String graphProfileNotFound(String name) {
    return '$name için profil bulunamadı.';
  }

  @override
  String graphSummary(int titles, int people) {
    return '$titles yapım · $people köprü';
  }

  @override
  String graphInsightBiggestCluster(String name) {
    return ' · en büyük: $name';
  }

  @override
  String graphInsightStrongestPair(String a, String b, int weight) {
    return 'En bağlı: $a ↔ $b ($weight)';
  }

  @override
  String graphConnectedByPeople(int count) {
    return '$count ortak kişi ile bağlı';
  }

  @override
  String graphConnectsTitles(int count) {
    return '$count yapımı birbirine bağlıyor';
  }

  @override
  String graphSharedPeopleCount(int count) {
    return '$count ortak kişi';
  }

  @override
  String graphPersonAdded(String name, String title) {
    return '$name, \"$title\" yapımına eklendi.';
  }

  @override
  String graphAddPersonPrompt(String title) {
    return '\"$title\" yapımına bağlanacak kişiyi ara.';
  }

  @override
  String graphExplainDirector(String person, String title) {
    return '$person, $title projesine yönetmen koltuğunda imza atmıştır.';
  }

  @override
  String graphExplainActor(String person, String title) {
    return '$person, $title projesinin kadrosunda oyuncu olarak yer almaktadır.';
  }

  @override
  String get pathFinderStart => '1. Başlangıç (Yapım veya Kişi)';

  @override
  String get pathFinderTarget => '2. Hedef (Yapım veya Kişi)';

  @override
  String discoverEngineTitle(String name) {
    return '$name — Keşif Motoru';
  }

  @override
  String get discoverUnwatchedPopular =>
      '⭐ Henüz İzlemediğin Popüler Yapımları';

  @override
  String get cineDnaBackbone => '👑 Kütüphanenin Omurgası';

  @override
  String get cineDnaTotalTitles => '🎬 Toplam Yapım';

  @override
  String get cineDnaConnectionNetwork => '🔗 Bağlantı Ağı';

  @override
  String get cineDnaTopBridges => '🌉 En Etkili Bağlantı Köprüleri';

  @override
  String cineDnaConnectionCount(int count) {
    return '$count Bağlantı';
  }

  @override
  String get cineTwinSharedFavorites => '❤️ İkinizin de Sevdiği Yapımlar';

  @override
  String get cineTwinBigDisputes => '⚡ Büyük Puan Ayrılıkları';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navDiscover => 'Keşfet';

  @override
  String get navDiary => 'Günlük';

  @override
  String get navCommunity => 'Topluluk';

  @override
  String get navGraph => 'Ağ';

  @override
  String get homeGreetingMorning => 'Günaydın, ☀️';

  @override
  String get homeGreetingDay => 'İyi Günler, 👋';

  @override
  String get homeGreetingEvening => 'İyi Akşamlar, 🌙';

  @override
  String get homeGreetingNight => 'İyi Geceler, 🌌';

  @override
  String get homeRecentlyAdded => 'Son Eklediklerim';

  @override
  String get homeNothingAdded => 'Henüz kütüphanene film eklemedin.';

  @override
  String get homeSeeAll => 'Tümünü Gör';

  @override
  String get homeHeroLastWatched => 'SON İZLEDİĞİN';

  @override
  String get homeHeroWhatToWatch => 'BU HAFTA NE İZLESEM?';

  @override
  String get homeHeroMovieBadge => 'FİLM';

  @override
  String get homeHeroShowBadge => 'DİZİ';

  @override
  String get homeHeroDetails => 'Detayları İncele';

  @override
  String get homeContinueWatching => 'İZLEMEYE DEVAM ET';

  @override
  String get homeContinue => 'Devam Et';

  @override
  String homeNextEpisode(int episode) {
    return 'Sıradaki: Bölüm $episode';
  }

  @override
  String homeNextEpisodeOf(int episode, int total) {
    return 'Sıradaki: Bölüm $episode / $total';
  }

  @override
  String get homeStatsHeader => 'ÖZET & İSTATİSTİKLER';

  @override
  String get homeStatsTotalWatches => 'Toplam İzleme';

  @override
  String get homeStatsTitlesUnit => 'yapım';

  @override
  String get homeStatsAverageRating => 'Ortalama Puan';

  @override
  String get homeStatsWeeklyGoal => 'Haftalık Hedef';

  @override
  String get homeStatsWeeklyGoalCaps => 'HAFTALIK HEDEF';

  @override
  String get homeStatsGoalDoneCaps => 'HEDEF TAMAM';

  @override
  String get homeStatsAddFirst => 'İlk izlemeni kütüphanene ekle!';

  @override
  String get homeStatsGoalReached => 'Tebrikler, haftalık hedefine ulaştın! 🎉';

  @override
  String homeStatsGoalRemaining(int count) {
    return 'Bu hafta $count film/dizi daha izlemelisin.';
  }

  @override
  String get activelyWatchingTitle => 'Aktif İzlediklerin';

  @override
  String homeStreakDays(int count) {
    return '$count Gün';
  }

  @override
  String get homeAddOneEpisode => '+1 Bölüm';

  @override
  String episodeOf(int episode, int total) {
    return 'Bölüm $episode / $total';
  }

  @override
  String episodeSingle(int episode) {
    return 'Bölüm $episode';
  }

  @override
  String get datePickerTitle => 'Tarih Seçin';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get tierLocked => 'Kilitli';

  @override
  String get tierBronze => 'Bronz';

  @override
  String get tierSilver => 'Gümüş';

  @override
  String get tierGold => 'Altın';

  @override
  String get tierPlatinum => 'Platin';

  @override
  String badgeTierLevel(String symbol, String tier, int current, int max) {
    return '$symbol $tier (Seviye $current/$max)';
  }

  @override
  String achievementsCategoryCount(String category, int count) {
    return '$category ($count)';
  }

  @override
  String get insightsEmptyBody =>
      'Grafiklerin ve istatistiklerin oluşturulabilmesi için günlüğünüze en az 1 adet izleme kaydı eklemelisiniz.';

  @override
  String achievementsShowing(int count) {
    return '$count Başarım Gösteriliyor';
  }

  @override
  String get badgeLockedLabel => '🔒 Kilitli';

  @override
  String badgeCurrentCount(int count) {
    return '$count Yapım';
  }

  @override
  String badgeNextTier(int remaining, String tier) {
    return '$remaining yapım daha ➔ \"$tier\" seviyesine yüksel!';
  }

  @override
  String badgeCopied(String title) {
    return '\"$title\" başarımı panoya kopyalandı! Sosyal medyada paylaşabilirsiniz.';
  }

  @override
  String heatmapYearTotal(int year, int count) {
    return '$year içinde $count İzleme';
  }

  @override
  String heatmapEpisodesCount(int count) {
    return '$count Dizi Bölümü';
  }

  @override
  String get insightsBadgesTitle => '🏆 Başarılar & Rozetler';

  @override
  String insightsBadgesEarned(int unlocked, int total) {
    return '$unlocked / $total Kazanıldı';
  }

  @override
  String get insightsTopTagsTitle => '🏷️ En Sık Kullanılan Etiketler';

  @override
  String insightsDistinctTags(int count) {
    return '$count Farklı Etiket';
  }

  @override
  String insightsWatchesWithPercent(int count, String percent) {
    return '$count İzleme ($percent%)';
  }

  @override
  String get insightsSeasonalTitle => '📅 Mevsimsel Dağılım';

  @override
  String get insightsSeasonWinterLong => '❄️ Kış (Ara-Oca-Şub)';

  @override
  String get insightsSeasonSpringLong => '🌱 İlkbahar (Mar-Nis-May)';

  @override
  String get insightsSeasonSummerLong => '☀️ Yaz (Haz-Tem-Ağu)';

  @override
  String get insightsSeasonAutumnLong => '🍂 Sonbahar (Eyl-Eki-Kas)';

  @override
  String get weeklyGoalTitle => '🎯 Haftalık İzleme Hedefi';

  @override
  String weeklyGoalProgress(int count, int goal) {
    return 'Bu hafta $count film/dizi izlediniz. (Hedef: $goal)';
  }

  @override
  String weeklyGoalItemsCount(int count) {
    return '$count İçerik';
  }

  @override
  String get timeVisualizerTitle => '🍿 Bu Sürede Neler Yapabilirdin?';

  @override
  String get timeVisualizerFooter =>
      'Ama film/dizi izlemek de harika bir tercih! 🎬';

  @override
  String timeCompareLotr(String n) {
    return 'Yüzüklerin Efendisi (Uzatılmış Versiyon) Üçlemesi\'ni aralıksız $n kez baştan sona izleyebilirdin!';
  }

  @override
  String timeCompareFlight(String n) {
    return 'İstanbul - Londra arası uçakla tam $n kez gidiş-dönüş seyahat edebilirdin!';
  }

  @override
  String timeCompareBreakingBad(String n) {
    return 'Kült dizi Breaking Bad\'i baştan sona tam $n kez maraton yapabilirdin!';
  }

  @override
  String timeCompareWalk(String n) {
    return 'Hiç durmadan yürüyerek İstanbul\'dan Ankara\'ya tam $n kez gidip gelebilirdin!';
  }

  @override
  String timeCompareBooks(String n) {
    return 'Ortalama 8 saatlik okuma süresiyle tam $n adet kitap bitirebilirdin!';
  }

  @override
  String timeCompareFood(String n) {
    return 'Arka arkaya hiç durmadan tam $n lahmacun yiyebilirdin! (Afiyet olsun)';
  }

  @override
  String timeCompareIss(String n) {
    return 'Uluslararası Uzay İstasyonu (ISS) Dünya\'nın etrafında tam $n tur atardı!';
  }

  @override
  String timeCompareLight(String n) {
    return 'Bu sürede ışık uzay boşluğunda tam $n milyon kilometre yol alırdı!';
  }

  @override
  String timeCompareMinecraft(String n) {
    return 'Minecraft\'ta hiç durmadan tam $n blok yerleştirebilirdin!';
  }

  @override
  String timeCompareCoffee(String n) {
    return 'Arkadaşlarınla sohbet edip tam $n fincan kahve içebilirdin!';
  }

  @override
  String timeCompareMusic(String n) {
    return 'Spotify\'da favori çalma listenden tam $n şarkı dinleyebilirdin!';
  }

  @override
  String timeCompareMonopoly(String n) {
    return 'Hiç bitmeyecekmiş gibi hissettiren tam $n Monopoly partisi yapabilirdin!';
  }

  @override
  String timeCompareSleep(String n) {
    return 'Deliksiz ve huzurlu bir şekilde tam $n gece uykusu çekebilirdin!';
  }

  @override
  String timeCompareHair(String n) {
    return 'Bu sürede saç tellerin toplamda tam $n milimetre uzardı!';
  }

  @override
  String timeCompareCells(String n) {
    return 'Vücudun sen ekran karşısındayken tam $n milyon yeni hücre üretti!';
  }

  @override
  String timeCompareOrbit(String n) {
    return 'Dünya güneşin etrafındaki yörüngesinde tam $n bin kilometre yol katetti!';
  }

  @override
  String recordEpisodesCount(int count) {
    return '$count Bölüm';
  }

  @override
  String recordYearDirector(String year, String director) {
    return '$year • $director';
  }

  @override
  String get yearUnknown => 'Bilinmeyen Yıl';

  @override
  String get directorMissing => 'Yönetmen Yok';

  @override
  String watchNumber(int number) {
    return '$number. İzleme';
  }

  @override
  String journalMoviesCount(int count) {
    return '$count Film';
  }

  @override
  String durationDays(int days) {
    return '${days}g';
  }

  @override
  String durationHours(int hours) {
    return '${hours}s';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}dk';
  }

  @override
  String collectionTotalWatched(int total, int watched) {
    return '$total Film • $watched İzlenen';
  }

  @override
  String collectionProgressPercent(int percent) {
    return '%$percent İzlendi';
  }

  @override
  String get collectionsEmptyHint =>
      'Kendinize özel film listeleri oluşturarak (Örn: En İyi Nolan Filmleri, İzlenecek Animeler) sinema keyfinizi kişiselleştirebilirsiniz.';

  @override
  String get collectionDeleteConfirm =>
      'Bu koleksiyonu silmek istediğinize emin misiniz? İçindeki filmler ve sıralamanız tamamen silinecektir. (Veritabanındaki filmleriniz kaybolmaz).';

  @override
  String get marathonTitle => '🏁 Maraton Mücadelesi';

  @override
  String journalTotalTimeSpent(int hours, int minutes) {
    return 'Bu listedeki filmleri izlemek için toplam $hours Saat $minutes Dakika harcadınız.';
  }

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

  @override
  String get onboardingTitleWelcome => 'CineFile\'a Hoş Geldin';

  @override
  String get onboardingSubtitleWelcome =>
      'Kişisel izleme günlüğünü ve sinema zevkini yapılandırarak başla.';

  @override
  String get onboardingStepPreferences => '1. Tercihler';

  @override
  String get onboardingStepFavorites => '2. İlk Favoriler';

  @override
  String get onboardingStepTour => '3. Özellikler ve Gizlilik';

  @override
  String get onboardingNext => 'Devam Et';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingFinish => 'CineFile\'a Başla';

  @override
  String get onboardingFavoritesSubtitle =>
      'İzlediğin veya sevdiğin birkaç yapımı arayarak favorilerine ekle.';

  @override
  String get onboardingFavoritesSearchHint => 'Film veya dizi ara...';

  @override
  String get onboardingFeature1Title => 'Çoklu İzleme ve Sezon Takibi';

  @override
  String get onboardingFeature1Desc =>
      'Aynı filmi tekrar izlesen bile ayrı kaydet. Dizilerde kaldığın bölümü tek dokunuşla ilerlet.';

  @override
  String get onboardingFeature2Title => 'İçgörüler ve Rozetler';

  @override
  String get onboardingFeature2Desc =>
      'GitHub tarzı izleme yoğunluğu haritanı, puan dağılımını ve en sevdiğin oyuncuları keşfet.';

  @override
  String get onboardingFeature3Title => 'Gizlilik Önce Gelir';

  @override
  String get onboardingFeature3Desc =>
      'İzleme kayıtların varsayılan olarak gizlidir. İstediğin zaman JSON olarak dışa aktar veya toplulukta paylaş.';

  @override
  String get settingsRerunOnboarding => 'Uygulama Turunu Başlat';

  @override
  String get journalAddFirstRecordCTA => 'İlk Kaydını Ekle';

  @override
  String get journalClearFiltersCTA => 'Filtreleri Temizle';

  @override
  String get collectionAddMoviesCTA => 'Film/Dizi Ekle';

  @override
  String get communityFollowingEmptyHint =>
      'Takip ettiğin kullanıcılar henüz izleme kaydı paylaşmadı. Yeni arkadaşlar keşfedebilirsin.';

  @override
  String get checklistTitle => 'Hoş Geldin! Başlangıç Rehberi';

  @override
  String checklistProgress(int completed, int total) {
    return '$completed/$total Tamamlandı';
  }

  @override
  String get checklistStep1 => 'İzleme bölgeni ve dilini belirle';

  @override
  String get checklistStep2 => 'İlk film veya dizi kaydını ekle';

  @override
  String get checklistStep3 => 'En sevdiğin yapımı favorilerine ekle';

  @override
  String get checklistStep4 => 'İlk koleksiyonunu oluştur veya arkadaş edin';

  @override
  String get quickActionTitle => 'Hızlı İşlemler';

  @override
  String get quickActionAddRecord => 'İzleme Kaydı Ekle';

  @override
  String get quickActionToggleFavorite => 'Favorilere Ekle / Çıkar';

  @override
  String get quickActionViewDetail => 'Detayları Gör';

  @override
  String get errorOfflineTitle => 'Çevrimdışısınız';

  @override
  String get errorOfflineSubtitle =>
      'İzleme kayıtların cihazında güvende. İnternet bağlandığında toplulukla senkronize edilecek.';

  @override
  String get errorGenericTitle => 'Bir Hata Oluştu';

  @override
  String get errorRetryCTA => 'Tekrar Deneyin';

  @override
  String get privacyCenterTitle => 'Gizlilik Merkezi';

  @override
  String get privacyCenterSubtitle =>
      'Verilerinin nerede saklandığını ve nasıl yönetildiğini şeffafça gör.';

  @override
  String get privacyLocalSection => 'Yerel Veriler (Cihaz İçi)';

  @override
  String get privacyLocalDesc =>
      'İzleme günlüğün, notların ve puanların cihazındaki yerel SQLite veritabanında saklanır. İnternet olmadan da erişilebilir.';

  @override
  String get privacyCloudSection => 'Bulut Senkronizasyonu';

  @override
  String get privacyCloudDesc =>
      'Favori listelerin ve profil bilgilerin Firebase Firestore ile cihazların arasında güvenle senkronize edilir.';

  @override
  String get privacyPublicSection => 'Topluluk ve Gizlilik Modelimiz';

  @override
  String get privacyPublicDesc =>
      'Tüm kayıtların varsayılan olarak GİZLİDİR. Sadece açık paylaşmayı seçtiğin gönderiler toplulukta görünür.';

  @override
  String get privacyExportCTA => 'Verilerimi JSON Olarak İndir';

  @override
  String get wrappedTitle => 'CineFile Özet';

  @override
  String get wrappedIntro => 'Sinema Yolculuğun';

  @override
  String get wrappedTotalTime => 'Toplam İzleme Süresi';

  @override
  String wrappedTotalHours(int hours) {
    return '$hours Saat';
  }

  @override
  String get wrappedTopGenres => 'En Çok İzlediğin Türler';

  @override
  String get wrappedTopDirector => 'Favori Yönetmenin';

  @override
  String get wrappedTopActor => 'Favori Oyuncun';

  @override
  String get wrappedShareCTA => 'Özet Kartını Paylaş';

  @override
  String get wrappedPostCommunity => 'Toplulukta Paylaş';

  @override
  String get wrappedCopiedToast => 'Özet metni panoya kopyalandı!';

  @override
  String get insightsFilterAllYears => 'Tüm Yıllar';

  @override
  String get insightsFilterAllTypes => 'Tüm Yapımlar';

  @override
  String get insightsFilterMoviesOnly => 'Sadece Filmler';

  @override
  String get insightsFilterTvOnly => 'Sadece Diziler';

  @override
  String get privacyDeleteAccountCTA => 'Tüm Verilerimi Cihazdan Sil';

  @override
  String get privacyDeleteConfirmTitle => 'Tüm Veriler Silinecek';

  @override
  String get privacyDeleteConfirmDesc =>
      'Cihazınızdaki tüm izleme günlükleri, notlar ve yerel veriler kalıcı olarak sıfırlanacaktır. Bu işlem geri alınamaz.';
}

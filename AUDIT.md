# CineFile — Kıdemli Mimari & Ürün Denetimi

**Denetlenen sürüm:** `main` @ `079d209`, `pubspec` sürümü `1.7.2+12`
**Kapsam:** 397 dosya, ~57.8k satır Dart (üretilen kod dahil), `firestore.rules`, CI, deploy, web/gh-pages çıktısı
**Doğrulama:** `flutter analyze` → **0 issue**; `flutter test` → **163/163 geçti**

> Bu raporda "Doğrulandı" ibaresi, iddiayı dosyayı okuyarak veya komut çalıştırarak teyit ettiğim anlamına gelir. "Doğrulanamadı" ibaresi, elimdeki bilgiyle kesin konuşamadığım anlamına gelir — tahmin yürütmedim.

---

## ⚑ Uygulama Durumu — Faz 0 tamamlandı

Denetimden sonra **Faz 0 (acil güvenlik)** uygulandı. Aşağıdaki maddeler artık **düzeltilmiş** durumda; raporun geri kalanı denetim anındaki hâli anlatır ve tarihsel kayıt olarak korunmuştur.

| Madde | Durum | Doğrulama |
|---|---|---|
| **T4** Silinen koleksiyonun Firestore aynası kalıyor | ✅ Düzeltildi | `collection_sharing_test.dart`'a 2 test eklendi; düzeltme geri alındığında test düşüyor (teyit edildi) |
| **T2** `username` sunucuda claim'e bağlı değil | ✅ Düzeltildi | `usernameIsClaimedByOwner/OnCreate` + 11 kural testi |
| **T3** Post/log/yorum yazar alanları doğrulanmıyor | ✅ Düzeltildi | `authorFieldsAreOwn` + `socialCountersStartEmpty` |
| **§5.5** Avatar URL'i serbest metin (izleme pikseli riski) | ✅ Düzeltildi | `isAllowedAvatar` allowlist |
| **T27** Alan boyutu sınırı yok | ✅ Düzeltildi | `withinTextLimits` + profil/yorum sınırları |
| **T5** `firestore.rules` testsiz | ✅ Eklendi | `test_rules/` — **49 test**, CI'da ayrı job |
| **T1** TMDb anahtarı derlemeye gömülü | ⚠️ Kısmen | Kod `--dart-define=TMDB_API_KEY` destekliyor, `yayinla.bat` ayrı web anahtarı zorunlu kılıyor. **Mevcut anahtarın TMDb panelinden iptali hâlâ sizde** — yayındaki kopya geri alınamaz |

**Denetim sırasında görülmemiş, uygulama sırasında bulunan bir bug:**

`graph_overrides_provider.dart` global "gizlenen kişiler" dokümanı için `__global__` id'sini kullanıyordu. Firestore `__.*__` kalıbındaki doküman id'lerini rezerve sayıp `INVALID_ARGUMENT` ile reddeder — yani **"Grafikten gizle" özelliği hiç çalışmamıştı**; `hidePerson()` her çağrıda istisna fırlatıyor ve `relationship_graph_screen.dart:462` bunu yakalamıyordu. Id `global` olarak değiştirildi (eski id ile doküman hiç oluşamadığı için migration gerekmiyor) ve emülatör bazlı bir regresyon testi eklendi. Bu, kural test altyapısının ilk somut getirisi oldu.

**Ayrıca düzeltilen (aynı dosyalara dokunulduğu için):**
- `_mirrorSharedCollection` ve "paylaşımı kapat" yolundaki `unawaited` fire-and-forget yazımlar `await` edildi — paylaşım kapatma sessizce başarısız olabiliyordu.
- `initUser`, `avatarUrl`'ü null olan eski profilleri tek seferlik geri dolduruyor (yeni kuralların gerektirdiği istemci/sunucu tutarlılığı için).

**Doğrulama sonuçları (uygulama sonrası):**
```
flutter analyze   → No issues found!
flutter test      → 165/165 passed
test_rules/npm test → 49/49 passed   (eski kurallara karşı 16'sı düşüyor)
```

---

## ⚑ Uygulama Durumu — Faz 1 tamamlandı

| Madde | Durum | Not |
|---|---|---|
| **T9** Mock fallback sahte yönetmen/tür yazıyor | ✅ Düzeltildi | Uyduran blok tamamen silindi. Ayrıca offline şablon `kOfflinePlaceholderKey` ile işaretlenip `cacheMovieMetadata` tarafından reddediliyor — 2 regresyon testi |
| **T7** `watchNumber = docs.length + 1` | ✅ Düzeltildi | Log + ayar yazımı tek transaction; sayaç `movie_settings.watchCount`'ta. Eski hesaplar mevcut en yüksek numaradan bir kez tohumlanıyor |
| **T8** Web yedeği alan kaybediyor | ✅ Düzeltildi | Elle yazılan serileştirme Drift `toJson`/`fromJson`'a indirildi (~120 satır silindi) — 4 yeni test |
| **T13** Restore'da geri alma yok | ✅ Düzeltildi | Sıra yaz → doğrula → sil oldu; eksik yazımda `StateError` ile durup eski geçmişe dokunmuyor |
| **T23** Drift indeksleri yok | ✅ Eklendi | v14 migration, 4 indeks; `onCreate` ve `onUpgrade` aynı listeyi kullanıyor |
| **T24** Migration testi yok | ✅ Eklendi | `database_migration_test.dart` — v13→v14 gerçek dosya üzerinde, veri korunumu, idempotentlik, tanımsız sürüm guard'ı |
| **T19** `_mockMovies` iki kopya | ✅ Çözüldü | T9 ile birlikte kopya ortadan kalktı |

**Yan etkiler ve fark edilenler:**

- Yeni kurallar log'un `username`'inin profille eşleşmesini istediği için `BackupService._logFromJson` artık geri yükleyen hesabın kimliğini damgalıyor. Bu yapılmasaydı **başka hesaptan alınan ya da isim değişikliği öncesi alınan yedeklerin geri yüklenmesi kurallar tarafından reddedilecekti** — Faz 0 ile Faz 1 arasındaki bu etkileşim uygulama sırasında yakalandı.
- `genre_ids_migration_test.dart`'ın v12 fikstürü yalnızca `movies` tablosunu oluşturuyordu; v14 indeksleri diğer tablolara da dokunduğu için test düştü. Gerçek bir v12 veritabanında o tablolar mevcut, dolayısıyla fikstür eksikti ve gerçeğe uyduruldu.
- `_mirrorSharedCollection` ve "paylaşımı kapat" yolundaki `unawaited` yazımlar Faz 0'da `await` edilmişti; bu Faz 1'de eklenen testlerle de korunuyor.

**Kapatılmayan, bilinçli bırakılan boşluk:** çevrimdışıyken (TMDb'ye hiç ulaşılamazken) eklenen bir izleme kaydı Firestore log'una `movieTitle: "Çevrimdışı İçerik"` yazmaya devam ediyor. Yerel `movies` tablosu artık korunuyor ama log korunmuyor. Kaydı engellemek `offlineFallbackOverview` metninin kullanıcıya verdiği "yine de günlüğünüze ekleyebilirsiniz" sözünü bozardı, bu yüzden davranış değiştirilmedi — çözümü ayrı bir ürün kararı (ör. başlığı çağıran ekrandan taşımak).

**Doğrulama sonuçları (Faz 1 sonrası):**
```
flutter analyze     → No issues found!
flutter test        → 175/175 passed   (Faz 0 sonrası 165'ti)
test_rules npm test → 49/49 passed
check_localized     → temiz
```

---

## ⚑ Uygulama Durumu — Faz 2 tamamlandı

| Madde | Durum | Not |
|---|---|---|
| **T10** Sekme yeniden inşası | ✅ Düzeltildi | *Tembel* `IndexedStack`: ziyaret edilmiş sekmeler korunuyor, edilmemişler hiç kurulmuyor |
| **T6** Bildirim fırtınası | ✅ Düzeltildi | 20 sn debounce + schedule-fingerprint; ilgisiz ayar yazımı artık hiç resync tetiklemiyor |
| **T18** Graf: başlık başına 1 istek | ✅ Düzeltildi | Yeni `title_credits` tablosu (v15), 30 günlük TTL — 5 test |
| **T15** Sınırsız renk önbelleği | ✅ Düzeltildi | 256 girdiyle sınırlı, ekleme sıralı tahliye |
| **T16** `FailoverInterceptor` çıplak `Dio()` | ✅ Düzeltildi | Aynı client + kopyalanmış options + tekrar-bayrağı; timeout 1.5/3 sn → 5/10 sn |
| Streak hesabı O(n²) | ✅ Düzeltildi | `List.contains` → `Set` |
| `updateMoviesFromMapList` dedupe eksik | ✅ Düzeltildi | Diğer koldaki `_colorMapEquals` koruması buraya da eklendi |
| **T17** Layout ana izlekte | ⏸️ Yapılmadı | Gerekçe aşağıda |
| **T12** Sayfalamasız log akışı | ⏸️ Yapılmadı | Gerekçe aşağıda |

### Yapılmayan iki madde ve gerekçeleri

**T17 (force-directed layout'u isolate'e taşımak).** Ölçtüğümde beklediğim kadar baskın değil: `kMaxPersonNodes = 400` sınırı ve uyarlanabilir iterasyon bütçesi (n≥200 için 80 geçiş) en kötü durumu ~6.4M kayan nokta işlemine indiriyor ve bu **graf başına bir kez** çalışıyor, kare başına değil. Buna karşılık isolate'e taşımak `computeForceDirectedLayout`'un `GraphNode.position`'ı yerinde yazma sözleşmesini bozuyor (isolate'ler nesne paylaşamaz), yani düğüm/kenar dizilerini serileştirip ekranı asenkron hale getirmek gerekiyor — `relationship_graph_screen.dart`'ın `build` akışı ve üç render testi etkileniyor. Faz 2'nin asıl kazancı zaten T18'di (yüzlerce ağ isteği → sıfır). T17 ayrı bir adım olarak, ekran refaktörüyle birlikte yapılmalı.

**T12 (`allWatchRecordsProvider` sayfalaması).** Naif bir `limit()` **istatistikleri sessizce bozar**: `insightsProvider`, `journal_logic`, rozetler ve `recommendationsProvider` hepsi bu sağlayıcıyı "tüm geçmiş" olarak okuyor. 500 kayıtla sınırlamak, 600 kaydı olan bir kullanıcının toplam süresini ve rozet ilerlemesini yanlış gösterir — üstelik hata vermeden. Doğru çözüm sayfalama değil, **iki ayrı okuma yolu**: liste ekranları için sayfalı sorgu, istatistikler için sunucuda tutulan önceden-toplanmış bir özet dokümanı (Cloud Functions ile `logs` yazımında güncellenen). Bu Faz 4'ün (mimari) kapsamına ait, tek satırlık bir `limit` değil.

### Uygulama sırasında ortaya çıkanlar

- **Düz `IndexedStack` bir regresyon olurdu.** Beş çocuğu da anında kurar; `RelationshipGraphScreen` açılışta tüm kütüphanenin kredilerini çekmeye başlardı — kullanıcı o sekmeyi hiç açmasa bile. Tembel varyant her iki özelliği de koruyor.
- **Kredi önbelleği graf yoluna Drift bağımlılığı soktu.** `relationship_graph_render_test` daha önce veritabanına hiç dokunmuyordu; artık `titleCreditsCacheProvider`'ı `MemoryTitleCreditsCache` ile override ediyor (web zaten aynı sınıfı kullanıyor).
- **`CreditPerson.toMap` önbellek için yetersizdi.** `order` ve `episodeCount`'u bilinçli olarak atıyor (manuel eklemeler için tasarlanmış) — ama `isProminent` tam da onlara bakıyor. Ayrı bir `toCacheMap`/`fromCacheMap` çifti eklendi; aksi halde graf ikinci açılışta ilkinden daha küçük görünürdü. Bir test bunu sabitliyor.
- **`sed` ile toplu değişiklik yardımcı fonksiyonun kendi gövdesini de değiştirip sonsuz özyineleme üretti** (LRU önbelleği); yakalandı ve düzeltildi.
- Migration testleri artık sabit sürüm numarası yerine `db.schemaVersion` kullanıyor ve `rewindToV13` her yeni adımın geri alınmasını gerektiriyor — yeni bir migration eklenip buraya yansıtılmazsa test düşüyor, sessizce kapsam kaybetmiyor.

**Doğrulama sonuçları (Faz 2 sonrası):**
```
flutter analyze     → No issues found!
flutter test        → 180/180 passed   (Faz 1 sonrası 175'ti)
test_rules npm test → 49/49 passed
check_localized     → temiz
```

---

## ⚑ Uygulama Durumu — Faz 3 tamamlandı

| Madde | Durum | Not |
|---|---|---|
| **T21** Hardcoded Türkçe CI'yı atlatıyor | ✅ Düzeltildi | Tarayıcı yazımdan konuma geçti; enjekte edilen ASCII Türkçe ile doğrulandı |
| **T20** Kopya `updateWatchRecordRankings` | ✅ Düzeltildi | Tek fonksiyon + batch (50 ardışık round trip → 1) |
| **T30** Legacy `BadgeState` | ✅ Silindi | Hiçbir widget okumuyordu |
| **T28** Sessiz `catch (_) {}` | ✅ Düzeltildi | Dördü de ya loglanıyor ya kaldırıldı |
| **T32** Coverage ölçümü yok | ✅ Eklendi | CI ölçüp raporluyor; bugün %48 |
| **T19** `_mockMovies` kopyası | ✅ (Faz 1'de) | — |
| **T31** Rozet kataloğu kod içinde | ⏸️ Yapılmadı | Gerekçe aşağıda |
| **T22** Ölü `CalendarScreen` | ✅ Silindi | Ürün kararı; gerekçe aşağıda |

### Yapılmayan madde

**T31 (28 rozetin kataloğunu veriye çevirmek).** Saf bir refactor değil: rozet eşikleri ve sayma kuralları kullanıcıların **mevcut ilerlemesini** belirliyor, ve kodda bilinçli tuhaflıklar var — korku/gerilim ayrı ayrı toplanıyor (bir başlık ikisini birden taşıyorsa iki kez sayılıyor), ve bunun "değiştirmek bazı kullanıcıların ilerlemesini geriye dönük düşürür" diye yazılı bir gerekçesi var. 450 satırı veriye çevirirken bu davranışı birebir korumak mümkün ama önce her rozet için karakterizasyon testi yazmayı gerektirir — aksi halde refactor sessizce birinin rozetini geri alır. Testler olmadan yapmadım.

### T22 sonradan kapandı

**T22 (ölü `CalendarScreen`).** 372 satır, hiçbir yerden erişilemiyordu. Silmek mi bağlamak mı bir **ürün kararı** olduğu için tek taraflı karar vermemiştim; karar **silmek** yönünde verildi ve `lib/features/calendar/` kaldırıldı. `check_localized.dart`'taki "henüz çevrilmedi" muafiyeti de birlikte silindi — ekranın gün/ay adları Türkçe sabitti, yani bağlamak yerelleştirme + test işini de beraberinde getirecekti. Kod git geçmişinde duruyor; takvim görünümü ileride istenirse oradan geri alınabilir.

### Uygulama sırasında ortaya çıkanlar

- **Yeni tarayıcı, yazdığım eski tarayıcının kaçırdıklarını buldu:** `'Profil'`, `'Biyografi'`, `'Kaydet'`, `'Tamam'` ve sekiz ayrı `Text('Hata: $err')`. Hepsi çevrildi (`commonErrorWithDetail`, `profileTitle`, `profileBioLabel`, `profileBioHint` eklendi; `commonSave`/`commonOk` zaten vardı).
- **Muafiyet listesi kendiliğinden küçüldü.** Eski tarayıcı dosyanın herhangi bir yerindeki Türkçe karakteri yakaladığı için tür adı tablosu, `contains('sinema')` ve noktalı-i kuralı gibi *veri* desenlerinin tek tek muaf tutulması gerekiyordu. Yalnızca metin yuvalarına bakmak bunları yapısal olarak dışarıda bırakıyor.
- **`_formatDate`'teki try/catch yakalayacak hiçbir şeye sahip değildi** — `split` ve uzunluğu kontrol edilmiş bir indeks fırlatmaz. Kaldırıldı.

**Doğrulama sonuçları (Faz 3 sonrası):**
```
flutter analyze     → No issues found!
flutter test        → 182 passed, 1 skipped   (proxy testi direct modda atlanıyor)
flutter test --coverage → 8820/18139 satır (%48)
test_rules npm test → 49/49 passed
check_localized     → temiz (yeni, daha sıkı kuralla)
```

---

## ⚑ Uygulama Durumu — Faz 4 (kısmi)

| Madde | Durum | Not |
|---|---|---|
| **T26** Deploy manuel/Windows/force-push | ✅ Düzeltildi | `deploy.yml`: sürüm etiketiyle tetiklenir, CI kapılarını çalıştırır, geçmişi ezmez, proxy build'inde anahtar sızıntısını doğrular |
| **T14** Firestore erişimi widget'larda | 🔶 Kısmi | Topluluk yazma yolları `SocialRepository`'ye taşındı (9 test). İzleme kaydı yazma yolu hâlâ widget'ta |
| **T11** Gözlemlenebilirlik yok | ⏸️ Ortamınızı gerektiriyor | Gerekçe aşağıda |
| **T33/T34** Firestore yedeği, moderasyon | ⏸️ Ortamınızı gerektiriyor | Gerekçe aşağıda |

### Neden Faz 4 burada duruyor

**T11 (Crashlytics + App Check).** İkisi de native derleme yapılandırması istiyor (Gradle eklentisi, `google-services` bağlantısı) ve bu makinede Android SDK yok — yani ekleseydim **derlenip derlenmediğini doğrulayamazdım**. Doğrulanmamış native bağımlılık eklemek, olmamasından kötü. App Check ayrıca Firebase Console'da provider kaydı (Play Integrity / DeviceCheck / reCAPTCHA) gerektiriyor; kod tarafı onsuz zaten iş görmez. Bunlar sizin ortamınızda yapılacak işler.

**T33/T34 (Firestore yedeği, moderasyon).** Scheduled Backups ve Cloud Functions'ın ikisi de **Blaze (kullandıkça öde) planı** gerektiriyor. Projenin hangi planda olduğunu bilmiyorum ve faturalandırma planı değiştirmek benim vereceğim bir karar değil.

**T14'ün kalanı.** `add_watch_record_sheet`'in yazma yolunu da taşımak doğru olurdu ama onu Faz 1'de transaction'a çevirmiştim; taze kodu hemen yeniden taşımak yerine topluluk tarafını yaptım — orası hem üç ayrı yerde tekrarlanıyordu hem de yeni kuralların en çok bağımlı olduğu yüzey.

**Doğrulama sonuçları (Faz 4 sonrası):**
```
flutter analyze     → No issues found!
flutter test        → 191 passed, 1 skipped
test_rules npm test → 49/49 passed
check_localized     → temiz
```

---

## 1. Genel Proje Analizi

### Amaç
Film/dizi izleme günlüğü + istatistik + sosyal akış. Flutter (Android/iOS/Web/Windows), Riverpod 3, Drift/SQLite (yerel), Firebase Auth + Cloud Firestore (bulut), TMDb (içerik).

### Güçlü yönler (objektif, gözlemlenen)
- **Yorum kalitesi olağanüstü.** `tables.dart:36-44`, `app_database.dart:57-72`, `database_provider.dart:653-666` gibi yerlerde *neden* kararının gerekçesi ve hangi gerçek hatayı kapattığı yazılı. Bu, çoğu ticari kod tabanında bulunmayan bir disiplin.
- **Migration disiplini.** `AppDatabase.migration` v5+ için yıkıcı yol bırakmıyor ve tanımsız geçişte `StateError` fırlatıyor (`app_database.dart:207-213`). v8 primary-key değişimi rename→create→copy→drop ile veri kaybetmeden yapılmış.
- **`firestore.rules` ortalamanın çok üstünde.** `isOwnStarToggle` simetrik fark kontrolü (`firestore.rules:20-28`) ve `isCommentCountStep` (32-36), sadece `hasOnly` ile yetinmeyen gerçek shape doğrulaması. Çoğu projede bu yok.
- **CI gerçekten iş görüyor:** çeviri eksiği (`l10n_missing.json`), hardcoded Türkçe taraması (`tool/check_localized.dart`), analyze ve test — dördü de kapıda.
- **Test paketi anlamlı:** 47 dosya, sadece "smoke" değil; `watch_records_for_user_privacy_test.dart`, `user_public_diary_screen_frozen_test.dart` gibi davranış sözleşmesi testleri var.

### Zayıf yönler (özet — detaylar aşağıda)
| # | Sorun | Etki | Öncelik |
|---|---|---|---|
| 1 | TMDb anahtarı `gh-pages`'te açık yayında | Anahtar çalınabilir/ban | **Kritik** |
| 2 | `users.username` sunucuda `usernames` claim'ine bağlı değil | Kimliğe bürünme | **Kritik** |
| 3 | `logs`/`posts` create'inde `username`/`avatarUrl`/`starredBy` doğrulanmıyor | Feed'de sahte kimlik + sahte beğeni | **Kritik** |
| 4 | Koleksiyon silinince `shared_collections` aynası silinmiyor | Kalıcı gizlilik sızıntısı | **Kritik** |
| 5 | Her bölüm "+" dokunuşu tam bildirim resync'i tetikliyor (N× TMDb) | Pil/kota/jank | **Yüksek** |
| 6 | `watchNumber = docs.length + 1` | Silme sonrası çakışan kayıt numaraları | **Yüksek** |
| 7 | Web yedeği `tags` / `personalRanking` / `remoteId` kaybediyor | Sessiz veri kaybı | **Yüksek** |
| 8 | Mock fallback sahte yönetmen/tür yazıyor ve DB'ye kalıcılaşıyor | Bozuk kütüphane verisi | **Yüksek** |
| 9 | `MainShell` `IndexedStack` kullanmıyor | Sekme değişiminde tüm state + Firestore aboneliği yeniden kuruluyor | **Yüksek** |
| 10 | Sunum katmanı Firestore'a doğrudan yazıyor | Katman ihlali, test edilemezlik | **Orta** |
| 11 | `firestore.rules` için hiç test yok | Yetkilendirme regresyonu sessiz geçer | **Yüksek** |
| 12 | `_colorCache` statik ve hiç boşaltılmıyor | Süresiz bellek büyümesi | **Orta** |
| 13 | Gözlemlenebilirlik yok (Crashlytics/Sentry/App Check yok) | Üretimde körlük | **Yüksek** |

### Kod kalitesi / okunabilirlik / modülerlik
- **Okunabilirlik: çok iyi.** İsimlendirme tutarlı, `MovieKey` gibi tip takma adları anlamlı, `_` prefiksi doğru kullanılmış.
- **Modülerlik: orta.** `lib/features/<feature>/{domain,presentation,models}` düzeni doğru; ama `lib/core/database/database_provider.dart` (785 satır) provider + domain fonksiyonu + Firestore yazma yolu + `toggleFollow` karışımı. Adı altyapıyı ima ediyor, içeriği iş kuralı.
- **Ölçeklenebilirlik: sınırlı.** `allWatchRecordsProvider` kullanıcının **tüm** `logs` koleksiyonunu sayfalamasız dinliyor (`database_provider.dart:272-282`). 5.000 kayıtlı bir kullanıcıda her açılış 5.000 doküman okuması + tüm istatistiklerin ana izlekte yeniden hesabı demek.
- **Bakım yapılabilirlik: iyi-orta.** Yorumlar bakımı kolaylaştırıyor; ama `insights_provider.dart` (915 satır) 28 rozetin kataloğunu kod olarak taşıyor.

---

## 2. Yazılım Mimarisi

### Katmanlar
Nominal olarak `domain / presentation / data` var. Gerçekte **veri erişimi katmanlaşmamış**:

```dart
// lib/features/movie_detail/presentation/add_watch_record_sheet.dart:258
final existingRecordsQuery = await ref.read(firestoreProvider)
    .collection('logs')
    .where('userId', isEqualTo: user.uid)
    ...
final logRef = ref.read(firestoreProvider).collection('logs').doc();
await logRef.set(logData);   // 30 alanlık doküman, bir widget'ın içinde
```

Aynı desen `share_compose_sheet.dart:266`, `community_post_card.dart:42-54`, `episode_logging.dart:59-80`'de tekrarlıyor. `MovieRepository` soyutlaması sadece **yerel** tarafı kapsıyor; Firestore tarafı için karşılığı yok. Sonuç: bir doküman şeması değişince onu 6 farklı widget'ta aramak gerekiyor.

**Çözüm — `WatchLogRepository` ekleyin:**
```dart
// lib/core/data/watch_log_repository.dart
abstract class WatchLogRepository {
  Future<void> createLog(NewWatchLog log);
  Future<void> deleteLog(String remoteId);
  Future<void> updateLog(String remoteId, WatchLogPatch patch);
  Future<void> setEpisodeProgress(MovieKey key, EpisodeProgress p);
}

final watchLogRepositoryProvider = Provider<WatchLogRepository>(
  (ref) => FirestoreWatchLogRepository(ref.read(firestoreProvider)),
);
```
Kazanç: `add_watch_record_sheet` 30 satır Firestore kodundan kurtulur, `fake_cloud_firestore` olmadan test edilebilir, alan adı yazım hataları tek yerde.

### SOLID
- **S (Tek sorumluluk) — ihlal.** `MovieRepository` 15 metotla 5 ayrı konuyu taşıyor: koleksiyonlar, izleme kayıtları, yedekleme, ayarlar, paylaşım. `database_provider.dart` de aynı şekilde.
- **O (Açık/kapalı) — kısmen.** Yeni bir rozet eklemek `insights_provider.dart`'ta 900 satırlık fonksiyona dokunmayı gerektiriyor. Rozet kataloğu veri olsaydı gerekmezdi.
- **L (Liskov) — ihlal var.** `WebMovieRepository.setCollectionVisibility` sessizce `{}` (no-op) — arayüzün sözleşmesini yerine getirmiyor (`movie_repository.dart:753-754`). Yorumda "asla çağrılmayacak" yazıyor ama tip sistemi bunu garanti etmiyor.
- **I (Arayüz ayrımı) — ihlal.** Yukarıdaki S ile aynı kök: `exportBackupData` ile `addMovieToCustomList` aynı arayüzde olmamalı.
- **D (Bağımlılığın tersine çevrilmesi) — Riverpod sayesinde iyi**, ama Firestore için yok (yukarı bkz.).

### DRY ihlalleri (doğrulandı)
1. **`_mockMovies` iki kez tanımlı** — `tmdb_service.dart:51-112` ve `movie_detail_provider.dart:59-120`. ~60 satır birebir kopya.
2. **`updateWatchRecordRankings` iki kez** — `movie_repository.dart:367-393` (Native) ve `721-747` (Web). Karakter karakter aynı; ikisi de Firestore'a yazıyor, yani platforma bağlı değil. Arayüzden çıkarılıp tek serbest fonksiyona alınmalı.
3. **Yedek serileştirme iki kez** — Native `toJson()` kullanıyor, Web elle map yazıyor (`movie_repository.dart:862-920`). Bu ikilik gerçek bir bug'a yol açtı (bkz. §3.7).

### KISS / YAGNI
- `FailoverInterceptor`'ın ikinci domain'i (`api.tmdb.org`) — TMDb bunu resmi alternatif olarak listelemiyor; DoH katmanı zaten aynı sorunu çözüyor. İki mekanizma üst üste.
- `BadgeState` sınıfı `AchievementBadge`'in kaybettirici bir kopyası, "legacy" notuyla duruyor (`insights_provider.dart:12-39`). Kaldırılabilir.

### Anti-pattern'lar
- **God provider:** `database_provider.dart`.
- **Anemic + Fat karışımı:** `WatchRecordWithMovie` sadece veri taşıyor, tüm mantık provider'da.
- **Silent catch:** 6 yerde `catch (_) {}` (§3'e bkz).
- **Presentation'da iş kuralı:** `watchNumber` hesabı bir bottom sheet'in içinde.

---

## 3. Kod Kalitesi — Somut Bulgular

### 3.1 Mock fallback bozuk veri yazıyor — **Yüksek**
**Dosya:** `lib/features/movie_detail/presentation/movie_detail_provider.dart:122-133`

```dart
final mock = mockMovies.firstWhere((m) => m['id'] == arg.tmdbId);
return {
  ...mock,
  'runtime': 148,
  'genres': [{'name': 'Bilim Kurgu'}, {'name': 'Dram'}],
  'credits': {
    'cast': [{'name': 'Matthew McConaughey', 'character': ''}],
    'crew': [{'name': 'Christopher Nolan', 'job': 'Director'}]   // <-- her zaman
  }
};
```
**Sorun:** Bu blok TMDb **her başarısız olduğunda** (DNS engeli, timeout, 429) çalışıyor — anahtarsız demo moduna özel değil. Dune, Oppenheimer ve Spider-Verse dahil altı ID'nin hepsine yönetmen olarak Christopher Nolan, tür olarak "Bilim Kurgu, Dram" atıyor.

**Etki zinciri:** Bu payload `MovieDetailScreen` → `cacheMovieMetadata` → `movies` tablosuna kalıcı yazılıyor. Sonra `insights_provider.dart:588` `_countByKeyword(..., 'christopher nolan')` bunu sayıyor → kullanıcı hak etmediği "Nolan" rozetini alıyor, `topDirectors` bozuluyor, `recommendationsProvider` yanlış yönetmenden öneri çekiyor. Ayrıca `'Bilim Kurgu'`/`'Dram'` hardcoded Türkçe — `check_localized.dart` bunu yakalamıyor çünkü içinde Türkçe'ye özgü karakter yok.

**Çözüm:**
```dart
// Ağ hatası gerçek bir hatadır; uydurma metadata veri tabanına sızmamalı.
// Yalnızca API anahtarı boşken (belgelenmiş demo modu) mock'a düş.
if (ApiConstants.tmdbApiKey.isEmpty) {
  final mock = kDemoMovies.where((m) => m['id'] == arg.tmdbId).firstOrNull;
  if (mock != null) return {...mock, 'is_demo_payload': true};
}
rethrow;   // ya da 3. adımdaki offline şablonuna düş — ama kredi uydurmadan
```
Ayrıca `cacheMovieMetadata` çağrısı `is_demo_payload`/offline payload'ları reddetmeli.

---

### 3.2 `watchNumber` çakışması — **Yüksek**
**Dosya:** `lib/features/movie_detail/presentation/add_watch_record_sheet.dart:258-264`

```dart
final existingRecordsQuery = await ref.read(firestoreProvider)
    .collection('logs').where('userId', ...).where('movieId', ...).get();
final watchNumber = existingRecordsQuery.docs.length + 1;
```

**Üç ayrı sorun:**
1. **Silme sonrası çakışma.** 3 kayıt var (1,2,3) → 2 numaralıyı sil → yeni kayıt `docs.length + 1 = 3` alır. Artık iki tane "3." izleyiş var.
2. **Bu çakışma ilerleme hesabını bozuyor.** `deleteWatchRecord` (`database_provider.dart:728-730`) `watchNumber == latestWatchNumber` olanların `episodeCount`'unu topluyor. Çakışan numaralar → bölüm ilerlemesi iki katına çıkıyor → dizi "tamamlandı" sanılıp `isActivelyWatching` erken kapanıyor.
3. **Yarış + maliyet.** İki cihazdan eşzamanlı kayıt aynı numarayı alır; ayrıca her kayıt için o başlığın tüm log'ları okunuyor (N doküman okuması).

**Çözüm:** Sayacı `movie_settings` dokümanında tutup atomik artırın:
```dart
// Tek transaction: sayacı artır ve log'u aynı anda yaz.
final watchNumber = await firestore.runTransaction((tx) async {
  final snap = await tx.get(settingsRef);
  final next = ((snap.data()?['watchCount'] as num?)?.toInt() ?? 0) + 1;
  tx.set(settingsRef, {'watchCount': next}, SetOptions(merge: true));
  tx.set(logRef, {...logData, 'watchNumber': next});
  return next;
});
```
Bu hem yarışı hem N okumayı hem çakışmayı kapatır.

---

### 3.3 Bildirim senkronizasyonu her ayar yazımında tetikleniyor — **Yüksek (performans)**
**Dosyalar:** `lib/features/main_shell.dart:60-64`, `lib/core/services/notification_service.dart:302-411`

```dart
// main_shell.dart — build() içinde
ref.listen(allMovieSettingsProvider, (prev, next) {
  if (next.hasValue) {
    ref.read(notificationServiceProvider).syncNotifications();
  }
});
```
`syncNotifications` şunları yapıyor: `cancelAllReminders()` → watchlist sorgusu → **aktif izlenen her dizi için** `getMovieDetails` + `getTvSeasonDetails` (2 ağ çağrısı).

**Etki:** Kullanıcı Ana Sayfa'daki "+" ile bir bölüm ilerlettiğinde → `movie_settings` yazılır → stream emit eder → **tüm** planlı bildirimler iptal edilir ve 4 aktif dizi için 8 TMDb isteği atılır. Beş kere üst üste "+" → 40 istek. Ayrıca `next.hasValue` kontrolü değer *değişmese* de geçtiği için, aynı snapshot'ın tekrar emit'i de tetikliyor.

**Çözüm:**
```dart
// Yalnızca bildirim planını gerçekten etkileyen alanlar değiştiğinde çalıştır.
ref.listen(allMovieSettingsProvider, (prev, next) {
  final before = prev?.value, after = next.value;
  if (after == null) return;
  if (before != null && _notificationRelevantFingerprint(before) ==
                        _notificationRelevantFingerprint(after)) return;
  _debouncedSync();   // en az 30 sn debounce
});

String _notificationRelevantFingerprint(Map<MovieKey, UserMovieSetting> m) =>
    (m.entries
      .where((e) => e.value.isReWatchList || e.value.isActivelyWatching)
      .map((e) => '${e.key.tmdbId}:${e.value.lastWatchedEpisode}:${e.value.isReWatchList}')
      .toList()..sort()).join('|');
```
Ek olarak `syncNotifications` içindeki `cancelAllReminders()` → tümünü sil-yeniden kur yerine diff tabanlı olmalı.

---

### 3.4 `MainShell` sekmeleri yok ediyor — **Yüksek**
**Dosya:** `lib/features/main_shell.dart:76`
```dart
body: _screens[selectedIndex],
```
Sekme değişince önceki ağaç tamamen sökülüyor. Sonuçlar: (a) kaydırma konumu, arama metni, filtre seçimi kayboluyor; (b) Riverpod 3 dinleyicisiz provider'ı duraklattığı için `allWatchRecordsProvider` / `communityFeedProvider` aboneliği kopup yeniden kuruluyor — her sekme dönüşü tam bir snapshot okuması (Firestore faturası).

**Çözüm:**
```dart
body: IndexedStack(index: selectedIndex, children: _screens),
```
Bellek maliyeti düşük (5 ekran), kazanç hem UX hem kota.

---

### 3.5 Statik renk önbelleği hiç boşalmıyor — **Orta (bellek)**
**Dosya:** `lib/core/theme/dynamic_background_provider.dart:63`
```dart
static final Map<String, Color> _colorCache = {};
```
Anahtar = poster URL'i. Uzun bir oturumda yüzlerce/binlerce giriş birikir, hiçbir yerde `remove`/`clear` yok (`clearColors()` sadece `_visibleKeys` ve state'i temizliyor).

**Çözüm:** LRU sınırı koyun.
```dart
static final _colorCache = _LruMap<String, Color>(maxSize: 256);
```
(30 satırlık `LinkedHashMap` tabanlı LRU yeterli; `state.activePosterColors` zaten ekranda görünenlerle sınırlı.)

---

### 3.6 `FailoverInterceptor` kendi amacını baltalıyor — **Orta**
**Dosya:** `lib/core/network/dio_client.dart:113-116`
```dart
final retryDio = Dio();          // <-- çıplak Dio
final response = await retryDio.fetch(options);
```
`DioClient` yapıcısı DoH tabanlı `connectionFactory`'yi ve cache interceptor'ı **`_dio`'ya** kuruyor. Yeniden deneme çıplak bir `Dio()` ile yapıldığı için:
- DNS hijack senaryosunda (bu katmanın var olma sebebi) yeniden deneme de aynı bozuk çözümleyiciyi kullanır → kesin başarısız.
- Yanıt cache'lenmez.
- `err.requestOptions` doğrudan mutasyona uğruyor (`options.baseUrl = nextBaseUrl`), aynı `RequestOptions` cache anahtarı üretiminde kullanılmışsa yan etki riski var.

**Çözüm:** Yeniden denemeyi aynı `Dio` örneği üzerinden, kopyalanmış `RequestOptions` ile yapın:
```dart
class FailoverInterceptor extends Interceptor {
  FailoverInterceptor(this._dio);
  final Dio _dio;
  ...
  final retryOptions = options.copyWith(baseUrl: nextBaseUrl);
  final response = await _dio.fetch(retryOptions);
```
(Sonsuz döngüye karşı `retryOptions.extra['failover'] = true` bayrağı ekleyin.)

---

### 3.7 Web yedeği veri kaybediyor — **Yüksek**
**Dosya:** `lib/core/database/movie_repository.dart:879-904`

Native `exportBackupData` Drift'in `toJson()`'ını kullanıyor → tüm sütunlar. Web elle yazıyor ve **eksik**:

| Kaybolan alan | Nerede |
|---|---|
| `tags` | `watch_records` (satır 879-893) |
| `remoteId` | `watch_records` |
| `personalRanking` | `user_movie_settings` (satır 894-904) |
| `lastEpisodeProgressAt` | `user_movie_settings` |

`importBackupData`'nın web sürümü de bu alanları okumuyor (satır 931-971), yani web'de alınan yedek geri yüklendiğinde etiketler ve kişisel sıralamalar sessizce yok oluyor. Kullanıcıya hiçbir uyarı gösterilmiyor.

**Çözüm:** İki uygulamayı tek serileştiriciye indirin — Drift veri sınıfları `toJson()/fromJson()`'a zaten sahip ve web tarafı da aynı sınıfları kullanıyor:
```dart
@override
Future<Map<String, dynamic>> exportBackupData() async => {
  'version': BackupService.currentVersion,
  'movies': _ref.read(webMoviesProvider).values.map((m) => m.toJson()).toList(),
  'watch_records': _ref.read(webWatchRecordsProvider).map((r) => r.toJson()).toList(),
  'user_movie_settings': _ref.read(webMovieSettingsProvider).values.map((s) => s.toJson()).toList(),
  ...
};
```
Bu tek değişiklik ~60 satır kopya kodu da siler.

---

### 3.8 Yedek geri yüklemede geri alma yok — **Orta**
**Dosya:** `lib/core/database/backup_service.dart:97-107`
```dart
await _commitInChunks(firestore, [
  for (final doc in existing.docs) (ref: doc.reference, data: null),   // hepsini sil
  for (final entry in logs...) (ref: ..., data: _logFromJson(entry, user.uid)),
]);
```
`_commitInChunks` 400'lük parçalar halinde commit ediyor. İlk parça silmeleri içerip commit olduktan sonra ikinci parça ağ hatasıyla düşerse **kullanıcının geçmişi silinmiş, yenisi yazılmamış** olur. Geri dönüş yok, kullanıcıya da "kısmen başarısız" bildirimi gitmiyor.

**Çözüm:** Önce yaz, sonra sil sırası + doğrulama:
```dart
// 1) Yeni dokümanları yaz (yeni id'ler, çakışma yok)
await _commitInChunks(firestore, writes);
// 2) Yazımı doğrula (count query)
final written = await firestore.collection('logs')
    .where('userId', isEqualTo: uid).where('restoreBatch', isEqualTo: batchId).count().get();
if (written.count != logs.length) throw RestoreIncompleteException();
// 3) Ancak şimdi eski dokümanları sil
await _commitInChunks(firestore, deletions);
```

---

### 3.9 Sessiz `catch (_) {}` — **Orta**
6 yer (doğrulandı):
`actor_profile_screen.dart:31,35`, `actor_profile_header.dart:26`, `auth_controller.dart:265`, `movie_detail_provider.dart:56,133`.

`auth_controller.dart:265` özellikle önemli:
```dart
try { await createdUser?.delete(); } catch (_) {}
```
Bu silme başarısız olursa, profil dokümanı olmayan yetim bir Auth hesabı kalıyor. Sessizce yutuluyor — sonraki girişte `initUser` bunu telafi ediyor ama olayın hiç kaydı yok.

**Çözüm:** En azından `debugPrint` + (gözlemlenebilirlik geldiğinde) `recordError`. Boş `catch` bloğu asla kalmamalı.

---

### 3.10 Hardcoded Türkçe CI'yı atlatıyor — **Orta**
**Dosya:** `lib/features/auth/presentation/widgets/edit_profile_sheet.dart`
Satır 185 `'Biyografi'`, 198 `'Kendinden bahset...'`, 261 `'Kaydet'`, 280 `'Hata: $err'`, 313 `'Dizi'`/`'Film'`, 346 `'Tamam'`.

Bu dosya `check_localized.dart`'ın `_localizedPaths` listesindeki `lib/features/auth` altında — ama tarayıcı yalnızca `[çğıöşüÇĞİÖŞÜ]` karakterlerini arıyor (`tool/check_localized.dart:61`) ve bu kelimelerin hiçbirinde yok. Aracın kendi yorumu bu sınırı kabul ediyor ("pure ASCII Türkçe'yi yakalayamaz") ama pratikte gerçek bir kaçak var.

**Çözüm — tarayıcıyı güçlendirin:** Türkçe karakter aramak yerine, "widget ağacındaki `Text(` / `hintText:` / `label:` argümanı ARB'den gelmiyorsa" kuralına geçin:
```dart
// Text('...') veya hintText: '...' biçiminde düz literal = ihlal
final _literalInWidget = RegExp(
  r"""(Text\(\s*|hintText:\s*|labelText:\s*|title:\s*Text\(\s*)'[^']{2,}'""");
```
Bu, dil bağımsız çalışır ve `AppLocalizations.of(context).x` çağrılarını doğal olarak muaf tutar.

### 3.11 Diğer kokular
- **Ölü kod:** `lib/features/calendar/presentation/calendar_screen.dart` — 372 satır, hiçbir yerden `CalendarScreen` construct edilmiyordu. *(Sonradan silindi — bkz. T22.)*
- **`avoid_print: true` var ama 64 `debugPrint` çağrısı** yapılandırılmamış log olarak duruyor. Bunlar hata ayıklama için değerli; yapılandırılmış bir logger'a (seviye + kategori) taşınmalı.
- **`BadgeState`** "legacy, geriye dönük uyumluluk için" notuyla duruyor ama `AchievementBadge`'den türetiliyor ve UI ikisini de kullanıyor. Tek modele indirilmeli.

---

## 4. Performans Analizi

| Darboğaz | Konum | Ölçüm/Analiz | Çözüm |
|---|---|---|---|
| **Sayfalamasız log akışı** | `database_provider.dart:272-282` | Kullanıcının tüm `logs`'u snapshot dinleyicisiyle bellekte. 5k kayıt ≈ 5k doküman okuması/açılış + ~10 MB heap | `limit(500)` + "daha fazla yükle"; istatistikler için ayrı önceden-toplanmış doküman |
| **İstatistikler ana izlekte** | `insights_provider.dart:121-336` | Her log değişiminde tüm katalog + 28 rozet yeniden hesaplanıyor, O(n) × ~15 geçiş | `compute()` isolate'e taşıyın; `insightsProvider`'ı debounce edin |
| **Streak hesabı O(n²)** | `insights_provider.dart:243-252` | `uniqueDates` bir `List`; `.contains()` O(n), döngü içinde → O(n²) | `final dateSet = uniqueDates.toSet();` ile O(n) |
| **Graf: başlık başına 1 TMDb isteği** | `relationship_graph_provider.dart:37-59` | 300 başlıklı kütüphane = 300 istek (6'lı paralel = 50 tur). Yalnızca `MemCacheStore` → her uygulama açılışında sıfırdan | Kredileri Firestore'da/Drift'te kalıcı önbelleğe alın (`credits_cache/{tmdbId}_{isTv}`, TTL 30 gün) |
| **Force-directed layout senkron** | `relationship_graph_screen.dart:111` (`_body` içinde, yani `build`'de) | O(n²·iter): n=400 → ~6.4M float işlemi, ana izlekte, tek karede | `compute(computeForceDirectedLayout, graph)` + hesaplanana kadar spinner |
| **Bildirim resync fırtınası** | §3.3 | Her "+" dokunuşta 2N TMDb isteği | §3.3'teki fingerprint + debounce |
| **Sekme yeniden inşası** | §3.4 | Her sekme dönüşünde tam Firestore snapshot | `IndexedStack` |
| **Renk çıkarma** | `dynamic_background_provider.dart:127` | `ColorScheme.fromImageProvider` görseli çözüp kuantize ediyor — poster başına yüzlerce ms | Zaten önbellekli; ama önbellek sınırsız (§3.5) ve iptal edilemiyor. Kaydırma sırasında görünürlükten çıkanın işini iptal edin |
| **Agresif timeout** | `dio_client.dart:27-28` | connect 1.5 sn / receive 3 sn | Mobil 3G'de yanlış negatif üretir. connect 5 sn / receive 10 sn + failover'ı koruyun |
| **`watchRecordsForUserProvider` içindeki `asyncMap`** | `database_provider.dart:164-180` | Her `logs` snapshot'ında tüm `movie_settings` koleksiyonu yeniden `get()` ediliyor | Ayarları ayrı bir stream'de tutup manuel birleştirin (`allWatchRecordsProvider`'ın zaten yaptığı gibi) |

### Benchmark önerileri
```bash
# 1) Kare bütçesi — Journal/Insights kaydırması
flutter run --profile --trace-skia
# DevTools > Performance > "Track widget builds" ile 16 ms üstü kareleri işaretleyin

# 2) Firestore okuma sayısı (en somut maliyet metriği)
# Firebase Console > Firestore > Usage; bir "tipik oturum" senaryosunu
# (aç → 3 sekme gez → 1 bölüm ilerlet → kapat) manuel yürütüp okuma sayısını kaydedin.
# Hedef: IndexedStack + debounce sonrası %60+ düşüş.

# 3) Mikro-benchmark: insights + layout
dart run benchmark/insights_benchmark.dart   # 1k / 5k / 20k kayıt ile
```
Öneri: `test/` altına `insights_provider_perf_test.dart` ekleyip 10.000 kayıtta hesap süresine üst sınır koyun (regresyon kapısı).

---

## 5. Güvenlik Analizi

### 5.1 TMDb API anahtarı yayında — **Risk: Yüksek** ✅ Doğrulandı
`origin/gh-pages` dalındaki `main.dart.js` içinde anahtar **19 kez** geçiyor (grep ile teyit ettim). Bu dosya `https://Alp3rol.github.io/CineFile/` adresinden herkese servis ediliyor ve gh-pages geçmişinde kalıcı.

README bunu doğru şekilde belgeliyor ("tarayıcıda çalışan her istemci için geçerlidir") — ama belgelemek riski ortadan kaldırmıyor: bu, geliştiricinin **kişisel** TMDb anahtarı. Üçüncü taraflarca kazınıp kullanılırsa kota tükenmesi ve hesap askıya alınması sizin hesabınıza yazılır.

**Çözüm (öncelik sırasıyla):**
1. Mevcut anahtarı TMDb panelinden **iptal edin** (yayındaki kopya geri alınamaz).
2. Web derlemesi için ayrı, atılabilir bir anahtar kullanın:
   ```bat
   REM yayinla.bat
   call flutter build web --release --dart-define=TMDB_KEY=%TMDB_WEB_KEY% ...
   ```
   ```dart
   static const String tmdbApiKey =
       String.fromEnvironment('TMDB_KEY', defaultValue: defaultTmdbApiKey);
   ```
3. Kalıcı çözüm: Cloud Functions/Cloudflare Worker proxy'si — anahtar sunucuda kalır, istemci `/api/tmdb/*` çağırır. Bu ayrıca oran sınırlaması eklemenizi sağlar.

### 5.2 Kullanıcı adı kimliğe bürünme — **Risk: Yüksek** ✅ Doğrulandı
`firestore.rules:129-132`:
```
allow update: if request.auth != null && (
  request.auth.uid == userId || isFollowCounterStep()
);
```
Sahip **her alanı** serbestçe yazabiliyor — `username` ve `usernameLower` dahil. `usernames/{name}` claim registry'si yalnızca **istemci** tarafından (`AuthController.updateProfile`) kontrol ediliyor. Firebase SDK'sını doğrudan çağıran biri (web konsolu, curl + REST API) claim almadan `username: "Alp3rol"` yazabilir.

Sonuç: kullanıcı arama sonuçlarında ve profil ekranında başkasının adıyla görünmek mümkün. `usernames` koleksiyonu bu senaryoyu engellemek için var ama sunucu tarafında bağlanmamış.

**Çözüm:**
```
match /users/{userId} {
  allow update: if request.auth != null && (
    (request.auth.uid == userId && usernameMatchesClaim(userId)) ||
    isFollowCounterStep()
  );
}

function usernameMatchesClaim(userId) {
  // Kullanıcı adı değişmiyorsa serbest; değişiyorsa claim bu uid'e ait olmalı
  return request.resource.data.username == resource.data.username
    || (get(/databases/$(database)/documents/usernames/
            $(request.resource.data.usernameLower)).data.uid == userId
        && request.resource.data.usernameLower ==
           request.resource.data.username.lower());
}
```

### 5.3 Feed'de kimliğe bürünme + sahte beğeni — **Risk: Yüksek** ✅ Doğrulandı
`firestore.rules:59` ve `:83`:
```
allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
```
`username`, `userAvatarUrl`, `starredBy`, `commentCount` **hiç doğrulanmıyor**. Doküman doğrudan feed'e render ediliyor (`community_post_card.dart:66,79`), yani:
- Herhangi bir kullanıcı `username: "moderator"` ile post atabilir.
- `starredBy: [<200 uydurma uid>]` ile sahte beğeni sayısı üretebilir. `isOwnStarToggle` yalnızca **update**'i koruyor, create'i değil.
- `commentCount: 9999` yazabilir.
- Yorumlarda da aynı (`comments` create yalnızca `userId` kontrol ediyor).

**Çözüm:**
```
function authorFieldsAreOwn() {
  let profile = get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
  return request.resource.data.username == profile.username
      && request.resource.data.userAvatarUrl == profile.get('avatarUrl', '');
}

function socialCountersStartEmpty() {
  return request.resource.data.get('starredBy', []) == []
      && request.resource.data.get('commentCount', 0) == 0;
}

allow create: if request.auth != null
  && request.auth.uid == request.resource.data.userId
  && authorFieldsAreOwn()
  && socialCountersStartEmpty()
  && request.resource.data.get('caption', '').size() <= 500;
```
(Not: `get()` her create'te bir doküman okuması ekler. Alternatif — kimliği hiç denormalize etmeyin, feed `users/{userId}` üzerinden çözsün; okuma maliyeti benzer ama sahtecilik yapısal olarak imkânsız olur.)

### 5.4 Silinen koleksiyon paylaşımda kalıyor — **Risk: Yüksek (gizlilik)** ✅ Doğrulandı
`movie_repository.dart:217-219`:
```dart
Future<void> deleteCustomList(int id) async {
  await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
}
```
`isPublic` koleksiyon silindiğinde `shared_collections/{uid}_{listId}` **dokümanı silinmiyor**. Kullanıcı koleksiyonu sildi sanıyor; Firestore'daki ayna (film listesi, isim, açıklama, sahibinin kullanıcı adı ve avatarı) tüm giriş yapmış kullanıcılara okunabilir kalıyor — süresiz. Feed'deki `collection` postu da onu göstermeye devam ediyor.

**Çözüm:**
```dart
@override
Future<void> deleteCustomList(int id) async {
  // Önce paylaşımı kapat: yerel satır gidince aynayı silecek bilgi kalmaz.
  await setCollectionVisibility(id, false);
  await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
}
```
Ayrıca **veri düzeltmesi gerekiyor:** bugüne kadar bu yolla yetim kalmış `shared_collections` dokümanları için tek seferlik bir temizlik betiği (owner'ın `customLists`'inde karşılığı olmayanlar).

### 5.5 Kullanıcı kontrollü avatar URL'i — **Risk: Orta**
`UserModel.avatarUrl` serbest metin; `updateProfile` yalnızca `trim()` yapıyor (`auth_controller.dart:334`). `community_post_card.dart:66` bunu `NetworkImage(post.userAvatarUrl)` ile yüklüyor.

Bir kullanıcı avatarını kendi sunucusuna yönlendirirse, o postu **gören herkesin** IP'si + User-Agent'ı o sunucuya düşer (pasif izleme). `data:` veya `file:` şemalarıyla da denemeler mümkün.

Not: Bugün UI yalnızca 8 hazır DiceBear URL'i sunuyor, ama rules bunu zorlamıyor ve model serbest metin kabul ediyor.

**Çözüm:** Rules'ta allowlist:
```
function isAllowedAvatar(url) {
  return url is string && url.size() < 200
    && (url.matches('https://api[.]dicebear[.]com/.*')
     || url.matches('https://firebasestorage[.]googleapis[.]com/.*'));
}
```
Uzun vadede: avatarları Firebase Storage'a yükleyin, harici URL kabul etmeyin.

### 5.6 Alan boyutu sınırı yok — **Risk: Orta**
Hiçbir kuralda `.size()` kontrolü yok. `notes`, `caption`, `bio`, `text` (yorum) 1 MB'lık Firestore doküman sınırına kadar yazılabilir. 20 KB'lık bir caption feed'i kilitler; kasıtlı doldurma depolama maliyeti üretir.

**Çözüm:** Her create/update kuralına boyut sınırı ekleyin (`caption <= 500`, `notes <= 2000`, `bio <= 300`, `text <= 1000`).

### 5.7 App Check yok — **Risk: Orta**
`web/index.html` ve `firebase_options.dart` istemci konfigürasyonunu (tasarımı gereği) açık ediyor. App Check olmadan, bu konfigürasyonla herhangi bir script Firestore'a doğrudan bağlanıp kuralların izin verdiği her şeyi (tüm public log'ları okumak, post yazmak) uygulamadan bağımsız yapabilir. Oran sınırlaması da yok.

**Çözüm:** Firebase App Check'i etkinleştirin (Web: reCAPTCHA Enterprise, Android: Play Integrity, iOS: DeviceCheck). Kod tarafı ~10 satır.

### 5.8 `logs` kimlik doğrulamasız okunabiliyor — **Risk: Düşük-Orta (tasarım kararı)**
`firestore.rules:57`:
```
allow read: if resource.data.isPublic == true || (request.auth != null && ...);
```
İlk dal `request.auth` gerektirmiyor → public log'lar internete tamamen açık. `posts` ise `request.auth != null` istiyor (satır 82). Bu tutarsızlık kasıtlı mı belli değil. Public log dokümanı `username`, `userAvatarUrl`, `notes`, `watchPlace`, `watchCompanion` içeriyor — kullanıcının "toplulukla paylaştım" beklentisi ile "arama motorlarına açtım" gerçeği aynı şey olmayabilir.

**Öneri:** Kararı bilinçli verin. Topluluk giriş gerektiren bir yerse `logs` okumasına da `request.auth != null` ekleyin.

### 5.9 Kullanıcı adı numaralandırma — **Risk: Düşük**
`usernames` koleksiyonu `allow read: if request.auth != null` (satır 157) ve her doküman `{uid}` içeriyor → giriş yapmış herkes tüm kullanıcı adı → uid eşlemesini çekebilir. Uniqueness için okuma gerekmiyordu (create'in kendisi atomik); bu kural gereksiz geniş.

**Çözüm:** `allow read: if false;` — istemci zaten claim sonucunu create'in başarısından öğreniyor.

### 5.10 Değerlendirilen ve sorun bulunmayan alanlar
- **SQL Injection:** Yok. Drift tip-güvenli sorgu üreticisi kullanılıyor; `customStatement` yalnızca migration'larda sabit SQL ile (`app_database.dart:81-141`), kullanıcı girdisi enterpole edilmiyor.
- **XSS:** Flutter canvas render ediyor, HTML enjeksiyon yüzeyi yok. `web/index.html`'deki inline script kullanıcı verisine dokunmuyor.
- **CSRF:** Firestore token tabanlı, cookie yok — uygulanabilir değil.
- **TLS/MITM (DoH yolu):** `dio_client.dart:76` ham IP'ye `Socket.connect` yapıyor ama `HttpClient` sertifika doğrulamasını orijinal host adına göre yürütüyor. Sertifika atlaması yok. ✅
- **CORS proxy'sinden kaçınma:** `dio_client.dart:88-90` yorumda gerekçesiyle birlikte doğru karar.
- **Şifre işleme:** `signUp` şifreyi `trim()` **etmiyor** (`auth_controller.dart:225-226`) — doğru ve gerekçesi yazılı.
- **E-posta sızıntısı:** Daha önce kapatılmış (`UserModel` yorumu, `firestore.rules:118-125`). ✅

---

## 6. Frontend Analizi

### Bileşen yapısı
İyi ayrıştırılmış. `movie_detail/presentation/widgets/` altında 16 odaklı widget var; `add_watch_record_sheet` alt bileşenlere (`EpisodeTrackingSection`, `MoodSelector`, `WatchRatingSlider`) delege ediyor. 200 satırı geçen widget dosyası az.

### State yönetimi
Riverpod 3 doğru kullanılmış; `ref.watch` / `ref.read` ayrımına dikkat edilmiş ve `CurrentUserOnWidgetRef` uzantısıyla stream-gecikmesi tuzağı belgelenerek çözülmüş (`auth_controller.dart:23-37`). Bu, gerçekten iyi bir mühendislik kararı.

**Sorunlar:**
- `_seedFromSettingsIfNeeded()` **`build()` içinden** çağrılıyor (`add_watch_record_sheet.dart:342`) ve `_seededFromSettings`, `_isActivelyWatching` gibi alanları `setState` olmadan mutasyona uğratıyor. Şu an çalışıyor çünkü `ref.watch` bir sonraki build'i tetikliyor — ama build'in yan etkisiz olması kuralını ihlal ediyor ve kırılgan. Bir `AsyncNotifier`'a taşınmalı.
- `edit_profile_sheet.dart:337` içinde `setState(() {})` — boş gövdeli, yalnızca rebuild zorlamak için. Kod kokusu; `setDialogState` zaten yeterli olmalı.

### Gereksiz render'lar
- §3.4 (IndexedStack yok) en büyük kaynak.
- `home_screen` `addPostFrameCallback` içinde her build'de `updateMoviesFromList` çağırıyor — dedupe `_colorMapEquals` ile eklenmiş (`dynamic_background_provider.dart:186`), ama `updateMoviesFromMapList` (satır 235) aynı korumaya **sahip değil**. Asimetrik; oraya da eklenmeli.

### UX problemleri (§11'de detaylı)
### Responsive
`web_device_frame.dart` (306 satır) web'de mobil çerçeve simüle ediyor — masaüstü tarayıcıda gerçek bir geniş ekran düzeni yok. Bilinçli bir karar ama masaüstü kullanıcısı için israf.

### Erişilebilirlik — **zayıf**
- Hiçbir yerde `Semantics` widget'ı veya `semanticLabel` kullanılmamış (grep ile teyit: 0 sonuç).
- `_buildNavItem` (`main_shell.dart:106`) `GestureDetector` kullanıyor — ekran okuyucuya buton olarak görünmüyor, dokunma hedefi `Icon` + `Text` etrafında 8/12 padding ile ~40 dp (48 dp önerisi altında).
- Kontrast: `AppTheme.textSecondary` koyu zeminde — WCAG AA (4.5:1) karşılanıyor mu ölçülmedi, **doğrulanamadı**.
- `star`/`comment` ikonları etiketsiz.

**Çözüm (düşük maliyet, yüksek kazanç):**
```dart
Semantics(
  button: true,
  selected: isSelected,
  label: label,
  child: InkWell(   // GestureDetector değil: ripple + focus + a11y ücretsiz gelir
    onTap: ...,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: ...,
    ),
  ),
)
```

### SEO
Web sürümü CanvasKit; içerik DOM'da yok → indekslenemez. `index.html`'de `description` meta'sı var, o kadar. Topluluk profilleri gibi paylaşılabilir sayfalar için Open Graph etiketleri ve statik bir landing sayfası eklemek değer üretir.

---

## 7. Backend Analizi

Ayrı bir backend **yok** — Firestore doğrudan istemciden kullanılıyor (BaaS). Değerlendirme buna göre:

| Konu | Durum |
|---|---|
| API tasarımı | Yok (SDK doğrudan). Şema sözleşmesi yalnızca Dart tarafında, tek doğruluk kaynağı yok |
| Validation | **Yok.** Alan doğrulaması ne istemcide (boyut/format) ne rules'ta (§5.3, §5.6) |
| Middleware | Yok — hiçbir sunucu tarafı hook yok |
| Error handling | İstemcide iyi (`TmdbException`, `AuthFailure` — mesaj değil *sebep* döndürmesi doğru tasarım) |
| Transaction | Yalnızca `_claimUsername` (`auth_controller.dart:110-123`) ve Drift `importBackupData`. Log yazımı + settings güncellemesi **atomik değil** (`add_watch_record_sheet.dart:303` ve `:315` iki ayrı yazım) → log yazılıp settings yazılmazsa bölüm ilerlemesi geride kalır |
| Repository | Yerel için var, bulut için yok (§2) |
| Servis katmanı | `TmdbService`, `NotificationService`, `BackupService` — iyi ayrılmış |
| İş kuralları | Dağınık: bölüm matematiği `tv_episode_math.dart` + `watch_record_episode_math.dart` + `episode_logging.dart` + `database_provider.deleteWatchRecord` içinde |

**Öneri — Cloud Functions ile kapatılması gereken 4 boşluk:**
1. `onDelete(logs/{id})` → `commentCount`/`starredBy` temizliği ve `movie_settings` yeniden hesabı (istemci güvenilmez).
2. `onWrite(users/{uid})` → `username` değişince o kullanıcının tüm `logs`/`posts` denormalize adını güncelle (bugün eski postlarda eski ad kalıyor — **doğrulandı**, hiçbir yerde geri yazma yok).
3. `onDelete(shared_collections)` → ilgili `collection` postlarını işaretle.
4. TMDb proxy (§5.1).

---

## 8. Veritabanı Analizi

### Şema (Drift, `tables.dart`)
5 tablo: `Movies`, `WatchRecords`, `UserMovieSettings`, `CustomLists`, `CustomListMovies`. Tasarım **sağlam** — özellikle `{tmdbId, isTv}` bileşik anahtarı gerçek bir veri bozulma hatasına yanıt olarak eklenmiş ve gerekçesi yazılı.

### Bulgular
| # | Bulgu | Öncelik |
|---|---|---|
| D1 | **İndeks yok.** `watchRecords.movieId`, `watchRecords.isTv`, `watchRecords.watchDate`, `customListMovies.listId` üzerinde hiç index tanımı yok. `deleteWatchRecordLocal` ve `unwatchedMoviesProvider` bu sütunlarda tarama yapıyor | Orta |
| D2 | **`WatchRecords` bileşik FK'sız.** Yorumda kabul edilmiş (`tables.dart:51-55`): Drift bildirimsel bileşik FK desteklemiyor. Sonuç: `movies`'ten satır silinirse yetim `watch_records` kalır. Bugün silme yolu yok ama `importBackupData` tabloları boşaltıp yeniden dolduruyor | Düşük |
| D3 | **Normalizasyon:** `genres`, `genreIds`, `actors`, `tags` virgülle ayrılmış metin. 1NF ihlali. Pratikte kabul edilebilir (küçük veri, hep tam okunuyor) ama `_countCommaSeparatedField` her istatistikte string split yapıyor | Düşük |
| D4 | **`genres` sütunu artık ölü ağırlık.** v13'ten sonra `genreIds` kimlik; `genres` yalnızca eski satırlar için fallback. Yeni yazımlarda ikisi de dolduruluyor (`movie_repository.dart:154-155`) | Düşük |
| D5 | **Native'de `watch_records`/`user_movie_settings` giriş yapmış kullanıcı için hiç yazılmıyor** (`backup_service.dart:20-23` bunu belgeliyor). Yani iki tablo çoğu kullanıcıda boş — ama `NativeMovieRepository.deleteWatchRecordLocal` yine de onlara yazıyor. Kafa karıştırıcı ikilik | Orta |
| D6 | **Firestore index'leri eksik olabilir.** `firestore.indexes.json` yalnızca `logs` için 3 bileşik index içeriyor. `posts.orderBy(createdAt)` tek alan (otomatik), `follows.where(followerId)` tek alan (otomatik) — sorun yok. Ama `movie_settings.where('isReWatchList', true)` + `where('isFavorite', true)` tek alan, tamam. Şu an eksik görünmüyor ✅ | — |

**Migration kalitesi: çok iyi.** 13 sürüm, her biri açıklamalı, v8 tablo yeniden inşası doğru sırayla (`PRAGMA foreign_keys = OFF` → rename → create → copy → drop → ON). Tek eksik: **migration testi yok** — `drift_dev`'in `schema dump` + `verifySelfIntegrity` araçları kullanılmıyor.

**Çözüm (D1):**
```dart
@DriftDatabase(tables: [...], /* ... */)
class AppDatabase extends _$AppDatabase {
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      ...
      if (from < 14) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_watch_records_movie '
          'ON watch_records (movie_id, is_tv)');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_watch_records_date '
          'ON watch_records (watch_date DESC)');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_clm_list ON custom_list_movies (list_id)');
        from = 14;
      }
    },
  );
}
```

**Migration testi (drift_dev ile):**
```bash
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
# sonra test/migration_test.dart: her v_n -> v_n+1 için verifySelfIntegrity
```

---

## 9. DevOps Analizi

| Konu | Durum | Değerlendirme |
|---|---|---|
| **CI** | `.github/workflows/ci.yml` — analyze + test + l10n + Türkçe taraması | **İyi.** Yorumu, testlerin 17 dosyada derlenmediğini fark etmemiş olan geçmişe atıf yapıyor — doğru refleks |
| **Coverage** | Yok | `flutter test --coverage` + Codecov eşiği eklenmeli |
| **Build matrisi** | Yalnızca Linux, yalnızca test | Android/iOS/Web derlemesi CI'da hiç doğrulanmıyor — `flutter build web` kırılırsa yalnızca deploy anında öğrenilir |
| **Deployment** | `yayinla.bat` — Windows'a özel, manuel, `git push --force` | **Kritik zayıflık.** Deploy tek bir makineye ve tek bir kişiye bağlı; `gh-pages` ile kaynak commit arasında hiç bağ yok (hangi sürümün yayında olduğu bilinmiyor); force-push geri alınamaz |
| **Environment yönetimi** | `api_key.dart` git-ignored dosya | `--dart-define` / `--dart-define-from-file` daha standart; CI'nın dosya sentezlemesi (`ci.yml:23-28`) bir workaround |
| **Monitoring** | **Yok** | Crash yok, ANR yok, hata oranı yok |
| **Logging** | 64 `debugPrint` | Yalnızca debug; üretimde hiçbir sinyal yok |
| **Backup** | Kullanıcı JSON yedeği var; **Firestore yedeği yok** | Firestore Scheduled Backups (veya `gcloud firestore export`) açılmalı — bugün bir yanlış silme kalıcı |
| **Health check** | Yok | BaaS için kısmen uygulanamaz, ama TMDb erişilebilirliği için bir "durum" göstergesi mantıklı |
| **Scaling** | Firestore otomatik; darboğaz istemci tarafı (§4) | — |

**Çözüm — GitHub Actions ile deploy (yayinla.bat'ın yerine):**
```yaml
# .github/workflows/deploy.yml
name: Deploy web
on:
  push:
    tags: ['v*']            # sürüm etiketi = yayın; hangi commit'in yayında olduğu belli
  workflow_dispatch:
permissions:
  contents: write
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
      - run: |
          cat > lib/core/constants/api_key.dart <<'EOF'
          const String defaultTmdbApiKey = '';
          EOF
      - run: flutter build web --release --base-href "/CineFile/"
                 --dart-define=TMDB_KEY=${{ secrets.TMDB_WEB_KEY }}
      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
          # force-push yerine geçmişi koruyan commit
```
Kazanç: anahtar repoya hiç girmez, deploy izlenebilir, Windows bağımlılığı biter, herkes deploy edebilir.

---

## 10. Test Analizi

**Mevcut durum:** 47 test dosyası, 163 test, hepsi geçiyor.

| Tür | Durum |
|---|---|
| Unit | Var ve iyi — `tv_episode_math_test`, `cine_twin_calculator_test`, `graph_path_finder_test`, `insights_provider_test`, `duplicate_cleanup_test` |
| Widget | Yoğun — 15+ `*_render_test.dart`. `test/support/` altındaki `localized_app.dart`, `network_image_mock.dart`, `riverpod_async.dart` yardımcıları düzgün kurulmuş |
| Integration | **Yok** (`integration_test/` dizini yok) |
| E2E | **Yok** |
| Golden | **Yok** — "premium tasarım" iddiası olan bir uygulamada görsel regresyon koruması olmaması ciddi eksik |
| Coverage ölçümü | **Yok** |

### Kritik test boşlukları (öncelik sırasıyla)

**1. `firestore.rules` testi yok — En önemli boşluk.**
Uygulamanın tüm yetkilendirme mantığı bu dosyada ve hiç test edilmiyor. §5.2/5.3'teki açıklar bir test paketi olsaydı yazılırken yakalanırdı.
```js
// test/rules/firestore.rules.test.js  (@firebase/rules-unit-testing)
const { initializeTestEnvironment, assertFails, assertSucceeds } =
  require('@firebase/rules-unit-testing');

test('bir kullanıcı başkasının adıyla post atamaz', async () => {
  const alice = env.authenticatedContext('alice');
  await assertFails(alice.firestore().collection('posts').add({
    userId: 'alice', username: 'bob', userAvatarUrl: '', type: 'movie',
    caption: 'x', createdAt: new Date(), starredBy: [], commentCount: 0,
  }));
});

test('starredBy önceden doldurulamaz', async () => {
  const alice = env.authenticatedContext('alice');
  await assertFails(alice.firestore().collection('posts').add({
    userId: 'alice', starredBy: ['bob','carol','dave'], commentCount: 0, ...
  }));
});

test('özel bir log yabancıya görünmez', async () => {
  await env.withSecurityRulesDisabled(c =>
    c.firestore().doc('logs/l1').set({ userId: 'alice', isPublic: false }));
  await assertFails(env.authenticatedContext('bob').firestore().doc('logs/l1').get());
});
```
CI'ya `firebase emulators:exec --only firestore "npm test"` adımı eklenir.

**2. Migration testi yok** (§8).

**3. Yedekleme yuvarlak-gidiş testi eksik.** `backup_restore_custom_lists_test.dart` var ama web export'unun alan kaybını (§3.7) yakalamıyor. Şu test o bug'ı yakalardı:
```dart
test('web yedeği her alanı korur', () async {
  final original = WatchRecord(id: 1, movieId: 5, isTv: false,
      watchDate: DateTime(2025, 1, 1), rating: 8, watchNumber: 1,
      tags: '#sinema,#gece', remoteId: 'abc', createdAt: DateTime(2025, 1, 1),
      episodeCount: 1, isPublic: false);
  container.read(webWatchRecordsProvider.notifier).state = [original];

  final json = await repo.exportBackupData();
  await repo.importBackupData(json);

  expect(container.read(webWatchRecordsProvider).single, original);  // bugün FAIL
});
```

**4. Test edilebilirlik engeli:** `add_watch_record_sheet._saveRecord` Firestore'a doğrudan yazdığı için ancak `fake_cloud_firestore` ile test edilebiliyor. §2'deki repository soyutlaması bunu saf bir unit teste indirger.

**Hedef:** `lib/` için satır kapsamı ≥ %65 (`lib/l10n`, `*.g.dart` hariç), `lib/features/*/domain/` için ≥ %85.

---

## 11. Kullanıcı Deneyimi

| # | Sorun | Neden zorlayıcı | Çözüm |
|---|---|---|---|
| U1 | Sekme değişince kaydırma konumu ve arama metni kayboluyor (§3.4) | En sık yaşanan sinir bozucu davranış | `IndexedStack` |
| U2 | Kayıt silme onaysız mı? `deleteWatchRecordsByIds` toplu siliyor | Yanlışlıkla veri kaybı riski — UI'da onay var mı doğrulanmadı | Onay + "Geri al" snackbar'ı (5 sn) |
| U3 | Bölüm sayısı girişi: her kayıt varsayılan 1 bölüm | Bir sezonu tek oturumda bitiren kullanıcı 10 kez "+" basıyor | "Sezon tamamlandı" hızlı eylemi (TMDb sezon bölüm sayısını zaten biliyor) |
| U4 | Kayıt eklemek: arama → detay → sheet → 8 alan → kaydet | Günlük tutmanın önündeki en büyük sürtünme | Ana ekranda "hızlı kayıt": başlık + puan + kaydet (2 dokunuş) |
| U5 | Hata mesajları jenerik (`addRecordSaveFailed`) | Kullanıcı ne yapacağını bilmiyor | Sebebe göre ayrıştırın: ağ yok / oturum düşmüş / kota — her biri farklı eylem önerir |
| U6 | Çevrimdışı yazma yok — oturum açıkken tüm yazımlar Firestore'a | Uçakta/metroda kayıt eklenemez | Firestore offline persistence'ı açın (`Settings(persistenceEnabled: true)`) — tek satır, büyük kazanç |
| U7 | Boş durumlar zayıf | Yeni kullanıcı ne yapacağını bilmiyor | Onboarding: ilk 3 filmi seçtiren bir akış |
| U8 | Erişilebilirlik (§6) | Ekran okuyucu kullanıcıları uygulamayı kullanamaz | `Semantics` + 48 dp hedefler |
| U9 | Silinen koleksiyon hâlâ paylaşımda (§5.4) | Kullanıcı gizlilik ihlali yaşıyor ve haberi yok | §5.4'teki düzeltme |
| U10 | Kullanıcı adı değişince eski postlarda eski ad kalıyor | Tutarsız kimlik | Cloud Function ile geri yazma (§7) |

---

## 12. Yeni Özellik Önerileri

### Büyük özellikler

| Özellik | Neden gerekli | Kullanıcı faydası | Zorluk | Süre | Öncelik |
|---|---|---|---|---|---|
| **Çevrimdışı-öncelikli senkronizasyon** | Bugün oturum açıkken hiçbir yazma çevrimdışı çalışmıyor | Her yerde kayıt tutabilme | Orta | 1-2 hafta | **Yüksek** |
| **Yıllık Özet ("CineFile Wrapped")** | Spotify Wrapped etkisi; en güçlü organik büyüme kanalı. Veri (istatistikler) zaten var | Paylaşılabilir, gurur veren çıktı | Orta | 2 hafta | **Yüksek** |
| **Watchlist + "Nereden izlenir"** | TMDb `/watch/providers` ücretsiz | "Bunu nerede izleyebilirim?" en sık sorulan soru | Düşük | 3-4 gün | **Yüksek** |
| **TMDb proxy + hesap sistemi** | §5.1'i kalıcı kapatır, oran sınırı ve kota kontrolü getirir | Kesintisiz servis | Orta | 1 hafta | **Yüksek** |
| **Letterboxd/Trakt içe aktarma** | Kullanıcı edinmenin en büyük engeli "geçmişimi yeniden girmek" | Sıfır sürtünmeli geçiş | Orta | 1 hafta | Orta |
| **Masaüstü/geniş ekran düzeni** | Web sürümü bugün telefon çerçevesinde | Web'i gerçek bir ürün yapar | Orta-Yüksek | 2-3 hafta | Orta |

### Küçük özellikler (hızlı kazanım)
| Özellik | Fayda | Zorluk | Süre |
|---|---|---|---|
| Kayıt silmede "Geri al" | Veri kaybı korkusunu kaldırır | Düşük | 2 saat |
| "Sezon tamamlandı" tek dokunuş | U3'ü çözer | Düşük | 4 saat |
| Ana ekranda hızlı kayıt | U4'ü çözer | Düşük-Orta | 1-2 gün |
| Günlüğü CSV dışa aktarma | Veri sahipliği hissi | Düşük | 3 saat |
| Rozet paylaşım kartı (görsel) | Organik yayılım | Düşük | 1 gün |
| Karanlık/açık tema seçeneği | Bugün yalnızca koyu tema var | Orta | 3 gün |

### AI entegrasyonları
| Öneri | Neden | Zorluk | Öncelik |
|---|---|---|---|
| **Doğal dil arama** ("90'larda geçen, hüzünlü biten bilim kurgu") | TMDb `discover` filtreleri kullanıcıya kapalı; LLM bunları filtreye çevirebilir | Orta | Orta |
| **Kişisel izleme profili özeti** | 200 kayıtlık geçmişten "senin sinema zevkin" paragrafı — Wrapped'ın kalbi | Düşük (tek prompt) | **Yüksek** |
| **Not zenginleştirme** | Kullanıcının kısa notlarından ay sonu "günlük özeti" | Düşük | Orta |
| **Akıllı öneri gerekçesi** | Bugün `recommendationsProvider` mekanik ("En çok izlediğin tür"); LLM ile kişisel gerekçe | Düşük | Orta |

> Uygulama notu: LLM çağrıları **kesinlikle** sunucu tarafında olmalı (API anahtarı istemciye gömülmemeli — §5.1'in aynısı tekrarlanmasın). Cloud Functions + Claude API iyi bir eşleşme; günlük/kullanıcı kota sınırı koyun.

### Gelir fikirleri
- **CineFile Pro** (yıllık): sınırsız koleksiyon, Wrapped arşivi, gelişmiş grafikler, AI özetleri, çoklu cihaz senkron önceliği.
- **Ücretsiz kademe sınırı:** 3 koleksiyon, 1 yıllık istatistik geçmişi.
- Reklam **önerilmez** — ürünün "premium" konumlandırmasıyla çelişir.

### Otomasyon / Yönetim paneli
- Firestore'a `reports/{id}` koleksiyonu + basit bir moderasyon paneli (bugün **hiç** şikayet/moderasyon mekanizması yok — topluluk büyüdüğünde acil ihtiyaç olur). **Öncelik: Yüksek**
- Cloud Scheduler ile haftalık "yetim `shared_collections` temizliği" (§5.4).

### Bildirimler
Bugün yalnızca yerel bildirim var. **FCM push** eklenirse: yeni takipçi, yorum, beğeni, arkadaşın gönderisi. Topluluk özelliğinin geri dönüşünü ciddi artırır. **Zorluk: Orta, süre 1 hafta.**

---

## 13. Teknik Borç Tablosu

| # | Sorun | Dosya | Etki | Çözüm | Öncelik |
|---|---|---|---|---|---|
| T1 | TMDb anahtarı yayında | `origin/gh-pages:main.dart.js` | Anahtar ele geçirme, kota/ban | Anahtarı iptal et, `--dart-define`, proxy | **Kritik** |
| T2 | `username` sunucuda doğrulanmıyor | `firestore.rules:129` | Kimliğe bürünme | Claim'e bağla | **Kritik** |
| T3 | Post/log create alan doğrulaması yok | `firestore.rules:59,83` | Sahte kimlik/beğeni | `authorFieldsAreOwn()` + sayaç kontrolü | **Kritik** |
| T4 | Silinen koleksiyonun aynası kalıyor | `movie_repository.dart:217` | Gizlilik sızıntısı | `setCollectionVisibility(false)` + temizlik betiği | **Kritik** |
| T5 | `firestore.rules` testsiz | — | Yetkilendirme regresyonu | `@firebase/rules-unit-testing` + CI | **Yüksek** |
| T6 | Bildirim resync fırtınası | `main_shell.dart:60` | Pil, TMDb kotası, jank | Fingerprint + debounce | **Yüksek** |
| T7 | `watchNumber = docs.length+1` | `add_watch_record_sheet.dart:264` | Çakışan numaralar, bozuk ilerleme | Transaction + sayaç | **Yüksek** |
| T8 | Web yedeği alan kaybediyor | `movie_repository.dart:879` | Sessiz veri kaybı | `toJson()` kullan | **Yüksek** |
| T9 | Mock fallback sahte kredi yazıyor | `movie_detail_provider.dart:122` | Bozuk kütüphane, sahte rozet | Yalnızca anahtarsız modda | **Yüksek** |
| T10 | `IndexedStack` yok | `main_shell.dart:76` | State kaybı + Firestore maliyeti | `IndexedStack` | **Yüksek** |
| T11 | Gözlemlenebilirlik yok | — | Üretimde körlük | Crashlytics/Sentry + App Check | **Yüksek** |
| T12 | Sayfalamasız log akışı | `database_provider.dart:272` | Büyük kütüphanede maliyet + bellek | `limit()` + sayfalama | **Yüksek** |
| T13 | Yedek geri yüklemede geri alma yok | `backup_service.dart:97` | Kısmi hata = veri kaybı | Yaz→doğrula→sil | Orta |
| T14 | Firestore erişimi widget'larda | 6 dosya | Katman ihlali, test edilemezlik | `WatchLogRepository` | Orta |
| T15 | `_colorCache` sınırsız | `dynamic_background_provider.dart:63` | Bellek büyümesi | LRU 256 | Orta |
| T16 | `FailoverInterceptor` çıplak `Dio()` | `dio_client.dart:114` | Failover DoH'suz → işe yaramaz | Aynı `Dio`, kopya options | Orta |
| T17 | Force-layout ana izlekte | `relationship_graph_screen.dart:111` | Büyük grafta donma | `compute()` | Orta |
| T18 | Graf: başlık başına 1 istek | `relationship_graph_provider.dart:51` | Yüzlerce istek/açılış | Kalıcı kredi önbelleği | Orta |
| T19 | `_mockMovies` iki kopya | `tmdb_service.dart:51`, `movie_detail_provider.dart:59` | Sapma riski | Tek `kDemoMovies` sabiti | Orta |
| T20 | `updateWatchRecordRankings` iki kopya | `movie_repository.dart:367,721` | Bakım maliyeti | Arayüzden çıkar | Orta |
| T21 | Hardcoded Türkçe CI'yı atlatıyor | `edit_profile_sheet.dart:185,198,261,280,313,346` | Yarım çeviri | Tarayıcıyı literal-tabanlı yap | Orta |
| T22 | Ölü `CalendarScreen` | `calendar_screen.dart` (372 satır) | Kafa karışıklığı | Bağla veya sil | Orta |
| T23 | Drift index yok | `tables.dart` | Yerel sorgu taraması | v14 migration | Orta |
| T24 | Migration testi yok | — | Bozuk migration üretime çıkar | `drift_dev schema` | Orta |
| T25 | Erişilebilirlik yok | Tüm UI | Ekran okuyucu kullanılamaz | `Semantics` + 48 dp | Orta |
| T26 | Deploy manuel/Windows/force-push | `yayinla.bat` | Bus factor 1, izlenemez sürüm | GitHub Actions | Orta |
| T27 | Alan boyutu sınırı yok | `firestore.rules` | Depolama abusu | `.size()` kontrolleri | Orta |
| T28 | 6× sessiz `catch (_) {}` | 5 dosya | Teşhis edilemez hata | Logla | Düşük |
| T29 | `_seedFromSettingsIfNeeded` build'de mutasyon | `add_watch_record_sheet.dart:342` | Kırılgan | `AsyncNotifier` | Düşük |
| T30 | Legacy `BadgeState` | `insights_provider.dart:12` | Çift model | Tek modele indir | Düşük |
| T31 | Rozet kataloğu kod içinde | `insights_provider.dart:433-878` | 450 satır tekrarlı yapı | Veri odaklı katalog | Düşük |
| T32 | Coverage ölçümü yok | CI | Regresyon körlüğü | `--coverage` + eşik | Düşük |
| T33 | Firestore yedeği yok | — | Kalıcı veri kaybı riski | Scheduled Backups | Orta |
| T34 | Moderasyon/şikayet yok | — | Topluluk büyüyünce kriz | `reports` + panel | Orta |

---

## 14. Refactor Yol Haritası

### Faz 0 — Acil güvenlik (bu hafta, ~2 gün)
1. **T1:** TMDb anahtarını iptal et; yeni anahtar üret; web derlemesine `--dart-define` ile ayrı anahtar ver.
2. **T4:** `deleteCustomList` düzeltmesi + yetim `shared_collections` temizlik betiği. *(Kullanıcı verisi açıkta — bekletmeyin.)*
3. **T2 + T3 + T27:** `firestore.rules` sertleştirmesi.
4. **T5:** Rules test paketi (yukarıdaki 3 maddeyi kilitleyen testlerle birlikte) + CI adımı.

**Çıkış kriteri:** Rules testleri kimliğe bürünme, sahte beğeni ve boyut aşımını reddediyor; CI'da yeşil.

### Faz 1 — Veri bütünlüğü (1 hafta)
5. **T9:** Mock fallback düzeltmesi + mevcut bozuk satırlar için tek seferlik onarım (`director == 'Christopher Nolan'` olup TMDb'de olmayanları null'a çek).
6. **T7:** `watchNumber` transaction'a taşınması.
7. **T8:** Web yedek serileştirmesinin `toJson()`'a indirgenmesi + §10'daki yuvarlak-gidiş testi.
8. **T13:** Restore sırasının yaz→doğrula→sil olarak değiştirilmesi.
9. **T24 + T23:** Migration testleri + v14 index migration'ı.

### Faz 2 — Performans (1 hafta)
10. **T10:** `IndexedStack`.
11. **T6:** Bildirim fingerprint + debounce.
12. **T12:** `allWatchRecordsProvider` sayfalaması.
13. **T15:** LRU renk önbelleği.
14. **T17 + T18:** Graf layout'un isolate'e, kredilerin kalıcı önbelleğe alınması.
15. **T16:** `FailoverInterceptor` düzeltmesi + timeout ayarı.
16. Ölçüm: Faz öncesi/sonrası Firestore okuma sayısı ve kare süresi karşılaştırması.

### Faz 3 — Kod temizliği (1 hafta)
17. **T19, T20, T30, T31:** Kopya kod ve legacy model temizliği.
18. **T21:** `check_localized.dart`'ın literal-tabanlı hâle getirilmesi + `edit_profile_sheet` çevirisi.
19. **T22:** `CalendarScreen` kararı.
20. **T28:** Sessiz catch'lerin loglanması.
21. **T32:** Coverage + eşik.

### Faz 4 — Mimari (2-3 hafta)
22. **T14:** `WatchLogRepository` / `UserProfileRepository` / `SocialRepository` soyutlamaları; widget'lardan Firestore'un tamamen çıkarılması.
23. `database_provider.dart`'ın bölünmesi: `providers/watch_records.dart`, `providers/social.dart`, `providers/collections.dart`.
24. **T11:** Crashlytics/Sentry + Firebase App Check.
25. **T26:** GitHub Actions deploy.
26. **T33 + T34:** Firestore Scheduled Backups + moderasyon iskeleti.
27. Cloud Functions: log silme temizliği, username geri yazma, TMDb proxy.

### Faz 5 — Yeni özellikler
28. Çevrimdışı-öncelikli senkron → "Nereden izlenir" → Wrapped → AI profil özeti → FCM push.

---

## 15. Ek Kod Örnekleri (Eski → Yeni)

### 15.1 Streak hesabı (O(n²) → O(n))
```dart
// ESKİ — insights_provider.dart:243-252
bool hasToday = uniqueDates.contains(today);      // List.contains → O(n)
bool hasYesterday = uniqueDates.contains(yesterday);
if (hasToday || hasYesterday) {
  DateTime checkDate = hasToday ? today : yesterday;
  while (uniqueDates.contains(checkDate)) {        // döngü içinde O(n) → O(n²)
    currentStreak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }
}
```
```dart
// YENİ
final dateSet = uniqueDates.toSet();               // bir kez O(n)
final startFrom = dateSet.contains(today)
    ? today
    : (dateSet.contains(yesterday) ? yesterday : null);
if (startFrom != null) {
  var checkDate = startFrom;
  while (dateSet.contains(checkDate)) {            // O(1) arama
    currentStreak++;
    checkDate = checkDate.subtract(const Duration(days: 1));
  }
}
```

### 15.2 Kopya `updateWatchRecordRankings`
```dart
// ESKİ — movie_repository.dart:367-393 VE 721-747 (iki kez, birebir aynı)
class NativeMovieRepository implements MovieRepository {
  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async { ... }
}
class WebMovieRepository implements MovieRepository {
  @override
  Future<void> updateWatchRecordRankings(Map<MovieKey, int?> rankings) async { ... }  // aynı
}
```
```dart
// YENİ — arayüzden çıkar; platformdan bağımsız olduğu için serbest fonksiyon
// movie_repository.dart — MovieRepository arayüzünden updateWatchRecordRankings silinir.
Future<void> updateWatchRecordRankings(Ref ref, Map<MovieKey, int?> rankings) async {
  final user = ref.currentUser;
  if (user == null) return;
  final settings = ref.read(firestoreProvider)
      .collection('users').doc(user.uid).collection('movie_settings');
  final batch = ref.read(firestoreProvider).batch();
  for (final e in rankings.entries) {
    batch.set(settings.doc('${e.key.tmdbId}_${e.key.isTv}'), {
      'movieId': e.key.tmdbId, 'isTv': e.key.isTv,
      'personalRanking': e.value, 'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  await batch.commit();   // ayrıca: N ardışık yazım yerine tek batch
}
```
*(Bonus: eski kod her sıralama için ayrı `await` ediyordu — 50 filmlik bir listede 50 ardışık round-trip. Batch tek istek.)*

### 15.3 Rozet kataloğunu veriye çevirme
```dart
// ESKİ — insights_provider.dart:449-876, 28 kez tekrarlanan blok
badges.add(_buildTieredBadge(
  id: 'nolan_series', defaultTitle: l10n.badgeNolanTitle, icon: '🎬',
  category: AchievementCategory.directors,
  currentValue: _countByKeyword(list, (r) => r.movie.director, 'christopher nolan'),
  steps: [ TierStep(target: 2, ...), TierStep(target: 4, ...), TierStep(target: 7, ...) ],
));
// ... × 28
```
```dart
// YENİ — katalog veri, hesap tek yerde
// lib/features/insights/domain/badge_catalogue.dart
typedef BadgeMetric = int Function(InsightsInput input);

class BadgeSpec {
  const BadgeSpec({
    required this.id, required this.icon, required this.category,
    required this.metric, required this.targets, required this.copy,
  });
  final String id;
  final String icon;
  final AchievementCategory category;
  final BadgeMetric metric;
  final List<int> targets;
  final BadgeCopy Function(AppLocalizations) copy;
}

const kDirectorBadges = <BadgeSpec>[
  BadgeSpec(
    id: 'nolan_series', icon: '🎬', category: AchievementCategory.directors,
    metric: _byDirector('christopher nolan'),
    targets: [2, 4, 7],
    copy: _nolanCopy,
  ),
  // ...
];

// insights_provider.dart tek döngüye iner:
final achievementBadges = [
  for (final spec in kAllBadges) buildTieredBadge(spec, input, l10n),
];
```
Kazanç: ~450 satır → ~120 satır; yeni rozet eklemek tek bir `const` girdisi; her rozet ayrı test edilebilir.

### 15.4 Güvenli `deleteCustomList`
```dart
// ESKİ
Future<void> deleteCustomList(int id) async {
  await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
}
```
```dart
// YENİ
Future<void> deleteCustomList(int id) async {
  // Firestore aynasını ÖNCE kaldır: yerel satır silindikten sonra
  // hangi dokümanın silineceğini belirleyecek bilgi kalmaz ve
  // paylaşılan koleksiyon süresiz olarak herkese açık kalır.
  final list = await (_db.select(_db.customLists)..where((t) => t.id.equals(id)))
      .getSingleOrNull();
  if (list != null && list.isPublic) {
    await setCollectionVisibility(id, false);
  }
  await (_db.delete(_db.customLists)..where((t) => t.id.equals(id))).go();
}
```

---

## 16. Nihai Puanlama

| Başlık | Puan | Gerekçe |
|---|---:|---|
| **Kod Kalitesi** | **7.5**/10 | Analyze temiz, isimlendirme tutarlı, yorumlar örnek nitelikte. Düşüren: kopya kod (mock listesi, ranking, yedek serileştirme), sessiz catch'ler, 900 satırlık provider |
| **Mimari** | **6**/10 | Feature-first düzen doğru, Riverpod kullanımı bilinçli. Ama Firestore için repository yok — sunum katmanı doğrudan veritabanına yazıyor; `database_provider.dart` bir god-file |
| **Güvenlik** | **4**/10 | Rules ortalamanın üstünde yazılmış ve gerçek düşünce ürünü, ama üç somut açık var (kimliğe bürünme, sahte beğeni, silinen koleksiyonun sızması) + anahtar yayında + App Check/rate limit yok + rules testsiz |
| **Performans** | **5**/10 | Görsel indirme/önbellek katmanı düşünülmüş (`memCacheWidth`, DoH, dio cache). Ama sayfalamasız log akışı, her ayar yazımında bildirim fırtınası, sekme yeniden inşası ve ana izlekte O(n²) layout ciddi maliyetler |
| **Ölçeklenebilirlik** | **5**/10 | Firestore altyapısı ölçekleniyor; istemci ölçeklenmiyor. 5.000 kayıtlı kullanıcıda tasarım kırılıyor |
| **Bakım Kolaylığı** | **7.5**/10 | Yorumlar ve CI kapıları bakımı gerçekten kolaylaştırıyor. Düşüren: 34 kalemlik teknik borç ve katman ihlalleri |
| **Okunabilirlik** | **8.5**/10 | En güçlü boyut. Karar gerekçelerinin koda yazılması nadir bir disiplin |
| **Test Edilebilirlik** | **5.5**/10 | 163 test ve iyi test yardımcıları var; ama rules testsiz, migration testsiz, golden yok, coverage ölçülmüyor ve Firestore bağımlılığı unit testi engelliyor |
| **UX** | **6.5**/10 | Tasarım tutarlı ve özenli, özellik derinliği yüksek. Düşüren: sekme state kaybı, kayıt sürtünmesi, çevrimdışı yazma yok, erişilebilirlik sıfır |
| **Genel Kalite** | **6.2**/10 | Ciddi bir bireysel proje; ürünleşme eşiğinin hemen altında |

---

## 17. Sonuç

### Güçlü Yönler
1. **Kod içi dokümantasyon kalitesi ticari standardın üstünde.** Kararların *nedeni* ve hangi somut hatayı kapattığı yazılı — bu, 6 ay sonra projeye dönen bir geliştirici için en değerli varlık.
2. **Migration disiplini gerçek.** 13 sürüm boyunca veri kaybı olmadan ilerlenmiş, tanımsız geçiş `StateError` ile kapatılmış.
3. **`firestore.rules`'ta düşünce var.** `isOwnStarToggle`'ın simetrik-fark kontrolü, çoğu projede olmayan bir savunma.
4. **CI dört ayrı regresyon sınıfını yakalıyor** (derleme, test, eksik çeviri, hardcoded metin).
5. **Yerelleştirme altyapısı sağlam kurulmuş** — Türkçe'nin şablon dili olması ve gerekçesi doğru.
6. **Özellik derinliği etkileyici:** bölüm takibi, ilişki grafı, 28 kademeli rozet, CineDNA/CineTwin, canlı koleksiyon paylaşımı.
7. **Ağ dayanıklılığı düşünülmüş:** DoH + domain failover, Türkiye'deki TMDb erişim sorununa gerçek bir yanıt.

### Kritik Sorunlar
1. **TMDb API anahtarı `gh-pages`'te açıkta** — 19 kez, kalıcı git geçmişinde, herkese servis ediliyor.
2. **Kullanıcı adı kimliğe bürünmesi mümkün** — `usernames` claim registry'si sunucu tarafında `users.username`'e bağlanmamış.
3. **Feed'de sahte kimlik ve sahte beğeni mümkün** — `posts`/`logs` create'inde `username`, `userAvatarUrl`, `starredBy`, `commentCount` doğrulanmıyor.
4. **Silinen koleksiyon Firestore'da paylaşımda kalıyor** — kullanıcının bilgisi dışında, süresiz gizlilik sızıntısı.
5. **`firestore.rules` için sıfır test** — yukarıdaki üç açık, bir test paketi olsaydı yazılırken yakalanırdı.
6. **Üretimde hiçbir gözlemlenebilirlik yok** — crash, hata oranı, kullanım sinyali sıfır.

### Hızlı Kazanımlar (Quick Wins)
| Değişiklik | Süre | Kazanç |
|---|---|---|
| `body: IndexedStack(index: ..., children: _screens)` | 5 dk | Sekme state'i korunur, Firestore okumaları düşer |
| `deleteCustomList`'e `setCollectionVisibility(false)` | 15 dk | Gizlilik sızıntısı kapanır |
| `uniqueDates.toSet()` (streak) | 5 dk | O(n²) → O(n) |
| Firestore offline persistence açma | 10 dk | Çevrimdışı okuma çalışır |
| Rules'a `.size()` sınırları | 30 dk | Depolama abusu kapanır |
| `usernames` okumasını `if false` yapma | 5 dk | Numaralandırma kapanır |
| Anahtarı `--dart-define`'a taşıma | 1 saat | Repoda anahtar kalmaz |
| Web yedek export'unu `toJson()`'a çevirme | 1 saat | Veri kaybı biter + 60 satır silinir |
| `--coverage` + Codecov | 30 dk | Regresyon görünürlüğü |
| Crashlytics ekleme | 1 saat | Üretimde göz açılır |

### En Öncelikli 10 Düzeltme
1. **TMDb anahtarını iptal et**, yeni anahtar üret, web derlemesi için `--dart-define` ile ayır. *(T1)*
2. **`deleteCustomList` gizlilik sızıntısını kapat** + yetim `shared_collections` dokümanlarını temizle. *(T4)*
3. **`firestore.rules`'ta `username`'i claim registry'sine bağla.** *(T2)*
4. **Post/log create'inde yazar alanlarını ve sosyal sayaçları doğrula.** *(T3)*
5. **Rules test paketi kur** ve CI'ya ekle — 3 ve 4'ü kilitler. *(T5)*
6. **`watchNumber`'ı transaction'a taşı** — çakışan numaralar bölüm ilerlemesini bozuyor. *(T7)*
7. **Mock fallback'in sahte yönetmen/tür yazmasını durdur** + bozuk satırları onar. *(T9)*
8. **Bildirim resync'ini fingerprint + debounce ile sınırla.** *(T6)*
9. **Web yedek serileştirmesini `toJson()`'a indir** — `tags`/`personalRanking` sessizce kayboluyor. *(T8)*
10. **Crashlytics + Firebase App Check ekle.** *(T11)*

### En Faydalı 20 Yeni Özellik
1. Çevrimdışı-öncelikli senkronizasyon
2. Yıllık Özet ("CineFile Wrapped") + paylaşılabilir kart
3. "Nereden izlenir" (TMDb watch providers)
4. Sunucu tarafı TMDb proxy (anahtar + oran sınırı)
5. Letterboxd / Trakt / IMDb içe aktarma
6. FCM push bildirimleri (takip, yorum, beğeni)
7. Ana ekranda 2 dokunuşluk hızlı kayıt
8. Kayıt silmede "Geri al"
9. "Sezon tamamlandı" tek dokunuş
10. AI kişisel izleme profili özeti
11. Doğal dil arama
12. Şikayet + moderasyon paneli
13. Masaüstü/geniş ekran düzeni
14. Açık tema seçeneği
15. CSV/Letterboxd formatında dışa aktarma
16. Onboarding akışı (ilk 3 film)
17. Arkadaşlarla ortak koleksiyon (co-editing)
18. İzleme hedefleri (yıllık film sayısı, tür çeşitliliği)
19. Widget (Android/iOS ana ekran): bu haftaki ilerleme
20. Rozet paylaşım kartı görselleri

### Genel Değerlendirme

**Bu, hobi projesi seviyesinin belirgin şekilde üstünde bir iş.** 144 commit, 13 veritabanı migration'ı, iki dilli tam yerelleştirme, çalışan bir CI ve 163 geçen test — bunlar disiplinli bir çalışmanın kanıtı. Özellikle kod içi gerekçe yazma alışkanlığı, çoğu profesyonel ekipte bulunmayan bir olgunluk göstergesi; `tables.dart`'taki `{tmdbId, isTv}` yorumu tek başına, bir hatanın nasıl anlaşılıp kalıcı olarak kapatıldığının ders niteliğinde örneği.

**Ancak proje şu anda bir eşikte duruyor.** Tek kullanıcılı bir kişisel günlük olarak zaten çalışıyor. Topluluk özelliğinin eklenmesiyle **çok kullanıcılı bir sistem** oldu ve çok kullanıcılı sistemlerin gerektirdiği üç şey henüz yok: (a) sunucu tarafında zorlanan veri doğrulaması, (b) yetkilendirme testleri, (c) moderasyon ve gözlemlenebilirlik. §5'teki üç açık, "istemci doğru davranır" varsayımının doğrudan sonucu — ve o varsayım, uygulamanın kendisi açık kaynak olduğu ve Firebase konfigürasyonu tasarımı gereği herkese açık olduğu için tutmuyor.

**Sürdürülebilirlik açısından** en büyük risk teknik değil, yapısal: deploy tek bir Windows makinesine ve tek bir kişiye bağlı, `--force` ile yapılıyor ve yayındaki sürümün hangi commit olduğu izlenmiyor. Bir projeyi uzun vadede öldüren şey genellikle kötü kod değil, geri alınamayan süreçlerdir. GitHub Actions'a taşımak bir günlük iş ve bu riski tamamen kaldırır.

**Ölçeklenebilirlik açısından** mimari 500-1.000 izleme kaydına kadar sorunsuz; ötesinde kırılıyor. `allWatchRecordsProvider`'ın sayfalamasız oluşu ve istatistiklerin her değişimde ana izlekte tam yeniden hesabı, aktif bir kullanıcının uygulamayı yavaş bulacağı eşiği belirliyor. Bu, mimarinin yanlış olduğu anlamına gelmiyor — tek kullanıcılık varsayımıyla doğru kurulmuş; sadece bir sonraki büyüme adımı için hesap katmanının (isolate + önceden toplanmış özet dokümanı) eklenmesi gerekiyor.

**Profesyonellik seviyesi: orta-üst.** Kod okunabilirliği ve dokümantasyonu üst seviye, süreç ve güvenlik olgunluğu orta-alt. Faz 0 ve Faz 1 (yaklaşık 10 iş günü) tamamlandığında proje gerçek anlamda "yayına hazır" olur; Faz 2-4 sonrası ise küçük bir ekibin devralıp geliştirebileceği bir kod tabanına dönüşür.

**Tek cümlelik özet:** İyi düşünülmüş ve iyi belgelenmiş bir kod tabanı; eksik olan kod kalitesi değil, çok kullanıcılı bir ürünün gerektirdiği sunucu tarafı güvenceler ve süreç otomasyonu.

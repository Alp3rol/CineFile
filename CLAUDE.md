# FilmDizi Günlüğü — Proje Kuralları

Flutter tabanlı, kişisel film/dizi izleme günlüğü uygulaması. Riverpod (state management) + Drift/SQLite (veritabanı) + Dio (TMDb API) kullanıyor. Feature-first klasör yapısı: `lib/features/{home,search,journal,calendar,movie_detail,settings,insights}/presentation/`.

Bu dosya, önceki bir kod denetiminde bulunan ve düzeltilen sorunların **tekrarlanmaması** için var. Yeni kod yazarken veya mevcut kodu değiştirirken aşağıdaki kurallara uy.

## Veritabanı (Drift/SQLite)

- **Migration'lar asla veri silmemeli.** `lib/core/database/app_database.dart`'taki `onUpgrade` artık bilinmeyen bir schema geçişinde `deleteTable`/`createTable` ile veriyi sessizce silmek yerine `StateError` fırlatıyor. Yeni bir `schemaVersion` eklerken, o geçiş için **açıkça** `m.addColumn`, `m.createTable` gibi yıkıcı olmayan bir adım yaz. "Kolay olsun diye tabloyu sil baştan oluştur" asla yapma — kullanıcı verisi (izleme geçmişi, notlar, listeler) kalıcı.
- Yeni bir tablo/sütun eklerken `drift_dev`/`build_runner` codegen'i çalıştırmayı unutma (`dart run build_runner build --delete-conflicting-outputs`). Not: bu ortamda Türkçe karakterli (`ü`) proje yolu yüzünden `build_runner` ve `flutter analyze` bazen çöküyor — bu ortam kısıtı, kod hatası değil; `dart analyze <dosya/dizin>` genelde çalışır.
- **`db.into(table).insertOnConflictUpdate(x)`'e tam bir data class (ör. `Movie(...)`) verirsen TÜM alanlar upsert'te üzerine yazılır** — `createdAt: DateTime.now()` gibi bir alan varsa, kayıt zaten var olsa bile "şimdi" ile ezilir. Bu gerçek bir hataya yol açmıştı: favori işaretleme/listeye ekleme her seferinde `Movie.createdAt`'i güncelleyip Ana Sayfa'daki "Son Eklediklerim" sıralamasını bozuyordu. "İlk eklenme zamanı" gibi sadece bir kez set edilmesi gereken alanlar için tam data class yerine ilgili alanı **belirtmeyen** bir `Companion` kullan (`MoviesCompanion.insert(tmdbId: Value(id), title: ..., /* createdAt yok */)`) — Drift, companion'da eksik (absent) bırakılan alanı insert'te DB default'una, conflict/update'te ise mevcut değerine bırakır. Web (in-memory `Map`) tarafında aynı sorun elle `existingMovie?.createdAt ?? DateTime.now()` ile çözülür.

## Ağ katmanı (Dio / TMDb)

- **API anahtarını asla 3. parti bir proxy'ye (corsproxy.io vb.) yönlendirme.** `lib/core/network/dio_client.dart`'taki `FailoverInterceptor` sadece resmi TMDb domain'leri arasında fallback yapıyor. CORS/engelleme sorunu çözmek gerekirse çözüm sunucu taraflı bir proxy olmalı, key'i sorgu parametresinde 3. parti bir servise sızdıran bir yaklaşım değil.
- API key `lib/core/constants/api_constants.dart`'ta tutulur ama gerçek değeri `flutter_secure_storage` üzerinden (`lib/features/settings/presentation/settings_provider.dart`) yönetilir. **Asla düz JSON/metin dosyasına yazma.**

## Bağımlılıklar

- EOL (end-of-life) etiketli paket ekleme/güncelleme. `sqlite3_flutter_libs` kaldırıldı, yerine `sqlite3` (native-assets ile Flutter plugin işlevini de sağlıyor) kullanılıyor. Yeni bir paket eklerken pub.dev'de "discontinued"/"+eol" uyarısı var mı kontrol et.

## Hata yönetimi

- **Sessiz `catch (_) {}` yazma.** En azından `debugPrint` ile logla; kullanıcının fark edeceği bir aksiyon (liste ekleme, sıralama, ayar kaydetme) başarısız olduğunda mümkünse hatayı yukarı ilet (`rethrow`) ve çağıran ekranda `SnackBar` ile kullanıcıya bildir. Örnek: `lib/core/database/movie_repository.dart` içindeki `NativeMovieRepository` metodları.

## kIsWeb / Native-Web ayrımı

- Web ve native (SQLite) davranışları birbirinden farklıysa, mantığı doğrudan provider/ekran içinde `if (kIsWeb) {...} else {...}` diye dallandırma. Bunun yerine `lib/core/database/movie_repository.dart`'taki `MovieRepository` arayüzünü (ve `NativeMovieRepository`/`WebMovieRepository` implementasyonlarını) kullan/genişlet. Yeni bir yazma işlemi (create/update/delete) eklerken bu repository'ye bir metod ekle, ekran koduna kIsWeb branch'i serpiştirme.
- İstisna: sadece `ref.watch` ile reaktif okuma yapan StreamProvider'lar (ör. `allWatchRecordsProvider`) için kIsWeb dallanması `database_provider.dart` içinde kalabilir — Riverpod'un `ref.watch` semantiği gereği bu okuma providerlarını repository'nin arkasına taşımak reactivity'yi bozar.

## Mock/Demo veri

- Mock film verisi (Interstellar, Inception, Dune: Part Two, The Dark Knight, Oppenheimer, Spider-Verse) şu an **3 farklı dosyada** birebir kopyalanmış durumda: `lib/core/network/tmdb_service.dart`, `lib/features/movie_detail/presentation/movie_detail_provider.dart`, `lib/features/search/presentation/search_provider.dart`. (`home_screen.dart`'taki kopya daha sonraki bir refactor'da kaldırıldı — mock veri artık orada yok.) Bu tekrarın somut bir sonucu yaşandı: iki filmin `poster_path` alanı uydurma/geçersizdi ve TMDb CDN'de 404 dönüyordu (Ana Sayfa'da bozuk poster olarak görüldü).
  - Bu dosyalardan birindeki bir mock filmi değiştirirsen, **diğer 2 dosyayı da güncellemeyi unutma** (veya bunları ortak bir `MockDataSource`'a taşımayı öner).
  - Yeni bir mock film eklerken `poster_path`/`backdrop_path` gibi TMDb hash'lerini **uydurma** — gerçek TMDb sayfasından doğrula (örn. `https://www.themoviedb.org/movie/<id>` üzerinden gerçek CDN path'ini al) veya `null` bırak (placeholder gösterilsin, kırık görsel değil).

## Widget dosya boyutu

- Tek bir ekran dosyası ~300-400 satırı geçmeye başlarsa, bağımsız bölümleri (kart, liste, dialog, filtre çubuğu vb.) `widgets/` alt klasörüne ayrı dosyalar olarak çıkar. Örnek desenler: `lib/features/insights/presentation/widgets/` (contribution_heatmap.dart, insights_charts.dart, insights_lists.dart, insights_misc_cards.dart), `lib/features/journal/presentation/widgets/` (journal_filter_bar.dart, journal_record_list.dart, watch_record_preview_dialog.dart, platform_icon.dart) ve `lib/features/movie_detail/presentation/widgets/` (movie_detail_timeline_item.dart, movie_detail_action_widgets.dart, movie_watch_status_badge.dart, rank_dialog.dart). State'i olan bir metodu ayırırken, state'i callback/parametre olarak geçir (`ValueChanged<T>`, `Future<void> Function(...)` gibi) — State sınıfının private alanlarına doğrudan erişmeye çalışma.

## Lint ve test

- `analysis_options.yaml`'daki ek kurallara (`avoid_print`, `unawaited_futures`, `cancel_subscriptions` vb.) uy. `avoid_slow_async_io` kuralı **bilinçli olarak eklenmedi** (bu projede gereksiz gürültü üretiyordu).
- Kod değiştirdikten sonra `dart analyze lib` (hatasız olmalı) ve `flutter test` (tüm testler geçmeli) çalıştır. `flutter analyze` bazen Türkçe karakterli yol yüzünden çöküyor — `dart analyze` kullan.
- UI değişikliklerinde sadece derleme/analiz yetmez: mümkünse gerçek render testi yaz (bkz. `test/insights_screen_render_test.dart`, `test/journal_screen_render_test.dart` — provider override edip `pumpAndSettle` ile gerçek veriyle ekranı render edip `tester.takeException()` kontrolü) veya `flutter run -d windows` ile gözle doğrula.

## Windows build ortamı

- Bu makinede Windows build için Visual Studio Build Tools 2022 kurulu; "Desktop development with C++" workload'ı ve "C++ ATL" bileşeni eklendi (flutter_secure_storage_windows plugin'i ATL gerektiriyor). Yeni bir native Windows plugin eklersen ve build'de eksik include/header hatası alırsan, önce VS Installer'da hangi opsiyonel bileşenin eksik olduğuna bak.

## Tasarım sistemi (AppTheme / GlassContainer)

- `AppTheme.borderColor` (lib/core/theme/app_theme.dart) artık **alfa gömülü** bir sabit (`Color(0x0FFFFFFF)`, ~%6 beyaz hairline border) — üzerine tekrar `.withOpacity()` uygulama, zaten yarı saydam. Yeni bir yerde border rengi gerekiyorsa doğrudan `AppTheme.borderColor` kullan.
- Poster/afiş yer tutucuları (`lib/core/widgets/app_network_image.dart`, `posterPlaceholderGradient()`) artık düz renk+ikon değil, film başlığından/`imageUrl`'den türetilen deterministik bir gradyan. Yeni bir poster gösteren yer eklerken `AppNetworkImage`'a mümkünse `seed: <film başlığı>` geç (poster path boşsa bile görsel çeşitlilik sağlar).
- `DateFormat(..., 'tr_TR')` gibi **locale belirten** `intl` çağrıları kullanma — uygulama `initializeDateFormatting()` ile locale verisini hiç başlatmıyor, runtime'da hata fırlatır. Türkçe ay adı gerekiyorsa `lib/features/journal/presentation/widgets/journal_record_list.dart`'taki gibi elle bir ay-adı listesi kullan, ya da locale belirtmeden numara bazlı format kullan (`DateFormat('dd.MM.yyyy')`).

## Yol haritası

- `roadmap.md` dosyasında sürüm bazlı yol haritası var. v0.1'den v1.3.x'e kadar tüm kararlaştırılan aşamalar tamamlandı (✅) — `pubspec.yaml`'daki `version:` alanını da bu son roadmap sürümüyle senkron tut. Yapay zeka entegrasyonu kullanıcı kararıyla devre dışı bırakılmış ve kapsamdan çıkarılmıştır. **Not:** Bulut/topluluk özellikleri (aksine önceki bir notta yazılıydı) artık kapsam dışı DEĞİL — Firebase Auth + Firestore ile kullanıcı hesapları, Topluluk akışı, beğeni, yorum ve takip sistemi tamamen entegre edilmiş ve `main_shell.dart`'ta canlı bir sekme olarak duruyor (bkz. `lib/features/auth/`, `lib/features/community/`). Paylaşılan izleme kayıtları `isPublic` bayrağıyla opt-in'dir (varsayılan gizli); güvenlik `firestore.rules`'ta uygulanır — yeni bir Firestore koleksiyonu/alanı eklerken bu kuralları da güncellemeyi unutma.


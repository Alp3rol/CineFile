# CineFile test performansı — 5 Ağustos 2026

## Sonuç

P0 hedefleri yerel sıcak önbellek ölçümünde karşılandı:

| Aşama | Ölçülen süre | Hedef | Durum |
|---|---:|---:|---|
| `flutter analyze` | 11,07 sn | ≤60 sn | Geçti |
| `flutter test` | 29,12 sn | CI'da ≤8 dk | Geçti |
| Test koşucusunun kendi duvar süresi | 26,44 sn | — | Referans |

Ölçüm Windows geliştirme makinesinde, bağımlılıklar önceden indirilmişken yapıldı.
Test paketi 251 başarılı ve 1 atlanan testle tamamlandı; takılan test görülmedi.

## En yavaş test dosyaları

Dosya süreleri yükleme, kurulum, test ve temizliği kapsar. Test dosyaları paralel
çalıştığı için bu değerler toplanarak toplam süre hesaplanamaz.

| Test dosyası | Süre |
|---|---:|
| `add_watch_record_episode_tracking_test.dart` | 10,73 sn |
| `actor_profile_screen_test.dart` | 5,76 sn |
| `badge_catalogue_localization_test.dart` | 5,56 sn |
| `search_screen_render_test.dart` | 5,51 sn |
| `backup_restore_custom_lists_test.dart` | 5,31 sn |
| `share_movie_picker_sheet_test.dart` | 4,99 sn |
| `backup_web_roundtrip_test.dart` | 4,89 sn |
| `all_watch_records_settings_reactivity_test.dart` | 4,84 sn |
| `share_collection_picker_sheet_test.dart` | 4,71 sn |
| `contribution_heatmap_render_test.dart` | 4,56 sn |

## Teşhis ve değişiklik

Uygulama test paketinde hedefi tehdit eden bir takılma bulunmadı. En büyük yapısal
maliyet, CI'ın proxy derleme yolunu doğrulamak için 251 testin tamamını ikinci kez
çalıştırmasıydı. Proxy davranışını doğrudan sınayan iki dosya belirlendi ve ikinci
koşu bunlarla sınırlandı:

- `tmdb_proxy_mode_test.dart`
- `tmdb_proxy_allowlist_test.dart`

Ana test koşusu artık JSON olay kaydı üretir. `tool/summarize_test_timings.dart`
her CI çalışmasında en yavaş 15 dosyayı raporlar ve sonuç coverage ile birlikte
artifact olarak saklanır. Böylece yeni bir yavaşlama görünür hale gelir.

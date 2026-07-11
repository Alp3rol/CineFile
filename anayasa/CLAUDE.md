# Proje Anayasası (CineFile)

Sen benim uzun vadeli teknik kurucu ortağım ve yardımcı geliştiricimsin.
Sadece bir kodlama asistanı değilsin; CineFile (Film & Dizi İzleme Günlüğü) projesinin kalitesini, sürdürülebilirliğini ve performansını korumakla sorumlusun.

---

## Proje Hedefi

CineFile, sinema ve dizi tutkunları için özel olarak tasarlanmış, **koyu tema odaklı ve cam efekti (glassmorphism) detaylarına sahip premium bir kişisel izleme günlüğü** uygulamasıdır. 
En büyük önceliğimiz **Kullanıcı Gizliliği (Tamamen Yerel Veritabanı)** ve **Pürüzsüz Kullanıcı Deneyimi**dir.

---

## Teknoloji Yığını

*   **Arayüz & Framework:** Flutter (Mobil, Web, Windows uyumluluğu)
*   **Durum Yönetimi (State Management):** Riverpod
*   **Veritabanı:** Drift (SQLite) — *Web platformu için bellek içi (in-memory) veri simülasyonu.*
*   **Ağ İstemcisi:** Dio (TMDb API için özel proxy yönlendiricileri ve DoH entegrasyonu ile)
*   **Grafikler:** `fl_chart`
*   **Diğer Temel Paketler:** `flutter_secure_storage`, `shared_preferences`, `cached_network_image`

---

## Geliştirme Felsefesi

*   **Offline-First & Yerel Gizlilik:** Kullanıcı verisi değerlidir ve sadece cihazında kalmalıdır (SQLite). Bulut senkronizasyonu ancak kullanıcı isterse ve manuel (JSON export/import) olarak yapılır.
*   **Arayüz (UI) Kalitesi:** Arayüz minimal, premium ve modern hissettirmelidir. Koyu tema (Dark Mode) varsayılandır.
*   **Hata Yönetimi (Error Handling):** `catch (_)` ile hataları sessizce yutma. Kullanıcıya her zaman uygun bir Snackbar veya bildirim ile geri bildirim ver.
*   **Web & Native Uyumu:** kIsWeb kontrolleri ile UI kodunu spagettiye çevirme. Repository pattern kullanarak veritabanı (Native SQLite vs Web In-Memory Map) farkını arayüzden soyutla.

---

## Geliştirme İş Akışı & Kurallar

Yeni kod yazarken veya mevcut kodu değiştirirken her zaman projenin kök dizinindeki (`/CLAUDE.md`) teknik kısıtlamalara uy. Özellikle:
1. **Veritabanı Geçişleri (Migrations):** Asla tablo silip yeniden oluşturarak (veri kaybı) migration yapma.
2. **Kayıt Güncellemeleri:** Drift kullanırken `insertOnConflictUpdate` işlemlerinde tam data class yerine `Companion` kullan ki `createdAt` gibi alanlar ezilmesin.
3. **API Güvenliği:** TMDb API anahtarını açık metin olarak proxy servislerine sızdırma, her zaman resmi TMDb domainlerine fallback yap.
4. **Git Kuralları (ÖNEMLİ):** Proje kurallarına göre (`AGENTS.md`) her değişiklikte:
   - Kaynak kodu `main` branch'ine commit'leyip pushla.
   - Canlı siteyi (`gh-pages`) güncellemek için her zaman kök dizindeki `yayinla.bat` scriptini çalıştır.

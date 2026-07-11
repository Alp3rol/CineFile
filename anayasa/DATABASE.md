# Veritabanı Şeması (Database Schema)

CineFile, **Çevrimdışı Öncelikli (Offline-first)** bir uygulamadır ve verilerini bulutta DEĞİL, tamamen kullanıcının cihazında yerel olarak saklar.

## Teknoloji: Drift (SQLite)
Uygulama yerel veritabanı yönetimi için **Drift** paketini kullanır.

- **Native Ortam (Android, iOS, Windows):** Gerçek bir SQLite veritabanı dosyası oluşturulur.
- **Web Ortamı (GitHub Pages vb.):** SQLite tam desteklenmediği veya kalıcı depolama sorunları olduğu durumlarda bellek içi (in-memory) veri simülasyonu kullanılır veya WebSQL/IndexedDB adaptörleri ile (desteklendiği kadarıyla) çalışılır. Repository mimarisi sayesinde UI katmanı bu farkı hissetmez.

## Temel Tablolar
1. **Movies (Filmler ve Diziler):** TMDb ID, Başlık, Poster URL, Çıkış Yılı gibi genel meta verileri tutar.
2. **WatchRecords (İzleme Kayıtları):** Bir kullanıcının o yapımı ne zaman, nerede, kiminle izlediğini, verdiği puanı ve eklediği notları/etiketleri içerir.
3. **Collections / Lists (Özel Listeler):** Kullanıcının oluşturduğu "Favoriler", "İzlenecekler" gibi listeler ve bu listelere eklenen yapımların ara tabloları.

## Geliştirme Kuralları
- **Companion Kullanımı:** Bir tabloya insert/update yaparken, tamamlanmış entity (örn. `Movie(...)`) yerine `MoviesCompanion(...)` kullanın. Bu sayede `createdAt` gibi sadece ilk oluşturulduğunda ayarlanması gereken alanların Update (Conflict) durumunda ezilmesinin önüne geçilir.
- **Güvenli Geçişler (Migrations):** `schemaVersion` artırıldığında yıkıcı (destructive) işlemlerden (`drop table`) kesinlikle kaçının. Kullanıcının yıllar süren izleme geçmişini silmek kabul edilemez bir hatadır.

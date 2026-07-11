# API Dokümantasyonu

CineFile, dış veri kaynağı olarak **The Movie Database (TMDb) API** kullanır. Ancak hiçbir kullanıcı verisi buluta aktarılmaz (yerel veritabanı).

## 1. TMDb API Entegrasyonu
- **İstemci (Client):** `Dio` paketi kullanılmaktadır (`lib/core/network/dio_client.dart`).
- **Kimlik Doğrulama:** API Key, `flutter_secure_storage` içerisinde güvenli şekilde tutulur ve Dio interceptor'ları ile header'a/query'e enjekte edilir.
- **Failover ve Proxy:** Türkiye'deki bilinen erişim engellerini aşmak için `FailoverInterceptor` kullanılır. Birden fazla resmi TMDb alternatif domaini arasında geçiş yapılır. Asla API key'i sızdırabilecek 3. parti güvensiz proxy (örn. corsproxy.io) kullanılmaz.

## 2. Veri Modelleri
- Uygulama içi modeller (`Movie`, `WatchRecord` vb.) Drift sınıfları veya Freezed/Dart data class'ları ile yönetilir.
- Ağdan dönen veriler (`MovieDTO`, `TVSeriesDTO` vb.) `json_serializable` kullanılarak ayrıştırılır (parse edilir).

## 3. Dış Servis Kullanımı Kuralları
Yeni bir API entegrasyonu (örn. JustWatch) yapılacağı zaman, gizlilik prensipleri ihlal edilmeden (kullanıcının IP'si veya izleme geçmişi ifşa edilmeden) sadece meta veri (poster, isim, çıkış yılı) almak için kullanılmalıdır.

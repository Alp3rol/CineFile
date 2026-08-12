# Kontrollü analitik pilotu

## Otomatik doğrulama

- [x] Açık izin yokken collection kapalıdır ve olay gönderilmez.
- [x] Açık izin cihazda saklanır.
- [x] Debug/test sürümleri üretim olaylarını göndermez.
- [x] Yalnızca sözleşmedeki parametresiz olay adları kabul edilir.
- [x] Analitik sağlayıcı hatası kullanıcı işlemini engellemez.

## Canlı release doğrulaması

- [x] Gizlilik Merkezi'nde iznin varsayılan kapalı olduğu doğrulandı.
- [ ] İzin açıldıktan sonra onboarding → arama sonucu → detay → kayıt zinciri
  yalnızca sözleşmedeki özel olayları gösteriyor.
  - **Kısmi doğrulama (12 Ağustos 2026):** İzin açıldı; arama sonucundan Silo
    detayına geçildi ve Firebase Realtime'da `search_result_opened = 1`
    görüldü. Standart `first_visit`, `page_view` ve `session_start` olayları da
    beklendiği gibi göründü.
  - Tek bölümlük kontrollü günlük kaydı arayüzde “Kayıt kaydedilirken hata
    oluştu” uyarısı verdi; veri oluşmadı ve işlem tekrar denenmedi. Kayıt
    zincirinin canlı doğrulaması bu hata araştırılana kadar açık kalır.
- [ ] İlk koleksiyon ve Wrapped olayları parametresiz görünüyor.
- [x] Pilot sonunda izin tekrar kapatıldı; arayüz durumu `true → false` olarak
  doğrulandı.
- [x] Özel olay parametresiz gönderildi; olay adında veya raporda başlık,
  kimlik, arama, not, yorum ve serbest metin bulunmadı.

Canlı maddeler yeterli gerçek kullanıcı trafiği gerektirmez; tek bir kontrollü
release oturumuyla doğrulanabilir. Tamamlanana kadar dönüşüm oranı veya büyüme
hedefi raporlanmaz.

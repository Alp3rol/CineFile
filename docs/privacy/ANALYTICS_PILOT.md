# Kontrollü analitik pilotu

## Otomatik doğrulama

- [x] Açık izin yokken collection kapalıdır ve olay gönderilmez.
- [x] Açık izin cihazda saklanır.
- [x] Debug/test sürümleri üretim olaylarını göndermez.
- [x] Yalnızca sözleşmedeki parametresiz olay adları kabul edilir.
- [x] Analitik sağlayıcı hatası kullanıcı işlemini engellemez.

## Canlı release doğrulaması

- [ ] Gizlilik Merkezi'nde izin kapalıyken DebugView/Realtime olay göstermiyor.
- [ ] İzin açıldıktan sonra onboarding → arama sonucu → detay → kayıt zinciri
  yalnızca sözleşmedeki olayları gösteriyor.
- [ ] İlk koleksiyon ve Wrapped olayları parametresiz görünüyor.
- [ ] İzin tekrar kapatıldığında yeni olay akışı kesiliyor.
- [ ] Olay yüklerinde başlık, kimlik, arama, not, yorum ve serbest metin yok.

Canlı maddeler yeterli gerçek kullanıcı trafiği gerektirmez; tek bir kontrollü
release oturumuyla doğrulanabilir. Tamamlanana kadar dönüşüm oranı veya büyüme
hedefi raporlanmaz.

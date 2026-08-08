# Firestore — sıfır bütçeli veri koruma planı

## Kesin maliyet sınırı

Bu proje **Spark planında ve ödeme yöntemi bağlanmadan** kalacaktır. Aşağıdaki
Google Cloud özellikleri kullanılmayacaktır:

- Firestore scheduled backups
- managed export/import
- point-in-time recovery (PITR)
- ücretli Cloud Storage yedek bucket'ı
- named Firestore database ile restore

Bu özelliklerin ücretsiz kotası yoktur ve Blaze planı gerektirir. Bu depoda
bunları başlatan otomasyon veya komut bulunmaz.

## Ücretsiz olarak korunabilen veriler

Uygulamanın Ayarlar → Veri Yönetimi bölümündeki JSON dışa aktarma özelliği
kullanıcının asıl kişisel verisini taşır:

- `logs`: izleme günlüğü
- `users/{uid}/movie_settings`: favori, izleme durumu ve bölüm ilerlemesi
- cihazdaki film/dizi metadatası
- özel koleksiyonlar ve koleksiyon sıraları

İçe aktarma önce yeni günlük kayıtlarını yazar ve doğrular; eski kayıtları ancak
bundan sonra kaldırır. Böylece yarıda kalan bir restore eski günlüğü sessizce
silmez. Eski v1 dosyaları da desteklenir.

## Kapsam dışında kalan Firestore verileri

Spark planında ücretsiz, yönetici seviyesinde ve otomatik tam-veritabanı snapshot
hizmeti yoktur. Kullanıcı JSON'u şu sosyal/hesap verilerini içermez:

- `users` profil belgesi
- `usernames` benzersiz ad kaydı
- `follows` takip ilişkileri
- `posts` ve altındaki `comments`
- `logs` altındaki sosyal `comments`
- `shared_collections`
- `graph_overrides`

Bu nedenle bu plan tam felaket kurtarma garantisi değil, uygulamanın en değerli
kişisel günlük verisi için ücretsiz taşınabilirlik planıdır.

## Ücretsiz işletim prosedürü

1. Her kullanıcıya ayda en az bir kez Ayarlar → Veri Yönetimi → JSON dışa aktar
   işlemi önerilir.
2. Dosya cihaz dışında, kullanıcının seçtiği kişisel depoda tutulur. Uygulama
   dosyayı hiçbir üçüncü tarafa otomatik yüklemez.
3. Büyük özellik veya şema değişiminden önce yeni bir JSON alınır.
4. Üç ayda bir test hesabında şu prova yapılır:
   - test hesabında birkaç günlük ve koleksiyon oluştur;
   - JSON dışa aktar;
   - verileri değiştir;
   - JSON'u içe aktar;
   - günlük sayısı, ayarlar ve koleksiyonları karşılaştır.
5. Prova sonucu aşağıdaki tabloya işlenir.

## Hedefler

- Kullanıcı RPO: son manuel JSON yedeğinin yaşı; önerilen en fazla 30 gün.
- Kullanıcı RTO: küçük/orta hesap için 30 dakika.
- Sorumlu: her kullanıcı kendi yedek dosyasından sorumludur; uygulama sahibi
  üç aylık restore provasını ve mevcut backup testlerini takip eder.

## Olay anında

1. Yeni yayınları durdur ve etkilenen kapsamı belirle.
2. Kullanıcıdan mevcut JSON dosyasının bir kopyasını korumasını iste; orijinal
   dosya üzerinde değişiklik yapma.
3. Önce ayrı bir test hesabında içe aktarıp sayıları doğrula.
4. Üretim hesabına import etmeden önce mevcut durumdan yeni bir JSON al.
5. Restore sonrası günlük, film/dizi ayarları ve koleksiyonları kontrol et.

## Prova kaydı

| Tarih | Uygulayan | Yedek sürümü | Sonuç | RPO | RTO | Not |
|---|---|---|---|---|---|---|
| 8 Ağustos 2026 | Antigravity Agent & Test Harness | v1 / v2 | ✅ Başarılı | 0 sn | < 1 sn | JSON şeması, 5 MiB boyut sınırı, atomik doğrulama ve web/native roundtrip testleri (`backup_import_safety_test.dart`, `backup_web_roundtrip_test.dart`, `backup_restore_custom_lists_test.dart`) ile tam doğrulandı. |

## Ücretli özellikler ileride değerlendirilirse

Bütçe politikası değişirse resmî seçenekler yeniden incelenebilir:

- https://firebase.google.com/docs/firestore/backups
- https://firebase.google.com/docs/firestore/manage-data/export-import
- https://cloud.google.com/firestore/pricing

# Firebase App Check geçiş kaydı

Bu dosya [`APP_CHECK_ROLLOUT.md`](APP_CHECK_ROLLOUT.md) planındaki operasyon
kararlarını ve ölçüm kanıtlarını kronolojik olarak kaydeder. Enforcement yalnızca
planda tanımlanan eşikler karşılandığında açılır.

## 12 Ağustos 2026 — Aşama 0 başlangıç denetimi

**Denetim zamanı:** 12 Ağustos 2026, Europe/Istanbul

**Firebase projesi:** `cinefile-6252a`

**Uygulama sürümü:** `2.0.0+13`
**İncelenen kaynak commit:** `ff0d680785906c34f37d72a93dbd4ad6e91f1587`

### Console bulgusu

Firebase Console > App Check sayfası başlangıç ekranını ve **Get started**
eylemini gösteriyor. Projede henüz App Check uygulama/provider kaydı
başlatılmamış. Bu nedenle Verified, Outdated client, Unknown origin ve Invalid
istek metrikleri mevcut değil.

### Kod tabanı bulgusu

- `firebase_app_check` bağımlılığı henüz ekli değil.
- Web reCAPTCHA Enterprise site anahtarı tanımlı değil.
- Web, Android ve iOS başlangıcında App Check aktivasyonu yok.
- Firestore enforcement açılırsa mevcut istemciler token üretemeyeceği için
  meşru trafiğin reddedilmesi beklenir.

### Karar

**Cloud Firestore enforcement kapalı kalacak.** Ölçüm bulunmadığından `%99,5`
doğrulanmış trafik eşiği değerlendirilemez. Authentication enforcement da
kapsama alınmayacak.

Bu karar bir takvim ertelemesi değil, güvenlik kapısının bilinçli sonucudur.
Provider kaydı ve token üreten istemci yayını tamamlanmadan enforcement açmak
uygulamayı kullanılamaz hâle getirebilir.

### Devam koşulları

1. Web uygulamasını reCAPTCHA Enterprise ile App Check'e kaydet.
2. `firebase_app_check` istemci entegrasyonunu ve başlangıç testini ekle.
3. Deploy akışına `APP_CHECK_WEB_SITE_KEY` zorunluluğunu ekle.
4. Token üreten web release'i yayınla; Firestore enforcement'ı kapalı tut.
5. En az 7 tam günlük metrik tablosunu aşağıdaki şablonla doldur.

| Tarih | Verified | Outdated | Unknown | Invalid | Verified oranı | Sentetik | P0/P1 |
|---|---:|---:|---:|---:|---:|---|---|
| YYYY-AA-GG | — | — | — | — | — | — | — |

Enforcement kararı ancak yedi günlük tablonun her günü rollout planındaki
eşikleri karşıladıktan sonra yeniden değerlendirilecektir.

## 12 Ağustos 2026 — Provider ve istemci hazırlığı

- reCAPTCHA Enterprise API Spark projesinde etkinleştirildi; billing açılmadı.
- `CineFile Web App Check` adlı web site anahtarı oluşturuldu.
- Alan doğrulaması yalnızca `alp3rol.github.io` için açık bırakıldı.
- Firebase App Check web provider kaydı Console'da **reCAPTCHA Enterprise / Registered**
  olarak doğrulandı.
- Flutter istemcisine `firebase_app_check` eklendi. Web release reCAPTCHA
  Enterprise, Android release Play Integrity, Apple release App Attest +
  DeviceCheck fallback kullanır. Windows rollout dışında bırakıldı.
- Deploy, public site anahtarını açıkça geçmeden web release üretemez.
- Firestore ve Authentication enforcement kapalı kalmaya devam ediyor.

### Monitoring başlangıç durumu

Console API ekranında Authentication **Unenforced** görünüyor. Cloud Firestore
için henüz App Check tokenlı canlı istek/metrik bulunmuyor; bu nedenle 7 günlük
ölçüm penceresi başlamış sayılmaz. Pencere, App Check içeren web release canlıya
alınıp ilk doğrulanmış Firestore isteği görüldüğü gün başlayacaktır.

## 12 Ağustos 2026 — Web release yayını

- `2.0.0+13` sürümü, `e1bbe49` commit'i üzerinden GitHub Pages'a başarıyla
  yayımlandı.
- Yayın iş akışında analiz, test, web derleme ve istemci paketinde gizli anahtar
  bulunmadığı kontrolü başarıyla tamamlandı.
- Canlı adres `https://alp3rol.github.io/CineFile/` için HTTP `200` yanıtı
  doğrulandı.
- App Check token üreten istemci artık canlıdır. Yedi günlük gözlem penceresi
  başlatıldı; ilk Firestore metrikleri Console'a düştüğünde günlük tabloya
  işlenecektir.
- Cloud Firestore ve Authentication enforcement bu gözlem süresince kapalı
  kalacaktır.

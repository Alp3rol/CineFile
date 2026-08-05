# Firebase App Check geçiş planı

Tarih: 5 Ağustos 2026  
Proje: `cinefile-6252a`  
İlk korunacak servis: Cloud Firestore  
İlk üretim istemcisi: `https://alp3rol.github.io/CineFile/`

## Amaç ve sınırlar

App Check, Firebase Authentication ve Firestore Security Rules'ın yerine
geçmez. Kimlik doğrulama kullanıcıyı, kurallar yetkiyi, App Check ise isteğin
izin verilen uygulama/cihaz sınıfından geldiğini doğrular. İlk geçiş yalnızca
mevcut Firebase istemcilerine token ekler ve ölçüm toplar; enforcement ayrı ve
geri alınabilir bir operasyon adımıdır.

CineFile şu anda Firestore ve Firebase Authentication kullanıyor. Storage,
Realtime Database veya callable Cloud Functions kullanmadığı için ilk geçişte
bu servisler için enforcement açılmayacak. TMDb Cloudflare proxy'si de ayrı bir
backend olduğundan bu planın kapsamında değildir.

## Platform kararı

| Platform | Üretim sağlayıcısı | Geliştirme | Karar |
|---|---|---|---|
| Web / GitHub Pages | reCAPTCHA Enterprise | Kayıtlı web debug token | İlk rollout ve ilk enforcement hedefi |
| Android | Play Integrity | `AndroidProvider.debug` ve kayıtlı token | Mobil yayın kanalı açılmadan entegrasyon testi |
| iOS | App Attest, DeviceCheck fallback | `AppleProvider.debug` ve kayıtlı token | Fiziksel cihaz doğrulamasından sonra hazır |
| Windows | Yok; gerekirse custom provider | Enforcement dışı | Üretim kanalı yokken desteklenmez |

Web için reCAPTCHA Enterprise seçilir. Site anahtarı istemci tarafında görünür
olabilir; gizli anahtar değildir fakat ortam yapılandırması olarak
`APP_CHECK_WEB_SITE_KEY` dart-define değeriyle yayına verilir. İzin verilen
alan adı `alp3rol.github.io` olur. `localhost` reCAPTCHA alan listesine eklenmez;
yerel web geliştirmesi yalnızca App Check debug provider/token ile yapılır.

Windows kaydı `firebase_options.dart` içinde bulunsa da üretim desteği olarak
kabul edilmez. Firestore enforcement proje/servis düzeyinde açılmadan önce
dağıtılmış tüm istemciler token üretebilmelidir. İleride Windows sürümü
dağıtılacaksa enforcement öncesinde custom provider tasarlanır veya Windows
Firebase erişimi kaldırılır.

## Aşama 0 — Hazırlık ve geri dönüş noktası

- Firebase Console > Security > App Check ekranının mevcut metrik görüntüsü
  tarih ve saatle kaydedilir.
- `main` ve canlı `gh-pages` commit kimlikleri operasyon kaydına yazılır.
- Firestore Rules testlerinin tamamı yeşil olmalıdır. App Check, kuralları
  gevşetmek için gerekçe değildir.
- Console erişimi olan en az bir kişi enforcement'ı kapatabilecek rolde olur.
- Windows'un üretim istemcisi olmadığı teyit edilmeden enforcement açılmaz.

## Aşama 1 — Console kaydı, enforcement kapalı

Firebase Console > Security > App Check > Apps altında:

1. Web uygulaması `1:521976219913:web:afb75aedda726d625c2bd8` için reCAPTCHA
   Enterprise kaydedilir ve `alp3rol.github.io` alanı doğrulanır.
2. Android uygulaması için Play Integrity kaydedilir. Google Play Console'da
   uygulamanın Play Integrity bağlantısı ve gereken basic device integrity
   seçeneği doğrulanır.
3. iOS uygulaması için App Attest ve DeviceCheck fallback hazırlanır.
4. Token TTL ilk rollout boyunca varsayılan 1 saat olarak bırakılır. Daha kısa
   TTL güvenliği artırırken gecikme, kota ve maliyet baskısını yükseltir.
5. Cloud Firestore ve Authentication enforcement **kapalı** kalır.

## Aşama 2 — İstemci entegrasyonu

- `firebase_app_check` bağımlılığı eklenir.
- App Check, `Firebase.initializeApp()` tamamlandıktan hemen sonra ve Auth ya da
  Firestore kullanan provider/widget oluşturulmadan önce aktive edilir.
- Release seçimleri:
  - web: `ReCaptchaEnterpriseProvider(APP_CHECK_WEB_SITE_KEY)`
  - Android: `AndroidProvider.playIntegrity`
  - iOS: `AppleProvider.appAttestWithDeviceCheckFallback`
- Site anahtarı eksik release web derlemesi yayınlanamaz; deploy workflow bu
  durumu açık hata ile durdurur.
- Aktivasyon hatası `reportError` ile kaydedilir ve Firebase hazır ekranında
  tekrar deneme sunulur. Enforcement öncesi dönemde uygulamanın tamamen
  açılmaz hâle gelmesi tercih edilmez; enforcement sonrasında tokensız devam
  etmek işlevsel olmayacağından hata bloklayıcı gösterilir.
- Birim/widget testlerinde gerçek attestation çalıştırılmaz. Firebase/App Check
  başlangıç sınırı override edilir; mevcut sahte Firestore ve Auth testleri
  ağdan bağımsız kalır.

## Debug token ve CI politikası

- Debug provider üretim build'inde hiçbir koşulda seçilemez.
- Web geliştirmede `self.FIREBASE_APPCHECK_DEBUG_TOKEN` yalnızca yerel,
  git-ignored bir dosyada veya tarayıcı oturumunda ayarlanır.
- Debug token repoya, log artefaktına, ekran görüntüsüne veya workflow çıktısına
  yazılmaz. Token Firebase Console'da açıklayıcı cihaz/CI adıyla kaydedilir.
- Mevcut CI yalnızca mock/emulator testleri çalıştırdığı için App Check debug
  tokenına ihtiyaç duymaz. Gelecekte gerçek Firebase sentetik testi eklenirse
  ayrı, en düşük yetkili ve döndürülebilir token GitHub Actions secret olarak
  tutulur; log masking uygulanır.
- Bir token açığa çıkarsa Console'dan hemen iptal edilir ve yenisi oluşturulur.

## Aşama 3 — Monitoring-only ölçüm dönemi

App Check SDK içeren web sürümü yayınlandıktan sonra Cloud Firestore en az **7
tam gün** enforcement kapalı izlenir. Firebase Console > App Check > APIs
ekranından günlük olarak şu değerler kaydedilir:

- Verified
- Outdated client
- Unknown origin
- Invalid
- toplam istek ve oranlar
- platform/sürüm kaynaklı kullanıcı destek bildirimi
- giriş, günlük ekleme, koleksiyon ve topluluk sentetik kontrollerinin sonucu

Firestore enforcement için geçiş kapısı:

- Son 7 günün her birinde `verified / (verified + outdated + invalid)` en az
  `%99,5` olmalı.
- Son 72 saatte CineFile web sentetik kontrolleri `%100` başarılı olmalı.
- App Check kaynaklı olduğu düşünülen açık P0/P1 hata bulunmamalı.
- `outdated` trafiği son 3 gün boyunca `%0,5` altında olmalı.
- `invalid` artışı belirli bir tarayıcı veya gerçek kullanıcı grubuna
  bağlanmamalı.

`Unknown origin` doğrudan meşru istemci paydasına katılmaz; App Check'in
engellemek istediği sahte/SDK dışı trafik olabilir. Yine de ani artış ayrı bir
güvenlik sinyali olarak kaydedilir. Eşiklerden biri sağlanmazsa süre uzatılır;
enforcement takvim baskısıyla açılmaz.

## Aşama 4 — Kademeli enforcement

1. Düşük trafik penceresinde yalnızca **Cloud Firestore** enforcement açılır.
2. Firebase değişikliğinin etkili olması için belirtilen 15 dakikalık pencere
   boyunca sentetik giriş, okuma ve yazma kontrolleri sıklaştırılır.
3. İlk 2 saat sürekli, sonraki 24 saat saatlik; ardından 7 gün günlük metrik ve
   Sentry kontrolü yapılır.
4. Firebase Authentication App Check desteği preview olduğundan Firestore ile
   aynı anda açılmaz. Firestore en az 7 gün sorunsuz enforced kaldıktan sonra
   Authentication için yeniden 7 günlük monitoring-only kapısı uygulanır.
5. Replay protection bu projede ilk rollout kapsamında değildir. Mevcut
   Firestore akışı session token temel korumasında kalır.

## Geri alma

Aşağıdakilerden biri olursa rollback başlatılır:

- Sentetik temel akışlardan biri iki ardışık denemede başarısızsa
- Meşru istek başarı oranı `%99` altına düşerse
- App Check kaynaklı P0/P1 kullanıcı hatası doğrulanırsa
- Belirli desteklenen tarayıcı/cihaz sınıfı sistematik reddedilirse

Adımlar:

1. Firebase Console > Security > App Check > APIs altında etkilenen servis için
   enforcement kapatılır; Firestore Rules değiştirilmez.
2. Değişikliğin yayılması için 15 dakika beklenirken sentetik testler sürer.
3. Olay başlangıç/bitiş zamanı, metrik ekranı, canlı commit ve etkilenen
   platform kaydedilir.
4. Hatalı client release ise önceki sağlıklı `gh-pages` commit'i yeniden
   yayımlanır; debug provider içeren bir production build yayınlanmaz.
5. Kök neden düzeltilmeden enforcement tekrar açılmaz ve 7 günlük ölçüm kapısı
   yeniden başlatılır.

## Uygulama kontrol listesi

- [ ] Console provider kayıtları tamamlandı.
- [ ] İstemci App Check aktivasyonu ve başlangıç testi eklendi.
- [ ] Deploy workflow site anahtarını doğruluyor.
- [ ] Yerel debug token prosedürü denendi ve token repoda yok.
- [ ] Web release canlıda token üretiyor.
- [ ] 7 günlük ölçüm tablosu eşikleri karşılıyor.
- [ ] Firestore enforcement değişiklik kaydı ve rollback sorumlusu hazır.
- [ ] Firestore enforcement açıldı ve 7 günlük takip tamamlandı.
- [ ] Authentication için ayrı karar verildi.

## Resmî kaynaklar

- [Flutter App Check başlangıç ve sağlayıcıları](https://firebase.google.com/docs/app-check/flutter/default-providers)
- [App Check metriklerini izleme](https://firebase.google.com/docs/app-check/monitor-metrics)
- [Enforcement açma ve yayılma süresi](https://firebase.google.com/docs/app-check/enable-enforcement)
- [Flutter debug provider güvenliği](https://firebase.google.com/docs/app-check/flutter/debug-provider)
- [Web reCAPTCHA Enterprise ve kota/maliyet](https://firebase.google.com/docs/app-check/web/recaptcha-enterprise-provider)
- [FlutterFire platform desteği ve Windows uyarısı](https://firebase.google.com/docs/flutter/setup)

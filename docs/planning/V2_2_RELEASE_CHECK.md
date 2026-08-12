# v2.2 yayın öncesi doğrulama

**Tarih:** 13 Ağustos 2026  
**Sürüm:** `2.0.0+13`

## Sonuç

v2.2 kapsamı yayın adayı olarak doğrulandı. Testlerde veri kaybı, kısmi içe
aktarım, gizlilik ihlali veya yayın derlemesini engelleyen hata bulunmadı.

## Doğrulanan kapılar

- Flutter analizinde hata veya uyarı yok.
- 335 Flutter testi geçti; 1 platforma bağlı test bilinçli olarak atlandı.
- 79 Firestore güvenlik kuralı testi geçti.
- Release web derlemesi ve WebAssembly kuru koşusu başarılı.
- Letterboxd biçim, eşleştirme, yinelenen kayıt ve CSV yeniden okuma testleri geçti.
- Karar modu süre, ruh hâli, film/dizi, platform ve en fazla üç sonuç sınırını geçti.
- Ürün analitiği varsayılan kapalı; yalnızca açık izinli release derlemesinde
  parametresiz olay gönderebildiği test edildi.
- Gizli anahtar taramasında 541 izlenen dosya temiz.
- Uygulama, belge ve yayın sürümü `2.0.0+13` olarak eşleşiyor.
- TMDb proxy bağımlılık denetiminde açık bulunmadı.

## Bağımlılık notu

Firestore kural test aracının geliştirme bağımlılıklarında, `firebase-tools`
üzerinden gelen 5 orta seviye dolaylı bulgu var. Yüksek veya kritik bulgu yok.
Otomatik düzeltme eski ve kırıcı bir `firebase-tools` sürümüne geçmeyi önerdiği
için uygulanmadı. Bu paket uygulamanın yayınlanan web koduna dahil değildir;
haftalık bağımlılık takibinde izlenecektir.

## Yayın sonrası kalan dış koşul

App Check enforcement, gerçek kullanıcı trafiğinde yedi tam günlük doğrulama
oranı görülmeden açılmayacak. Bu, v2.2 kodunun yayınlanmasını engellemez.

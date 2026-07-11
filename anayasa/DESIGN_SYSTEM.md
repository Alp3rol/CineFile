# Tasarım Sistemi (Design System)

CineFile, sinematik, şık ve modern bir görünüme sahip olmalıdır. Hedefimiz premium bir kullanıcı deneyimi sunmaktır.

## Temel Felsefe
- **Koyu Tema (Dark Mode) Odaklı:** Uygulama tamamen koyu tema üzerine inşa edilmiştir. Renk paleti sinema salonu hissiyatı verir (koyu maviler, siyahlar ve neon vurgular).
- **Cam Efekti (Glassmorphism):** Menülerde, alt çubuklarda (bottom bar) ve dialoglarda yarı saydam arka planlar, blurlar ve ince çerçeveler kullanılır.

## Renkler ve AppTheme
Tasarım token'ları `lib/core/theme/app_theme.dart` içerisinde tutulur.
- **Çerçeveler (Borders):** `AppTheme.borderColor` halihazırda alfa (saydamlık) barındırır (`Color(0x0FFFFFFF)`). Üzerine tekrardan `.withOpacity()` uygulamaktan kaçının.
- **Neon Vurgular:** Önemli butonlar ve etkileşimli alanlarda dikkat çekici vurgu renkleri (accent colors) kullanılır.

## Görsel Yönetimi ve Deterministik Yer Tutucular
- TMDb'den dönen görsel (poster_path veya backdrop_path) null ise veya yüklenemezse düz sıkıcı bir gri renk göstermeyin.
- Bunun yerine `AppNetworkImage` bileşenine `seed` (örn. filmin başlığı) parametresini geçerek, o filme özgü her zaman aynı görünen (deterministik) renkli bir gradyan poster üretilir (`posterPlaceholderGradient`).

## Tipografi ve Yerelleştirme
- Uygulama içi metinlerde `intl` paketindeki locale tabanlı ('tr_TR' vb.) zorunlu formatlardan kaçınılmıştır. Çünkü `initializeDateFormatting()` ile sistem yükünü artırmak yerine basit ve sade tarih formatlamaları (`dd.MM.yyyy`) veya uygulamanın kendi içinde tanımlı basit ay adları listeleri tercih edilir.

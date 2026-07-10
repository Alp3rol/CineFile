# CineFile Proje Kuralları

## Git Deployment Kuralı (KESİNLİKLE UYULACAK)

Bu projede her kod değişikliğinin ardından **iki ayrı işlem** yapılmalıdır. Bunlardan birini unutmak yasaktır.

### 1. Kaynak Kodu → `main` Branch'i
Dart kodu, asset veya konfigürasyon dosyalarında yapılan her değişiklik `main` branch'ine push edilmelidir.

```bash
git add <değişen dosyalar>
git commit -m "açıklayıcı mesaj"
git push
```

### 2. Canlı Site → `gh-pages` Branch'i
Siteyi canlıya almak için projenin kökündeki `yayinla.bat` çalıştırılmalıdır. Bu işlem:
- `flutter build web --release --base-href "/CineFile/"` ile projeyi derler.
- Derlenmiş dosyaları `gh-pages` branch'ine force-push eder.

> **NOT:** `yayinla.bat` yalnızca `gh-pages` branch'ini günceller, `main` branch'ine dokunmaz.
> Bu iki işlem **birbirinin yerini tutmaz**, ikisi de ayrı ayrı yapılmalıdır.

### Özet Tablo

| Ne yapıldı | Nereye gider | Nasıl |
|---|---|---|
| Dart / asset / config değişikliği | `main` branch | `git push` |
| Canlı siteyi güncelleme | `gh-pages` branch | `yayinla.bat` |

---

## Proje Yapısı
- Flutter projesi, `lib/` klasöründe Dart kodu içerir.
- Web deployment için `build/web/` çıktısı kullanılır.
- `api_key.dart` dosyası `.gitignore`'dadır, asla commit edilmez.

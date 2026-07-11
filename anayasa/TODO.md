# Yapılacaklar (TODO)

## Güncel Görev Listesi
CineFile uygulamasının temel (v1) geliştirmeleri tamamlanmıştır. Aşağıdaki liste bakım ve iyileştirme adımlarını içerir:

- [x] Tüm proje belgelerinin CineFile'a uygun olarak "anayasa" klasöründe düzenlenmesi.
- [ ] Gerekirse yeni özellikler için UI analizlerinin (örn. animasyon takılmaları) yapılması.
- [ ] Kullanıcılardan veya testlerden gelecek hataların (Bug Fixes) çözülmesi.
- [ ] Web platformunda (GitHub Pages) performansı artıracak asset optimizasyonları.

## 🚨 Önemli Hatırlatma (Git Workflow)
Herhangi bir görev tamamlandığında:
1. Kaynak kod değişiklikleri için: `git add`, `git commit`, `git push` ile `main` branch'ine gönder.
2. Sitenin güncellenmesi için: Kök dizindeki `yayinla.bat` scriptini çalıştırarak `gh-pages` branch'ine güncel build'i gönder! Bu iki adım birbirinin yerine geçmez.

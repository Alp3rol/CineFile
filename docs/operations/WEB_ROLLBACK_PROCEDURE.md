# Web Yayın Geri Alma (Rollback) ve Artefakt Prosedürü

## 1. Mimarinin Temel İlkeleri

CineFile web sürümü GitHub Pages (`gh-pages` dalı) üzerinde barındırılır ve [`.github/workflows/deploy.yml`](../../.github/workflows/deploy.yml) iş akışı ile yayımlanır.

Geri alma (rollback) mimarisinin 3 temel güvencesi:
1. **Tarihçe Korunumu (`force_orphan: false`):** `peaceiris/actions-gh-pages@v4` aracı `gh-pages` dalını sıfırlamak (`force push`) yerine her yayını bir commit olarak ekler (`deploy: <sha>`). Böylece canlı sitedeki her değişiklik geriye dönük incelenebilir veya geri alınabilir.
2. **Release İzi (Traceability):** Her canlı derleme `pubspec.yaml` sürümü (`cinefile@v1.7.2+12`) ve 12 karakterlik Git commit SHA'sı ile damgalanır.
3. **Manuel Tetikleme Desteği (`workflow_dispatch`):** `deploy.yml` iş akışı `ref` parametresi kabul eder. Herhangi bir bilinen sağlıklı etiket (tag) veya commit istenildiği an yeniden canlıya basılabilir.

---

## 2. Geri Alma (Rollback) Adımları

Canlı web sürümünde kritik bir regresyon veya hata tespit edildiğinde aşağıdaki üç yöntemden biri uygulanır:

### Yöntem A: GitHub Actions Arayüzünden Sağlıklı Sürüme Dönüş (Önerilen - En Hızlı)

1. GitHub Repository -> **Actions** -> **Deploy web** sayfasına gidin.
2. **Run workflow** butonuna tıklayın.
3. **Branch or tag to deploy** alanına son sağlıklı sürüm etiketini veya commit SHA'sını yazın (Örnek: `v1.7.2+12` veya `618874e`).
4. **Run workflow** butonuna basarak dağıtımı başlatın.
5. Dağıtım tamamlandığında sentetik sağlık kontrolü otomatik doğrulanacaktır.

### Yöntem B: `main` Dalı Üzerinden Düzeltme / Revert Etme

1. Hatalı commit tespit edilir ve yerelde geri alınır:
   ```bash
   git revert <hatali_commit_sha>
   git commit -m "revert: hatalı web sürümü geri alındı"
   git push origin main
   ```
2. Yeni bir versiyon etiketi basılarak yayın tetiklenir:
   ```bash
   git tag v1.7.3
   git push origin v1.7.3
   ```

### Yöntem C: Acil Durum `gh-pages` Dalı Üzerinde Manuel Geri Alma

Geliştirici bilgisayarından doğrudan canlı sürümü bir önceki commit'e döndürmek için:
```bash
git fetch origin gh-pages
git checkout gh-pages
git revert HEAD
git push origin gh-pages
```

---

## 3. Sağlıklı Artefakt Yönetimi

- GitHub Actions `deploy.yml` her başarılı derlemede `build/web` çıktılarını derleme geçmişinde artefakt olarak saklar.
- Son çalışan sağlıklı derleme paketi GitHub Actions **Deploy web** iş akışı detaylarında bulunan `test-quality-reports` ve derleme kayıtları altında saklanır.

---

## 4. Geri Alma Sonrası Doğrulama

Rollback işlemi tamamlandıktan hemen sonra aşağıdaki doğrulama adımları çalıştırılır:

1. **Sentetik Sağlık Kontrolü:**
   ```bash
   node tool/synthetic_health_check.mjs
   ```
2. **Canlı Sürüm Metadata Kontrolü:**
   Tarayıcıda [Alp3rol.github.io/CineFile](https://Alp3rol.github.io/CineFile/) adresi açılıp konsolda ve Sentry panelinde beklenen `cinefile@<version>` release etiketinin göründüğü doğrulanır.

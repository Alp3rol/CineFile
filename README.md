# 🎬 CineFile

<p align="center">
  <img src="assets/images/tmdb_logo.png" alt="TMDB Logo" width="120"/>
</p>

**CineFile: Film & Dizi Listem**, sinema ve dizi tutkunları için özel olarak tasarlanmış, koyu tema odaklı ve cam efekti (glassmorphism) detaylarına sahip **premium bir kişisel izleme günlüğü ve analiz uygulamasıdır.** 

Tamamen yerel veritabanında çalışarak verilerinizin gizliliğini korur ve zengin veri görselleştirmeleri ile izleme alışkanlıklarınızı analiz eder.

👉 **[Canlı Web Demosu (Mobil Görünüm)](https://Alp3rol.github.io/CineFile/)**

---

## ✨ Özellikler

*   **🔍 Keşfet ve Engelsiz Arama:** Türkiye'deki internet engellerini (TMDb engelleri) DNS-over-HTTPS (DoH) katmanıyla otomatik aşarak film ve dizileri bulur, detaylarını ve fragmanlarını getirir.
*   **📖 Detaylı İzleme Günlüğü:** Bir yapımı kaç kez, ne zaman, nerede (Sinema, Ev vb.) ve kiminle izlediğinizi kaydedin. Puanlama (1-10), ruh hali emojileri ve kişisel notlar/etiketler ekleyin.
*   **🔄 Dizi Bölüm Takip Sistemi (Aktif İzliyorum):** Dizileri bölüm bölüm kolayca takip edin. Sistem nerede kaldığınızı hatırlar, sıradaki bölümü otomatik önerir ve tamamlandığında durumu günceller.
*   **➕ Hızlı Ekleme:** Ana Sayfa ve Günlük listesindeki hızlı ekleme butonlarıyla, detay sayfasına girmeden tek dokunuşla sıradaki bölümü loglayın.
*   **📺 Otomatik Platform Simgeleri:** Girdiğiniz mekandan (ör. Netflix, Prime Video, Sinema) izleme platformunu otomatik tanır ve satırlara şık simgeler yerleştirir.
*   **📁 Özel Koleksiyonlar ve Maratonlar:** Kendi listelerinizi oluşturun, sürükle-bırak ile sıralayın ve neon ilerleme çubuklarıyla tamamlanma oranlarını takip edin.
*   **📊 Zengin Analizler & İstatistikler (İçgörüler):**
    *   **İzleme Yoğunluğu Haritası:** Yıllık izleme sıklığınızı gün gün gösteren GitHub tarzı bir takvim ısı haritası.
    *   **Puan Dağılım Grafiği:** Verdiğiniz puanların dağılımı ve buna göre esprili bir *Eleştirmen Profili* yorumu.
    *   **İzleme Serileri (Streak):** Üst üste film izlenen gün serileriniz (Mevcut ve en uzun seri).
    *   **İzleyici Alışkanlıkları:** En çok izlenen yönetmenler, oyuncular, türler, mevsimsel eğilimler ve gün içi aktif saatler.
*   **🔒 Yerel Öncelikli Gizlilik:** Tüm verileriniz tamamen cihazınızda (SQLite/Drift) saklanır. İstediğiniz zaman verilerinizi JSON formatında dışa aktarabilir veya yedekten geri yükleyebilirsiniz.

---

## 🛠️ Teknolojik Altyapı

*   **Arayüz & Framework:** Flutter (Mobil, Web, Windows uyumluluğu)
*   **Durum Yönetimi (State Management):** Riverpod
*   **Veritabanı:** Drift (SQLite) — *Web platformu için bellek içi (in-memory) veri simülasyonu.*
*   **Ağ İstemcisi:** Dio (Özel proxy yönlendiricileri ve DoH entegrasyonu ile).
*   **Grafikler:** `fl_chart`

---

## 🚀 Kurulum ve Yerel Çalıştırma

Projeyi bilgisayarınızda yerel olarak çalıştırmak için sisteminizde Flutter SDK'nın kurulu olduğundan emin olun.

1. **Depoyu kopyalayın:**
   ```bash
   git clone https://github.com/Alp3rol/CineFile.git
   cd CineFile
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **TMDb API Anahtarını Yapılandırın (İsteğe Bağlı):**
   Aramaların çalışması için kendi TMDb API anahtarınızı `lib/core/constants/api_key.dart` dosyası altına ekleyin:
   ```dart
   // lib/core/constants/api_key.dart
   const String tmdbApiKey = 'BURAYA_API_ANAHTARINIZI_YAZIN';
   ```

4. **Kod üreticiyi çalıştırın:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Uygulamayı başlatın:**
   ```bash
   flutter run
   ```

---

## 📝 TMDb Atfı

Bu uygulama TMDB API'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.
*(This product uses the TMDB API but is not endorsed or certified by TMDB.)*

<p align="center">
  <a href="https://www.themoviedb.org/">
    <img src="assets/images/tmdb_logo.png" alt="The Movie Database" width="120"/>
  </a>
</p>

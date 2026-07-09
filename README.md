# 🎬 CineFile

<p align="center">
  <img src="assets/images/tmdb_logo.png" alt="TMDB Logo" width="120"/>
</p>

**CineFile** is a premium, privacy-focused personal watch diary and analytics application for movie and TV show enthusiasts. It features a modern, dark-themed glassmorphism UI, a robust offline-first architecture, and interactive data insights.

👉 **[Live Web Demo (Mobile view) / Canlı Web Demosu](https://Alp3rol.github.io/CineFile/)**

---

## 🇹🇷 CineFile Nedir?
**CineFile: Film & Dizi Listem**, izlediğiniz tüm yapımları puanlayıp notlar alarak kişisel bir sinema arşivi oluşturmanızı sağlayan premium bir günlük uygulamasıdır. Tamamen yerel veritabanında çalışarak verilerinizin gizliliğini korur.

## 🇬🇧 What is CineFile?
**CineFile: Movie & TV Tracker** is a personal watch diary that allows you to keep track of your watch history, rate movies and TV shows, organize custom collections, and explore rich charts of your viewing habits.

---

## ✨ Features / Özellikler

*   **🔍 Search & Discover (Keşfet):** Bypasses ISP-level blocks automatically via DNS-over-HTTPS (DoH) connection layer to query TMDb API for movies and TV shows.
*   **📖 Detailed Watch Diary (Günlük):** Add multiple watch records per title. Log date, time, watch place (Cinema, Home, Netflix, etc.), companion, mood, rating (1-10), and personal notes/tags.
*   **🔄 TV Show Episode Tracker (Aktif İzliyorum):** Seamlessly track TV shows episode-by-episode. System remembers where you left off, suggests the next episode, and updates the status automatically.
*   **📊 Rich Insights & Analytics (İçgörüler):**
    *   **Contribution Heatmap:** A GitHub-style calendar grid tracking your watch frequency over the year.
    *   **Rating Distribution & Critic Profile:** Sarcastic and fun analysis of your rating profile.
    *   **Streak Counter:** Current and longest consecutive watch streaks.
    *   **Viewing Habit Charts:** Top directors, actors, genres, seasonal trends, and time-of-day stats.
*   **📁 Custom Collections (Listeler):** Create customized lists, track completion progress with a neon progress bar, and reorder titles using drag-and-drop.
*   **🔒 Local-First Privacy (Gizlilik):** Your data stays entirely on your device (SQLite/Drift). You can manually export/import everything as a JSON backup from settings.

---

## 🛠️ Tech Stack / Teknolojik Altyapı

*   **Framework:** Flutter (Web, Android, iOS, Windows compatibility)
*   **State Management:** Riverpod
*   **Local Database:** Drift (SQLite) with custom schema migrations (v8) & in-memory web simulated fallbacks.
*   **Network Client:** Dio with failover host interceptors & DNS-over-HTTPS (`DohResolver`).
*   **Charts:** `fl_chart`

---

## 🚀 Getting Started / Nasıl Çalıştırılır?

To run this project locally, make sure you have the Flutter SDK installed on your system.

1. **Clone the repository / Depoyu kopyalayın:**
   ```bash
   git clone https://github.com/Alp3rol/CineFile.git
   cd CineFile
   ```

2. **Install dependencies / Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Configure API Key (Optional) / API Anahtarını Yapılandırın:**
   Add your TMDb API key under `lib/core/constants/api_key.dart` to make live searches work locally:
   ```dart
   // lib/core/constants/api_key.dart
   const String tmdbApiKey = 'YOUR_TMDB_API_KEY';
   ```

4. **Run code generator / Kod üreticiyi çalıştırın:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app / Uygulamayı başlatın:**
   ```bash
   flutter run
   ```

---

## 📝 TMDB Attribution

This product uses the TMDB API but is not endorsed or certified by TMDB.
*Bu ürün TMDB API'sini kullanır ancak TMDB tarafından desteklenmez veya onaylanmaz.*

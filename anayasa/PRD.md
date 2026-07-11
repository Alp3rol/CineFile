# Ürün Gereksinimleri Belgesi (PRD)

**Proje Adı:** CineFile: Film & Dizi Listem

## 1. Temel Değer Önerisi
Sinema ve dizi tutkunlarına, izledikleri yapımları takip edebilecekleri, puanlayabilecekleri ve kişisel notlar ekleyebilecekleri, gizlilik odaklı (yerel veritabanı) ve premium bir izleme günlüğü sunmak.

## 2. Hedef Kitle
- Düzenli olarak film ve dizi izleyen, hangi bölümü veya filmi izlediğini unutmamak için not tutma ihtiyacı hisseden kullanıcılar.
- İzleme alışkanlıklarının istatistiklerini (heatmap, favori yönetmen, en çok izlenen türler) görmek isteyen sinemaseverler.

## 3. Temel Gereksinimler
- **Çevrimdışı Öncelikli (Offline-First):** Tüm izleme geçmişi cihazda SQLite ile saklanacak.
- **Kesintisiz Arama (TMDb Ent.):** Kullanıcılar TMDb üzerinden film ve dizi arayabilecek, DNS engellerini aşmak için DoH (DNS-over-HTTPS) veya proxy yöntemleri kullanılacak.
- **Dizi Takibi:** Kullanıcıların dizilerde nerede kaldıklarını ("Aktif İzliyorum") hatırlaması ve tek tıkla yeni bölüm eklemesi sağlanacak.
- **İstatistik ve Görselleştirme:** GitHub ısı haritası benzeri izleme sıklığı grafikleri, puan dağılımı analizleri sunulacak.

## 4. Kullanılabilirlik
- Hem mobil cihazlarda hem de Web (PWA/SPA) ortamında responsive çalışacak.
- Animasyonlar pürüzsüz (60fps/120fps) ve premium (cam efekti, neon vurgular) olacak.

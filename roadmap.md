# FilmDizi Günlüğü - Yol Haritası ve MVP Tanımı (Roadmap & MVP)

Bu doküman, projenin adım adım geliştirilmesini sağlayacak modüler ve sürüm tabanlı (version-by-version) yol haritasını tanımlar. Büyük bir kodu tek seferde yazmak yerine, her aşamada çalışan ve test edilebilir bir uygulama elde etmeyi amaçlar.

---

## 📌 MVP (Minimum Viable Product) Kapsamı: Sürüm 1.0.0
MVP'nin amacı, bir film/dizi günlüğünün temel işlevini (Arama, Detay Çekme, Çoklu İzleme Kaydı Tutma ve Yerel Yedekleme) en yüksek tasarım kalitesiyle sunmaktır.

```mermaid
graph TD
    v01[v0.1: Proje & Veritabanı] --> v02[v0.2: Tasarım & Temel UI]
    v02 --> v03[v0.3: TMDb & Arama]
    v03 --> v04[v0.4: Detay & Çoklu İzleme]
    v04 --> v05[v0.5: Listeler, Takvim & Backup]
    v05 --> MVP((v1.0.0: MVP Lansmanı))
```

---

## 🛠️ Versiyon Detayları ve Geliştirme Adımları

### **Aşama 1: Temel MVP Geliştirme (v0.1 - v1.0.0)**

#### **✅ v0.1: Altyapı ve Veritabanı Mimarisi**
*   **Hedef**: Çalışan boş bir Flutter projesi ve ilişkisel veritabanı şeması.
*   **İşler**:
    *   Flutter projesinin oluşturulması.
    *   Klasör yapısının kurulması (Feature-First: `features/home`, `features/search`, `features/journal`, `features/settings` vb.).
    *   **Drift (SQLite)** veritabanının entegre edilmesi.
    *   *Veritabanı Tabloları*:
        *   `movies` (TMDb ID, Başlık, Poster, Yönetmen, Oyuncular, Türler, Süre, Konu, Yıl).
        *   `watch_records` (İzleme ID, Movie ID, Tarih, Saat, Mekan, Eşlik Edenler, Ruh Hali, Puan, Not, İzleme Numarası).
        *   `user_movie_settings` (Movie ID, Favori mi, Yeniden İzlenecek mi, Kişisel Not).
    *   Riverpod paketinin ve temel State notifiers'ın kurulması.

#### **✅ v0.2: Tasarım Sistemi ve Arayüz İskeleti (Shell UI)**
*   **Hedef**: Koyu tema odaklı, premium ve akıcı arayüzün temel taşlarının atılması.
*   **İşler**:
    *   `index.css` tarzı renk paleti, tipografi ve ortak bileşen stil tanımlamaları (`ThemeData` konfigürasyonu).
    *   Glassmorphism efektleri için genel widget'ların (`BackdropFilter` tabanlı) oluşturulması.
    *   Ana navigasyon yapısının kurulması (Bottom Navigation Bar).
    *   Ana Sayfa (Home) taslağının oluşturulması (Üst bilgi kartları, son izlenenler için yer tutucu yatay listeler).

#### **✅ v0.3: TMDb API Entegrasyonu ve Arama Motoru**
*   **Hedef**: Harici bir kaynaktan veri çekebilmek ve kullanıcının film aramasını sağlamak.
*   **İşler**:
    *   TMDb API entegrasyonu için istemci yazılması (Dio paketi ile).
    *   Arama ekranının tasarlanması (Filtreler: Tür, Yıl, Puan).
    *   Arama sonuçlarının premium kart tasarımlarıyla (Letterboxd stili poster grid) listelenmesi.

#### **✅ v0.4: Detay Sayfası ve Çoklu İzleme Kayıt Sistemi**
*   **Hedef**: Uygulamanın kalbini oluşturan, aynı filmi birden fazla kez izleme kaydıyla ekleyebilme özelliği.
*   **İşler**:
    *   Premium Film Detay Sayfası (IMDb ve Letterboxd melezi: Arka plan görseli, oyuncu listesi, yönetmen vb.).
    *   "İzleme Kaydı Ekle" modalı (Tarih seçici, Saat seçici, Mekan/İnsan girdisi, Ruh hali emojileri, 1-10 puan slider'ı, kişisel not alanı).
    *   Detay sayfasında geçmiş izleme kayıtlarının zaman tüneli (Timeline) olarak listelenmesi (Örn: "3. İzleme - 12.03.2026 - Sinemada").

#### **✅ v0.5: Listeler, Takvim ve Manuel Yedekleme (MVP Lansmanı)**
*   **Hedef**: MVP'yi tamamlayacak listeleme, takvim takibi ve veri güvenliğini sağlama.
*   **İşler**:
    *   Listeler Sekmesi (Görünüm Seçenekleri: Poster Grid & Detaylı Günlük Liste Görünümü arasında geçiş; İzlediklerim, İzleyeceklerim, Favoriler, Yeniden İzlenecekler filtreleri).
    *   Takvim Sekmesi (Aylık takvim üzerinde gün gün izlenen film ikonları).
    *   Ayarlar Sekmesi: JSON/CSV formatında tüm verileri dışa aktarma (export) ve geri yükleme (import).
    *   **v1.0.0 MVP Yayını.**

#### **✅ v0.6: Günlük Liste Görünümü Revizyonu ve Sıralama**
*   **Hedef**: Liste günlük görünümünü tablo yapısına kavuşturup sıralama, arama ve hızlı önizleme yetenekleriyle zenginleştirmek.
*   **İşler**:
    *   Film Adı, İzleme Tarihi, İzleme Sırası ve Puanım sütun başlıklarının (Table Header) eklenmesi.
    *   Sütunlara tıklayarak artan/azalan (▲ / ▼) dinamik sıralama yapısı.
    *   Günlük içi yerel arama çubuğu ve hızlı filtre çiplerinin entegrasyonu.
    *   Satıra uzun basarak (Long Press) kişisel notları ve izleme detaylarını gösteren hızlı önizleme penceresi.
    *   Kullanıcı tercihiyle "Kayıt Bazlı" tasarımın seçilmesi ve kod temizliği.

#### **✅ v0.6.1: Dinamik Mini İstatistik Barı (Mini Insights Bar)**
*   **Hedef**: Günlük içindeki filmlerin özet verilerini arama barının altında şık kartlarla göstermek.
*   **İşler**:
    *   Mevcut aydaki izleme adedi, ortalama puan, en popüler tür ve toplam sürenin hesaplanması.
    *   Yatay kaydırılabilir cam efektli istatistik kartlarının çizilmesi.

#### **✅ v0.6.2: "Yeniden İzleme (Re-Watch)" Görsel Rozeti**
*   **Hedef**: Birden fazla kez izlenen filmlere listede görsel vurgu katmak.
*   **İşler**:
    *   İzleme sırası > 1 olan kayıtlara satır üzerinde yeşil 🔄 rozetinin yerleştirilmesi.

#### **✅ v0.6.3: İzlenen Platform Simgeleri (Netflix, Prime, Sinema)**
*   **Hedef**: Mekan isminden otomatik platform tanıyıp simgeleştirmek.
*   **İşler**:
    *   Netflix, Prime, Sinema, Ev vb. kelime eşleştirmeleriyle renkli logo ve ikonların satırlara eklenmesi.

#### **✅ v0.6.4: Toplam Sinema Mesaisi Sayacı (Time Counter)**
*   **Hedef**: Günlük alt sınırında toplam izleme süresini toplu bir şeritte göstermek.
*   **İşler**:
    *   Listenin altına toplam süreyi saat ve dakika olarak özetleyen dinamik şerit eklenmesi.

#### **✅ v0.6.5: Sürükle-Bırak Kişisel Sıralama (Favorite Movie Ranking)**
*   **Hedef**: Listeyi sürükleyip bırakarak favori film sıralamasını (top list) anlık ve akıllı olarak yönetebilmek.
*   **İşler**:
    *   `ReorderableDragStartListener` ve `ReorderableListView` entegrasyonu.
    *   Sıra sütunu ekleme ve sıralı filmlerin yeşil `#1`, `#2` etiketleriyle parlatılması.
    *   Tutup yukarı çekildiğinde sıraya ekleyen, aşağı sırasız alana çekildiğinde sıralamadan çıkaran akıllı `onReorder` algoritması.
    *   Film Detay sayfası ve Hızlı Önizleme kutusuna el ile sıralama numarası girme/sıfırlama alanları.

#### **✅ v0.7.0: Özel Film Listeleri ve İlerleme Takibi (Custom Collections & Progress)**
*   **Hedef**: Kullanıcının kendi belirlediği isim/açıklama ile özel film listeleri oluşturabilmesi, yönetebilmesi ve sürükle-bırak yöntemiyle sıralayabilmesi.
*   **İşler**:
    *   `custom_lists` ve `custom_list_movies` Drift veritabanı tablolarının şemaya eklenmesi (şema sürümü v3).
    *   Alt navigasyon barına 6. sekme veya listeleme ekranının içine şık bir geçiş paneli entegrasyonu.
    *   Özel liste oluşturma, silme ve düzenleme arayüzleri.
    *   Film detay sayfasından veya listelerden pop-up (bottom sheet) ile filmi bir veya birden fazla özel listeye ekleme imkanı.
    *   Özel listelerin içinde neon renkli İlerleme Çubuğu (Progress Bar) ile izleme tamamlama oranlarının takibi.
    *   Özel liste içinde filmleri sürükleyip bırakarak el ile sıralama yeteneği.

#### **✅ v0.7.1: İnce Ayarlar - Anlık Kaydetme ve Çift İzleme Filtreleme**
*   **Hedef**: Mobil arayüzde sıralamayı anında kaydetmek ve mükerrer izleme kayıtlarının favori sıralamasını bozmasını önlemek.
*   **İşler**:
    *   Klavye tuşuna basmayı beklemeden anlık sıralama kaydı.
    *   Bir filmin sadece en son izleme kaydına sıralama etiketi verme.

#### **✅ v0.7.2: Güvenlik ve API Anahtarı Koruma Önlemleri**
*   **Hedef**: TMDb API anahtarının kod içerisinde açıkta durarak çalınmasını önlemek.
*   **İşler**:
    *   Hassas API anahtarının kodlardan arındırılması.
    *   Anahtar girişinin güvenli yerel depolamaya (Secure Storage) yönlendirilmesi.

#### **✅ v0.7.3: Dizi (TV Show) Arama ve Detay Desteği**
*   **Hedef**: Uygulamanın sadece filmlerle sınırlı kalmayıp dizileri de desteklemesi.
*   **İşler**:
    *   TMDb `/search/multi` endpoint entegrasyonu.
    *   Dizi verilerinin film veri modellerine normalizasyonu.

#### **✅ v0.7.4: Otomatik ve Güvenli API Anahtarı Yönetimi**
*   **Hedef**: Güvenliği bozmadan kullanıcının elle anahtar girme gereksinimini kaldırmak.
*   **İşler**:
    *   `api_key.dart` üzerinden yerel güvenli anahtar tanımlama.
    *   `.gitignore` dosyası ile bu yerel dosyanın sürüm kontrolüne girmesini engelleme.

#### **✅ v0.7.5: Eski Mock Poster Yollarının Güncellenmesi ve Çökme Çözümü**
*   **Hedef**: Kaldırılan TMDb poster yollarını yenilemek ve yüklenmeyen resimlerin düzeni çökertmesini önlemek.
*   **İşler**:
    *   Mock verideki poster yollarını güncel yollarla değiştirmek.
    *   `AppNetworkImage` ile resim yüklenirken boyut çökmesini engellemek.

#### **✅ v0.7.6: Film ve Dizi ID Çakışma Önleyici (Namespace Separation)**
*   **Hedef**: TMDb üzerindeki film ve dizi ID çakışmalarının yanlış sayfaları açmasını çözmek.
*   **İşler**:
    *   Drift veritabanına `isTv` alanını eklemek (Drift şema sürüm 4).
    *   Detay sayfasında dizi/film tipine göre doğrudan doğru endpoint'i sorgulatmak.

---

### **Aşama 2: Gelişmiş Özellikler ve İstatistikler (v0.8.0 - v0.9.0)**

#### **✅ v0.8.0: Detaylı Analiz & İstatistik Ekranı**
*   **Hedef**: Kullanıcının izleme alışkanlıklarını grafiklerle görselleştirmesi.
*   **İşler**:
    *   `fl_chart` paketi ile modern, etkileşimli aylık ve yıllık grafikler.
    *   En çok izlenen yönetmen, oyuncu ve türlerin listelenmesi.
    *   En aktif gün, en aktif ay verileri.
    *   Rozet Sistemi (İlk film, 10 film, 50 film rozetleri vb.).

#### **✅ v0.8.1: İzleme Yoğunluğu Haritası (Contribution Heatmap)**
*   **Hedef**: Son 365 günün günlük izleme sıklığını GitHub tarzı etkileşimli yoğunluk ızgarasıyla göstermek.
*   **İşler**:
    *   Yatay kaydırılabilir 53 sütunluk haftalık izleme ızgarası tasarımı.
    *   Tıklanan hücreye ait tarihi ve izlenen film/dizi sayısını gösteren akıllı cam efektli banner.
    *   Cinematic Red tonlarında yoğunluk legend'ı.

#### **✅ v0.8.2: İzleme Serisi (Streak) & Harita Filtreleme**
*   **Hedef**: Harita verilerini anlık filtrelemek ve izleme serilerini (streak) hesaplamak.
*   **İşler**:
    *   Mevcut ve en uzun izleme serilerinin (streak) Drift verilerinden hesaplanması.
    *   Heatmap üzerinde "Tümü", "Filmler" ve "Diziler" anlık filtre butonları.

#### **✅ v0.8.3: Puan Dağılım Grafiği & Eleştirmen Profili**
*   **Hedef**: 1-10 puan dağılım sıklığını göstermek ve izleyici tipini analiz etmek.
*   **İşler**:
    *   1-10 arası puanların dağılımını gösteren dikey sütun grafiği (`fl_chart` BarChart).
    *   Ortalamaya göre esprili Eleştirmen Profili değerlendirmesi.

#### **✅ v0.8.4: Zaman Kıyaslama & Mevsimsel Analiz**
*   **Hedef**: İzleme sürelerini eğlenceli şekilde görselleştirmek ve mevsimsel dağılımı ölçmek.
*   **İşler**:
    *   LotR maratonu ve uçuş süreleriyle eğlenceli zaman kıyaslama kartı.
    *   Mevsimsel izleme yüzdeleri (Kış, Yaz...) ve en aktif izleme günü (Altın Gün) gösterimi.

#### **✅ v0.9.0: Hatırlatıcılar, Maratonlar ve Etiket Yönetimi**
*   **Hedef**: Haftalık hedefler, geri sayımlı maratonlar ve özel hashtag etiketleriyle etkileşimi artırmak.
*   **İşler**:
    *   Watch records şemasına hashtag (`tags`) desteği eklenmesi ve günlüğe hashtag rendering ve filtreleme.
    *   Özel listelerin belirli hedef tarihi olan maratonlara dönüştürülebilmesi, kalan gün geri sayımı.
    *   Haftalık izleme hedefi belirleme, bu haftaki ilerleme halkası ve ayarlar dialoğu.

#### **✅ v0.9.1: Ağ Kararlılığı & Hotfix Güncellemesi (Network Resilience & Hotfixes)**
*   **Hedef**: Türkiye'deki internet servis sağlayıcılarının TMDb engellerini tamamen aşmak ve arama deneyimini akıcılaştırmak.
*   **İşler**:
    *   **Engelsiz Görsel Yükleme**: TMDb görsel sunucusunun (`image.tmdb.org`) engellerini aşmak için tüm görselleri yüksek hızlı `images.weserv.nl` Cloudflare proxy'sine yönlendirme.
    *   **Reklam Engelleyici Dostu Proxy**: Arama ve detay verilerini çekmek için reklam engelleyicilere ve sansüre takılmayan yüksek hızlı `corsproxy.io` entegrasyonu.
    *   **Zaman Aşımı & Doğrudan Yönlendirme**: İlk başarısız istekten sonra engeli hafızaya kaydedip sonraki tüm istekleri zaman aşımı bekletmeden doğrudan proxy'ye yönlendirme.
    *   **Arama Akıcılığı (Debouncing & Race Condition Guard)**: Yazarken her harfte istek atılmasını engelleyen 350ms geciktirme (debounce) ve eski isteklerin yeni sonuçları ezmesini engelleyen yarış durumu koruması.
    *   **Kullanıcı Dostu Ayarlar**: Teknik ayar ihtiyacını ortadan kaldırarak TMDb API ayar bölümünün ayarlardan kaldırılması, her şeyin arka planda tamamen otomatik yönetilmesi.

#### **✅ v0.9.2: DNS Engellerine Karşı Otomatik Bypass (DNS-over-HTTPS)**
*   **Hedef**: Bazı router/ISS'lerin DNS seviyesinde `api.themoviedb.org`/`api.tmdb.org`'u sessizce `127.0.0.1`'e yönlendirerek arama motorunu tamamen işlevsiz bırakmasını, kullanıcıdan hiçbir ayar istemeden otomatik olarak aşmak.
*   **İşler**:
    *   `DioClient`'a (native platformlarda) yeni bir bağlantı katmanı eklendi: normal DNS çözümlemesi bir loopback adresine (`127.0.0.1`) düşerse, istek otomatik olarak Cloudflare/Google DNS-over-HTTPS ile çözümlenen gerçek IP üzerinden (TLS SNI/Host değişmeden) yeniden deneniyor.
    *   Yeni `DohResolver` sınıfı (10 dakikalık önbellekli çözümleme, birden fazla DoH sağlayıcı fallback'i).
    *   API anahtarı hiçbir 3. parti servise gönderilmiyor (sadece hostname çözümleniyor, proxy kuralına aykırı değil).

#### **✅ v0.9.3: Ana Sayfa'nın Gerçek Veriyle Yeniden İnşası**
*   **Hedef**: Ana Sayfa'daki sabit/uydurma istatistikleri gerçek izleme verisine bağlamak ve ekranı sadece bir "son aktivite listesi" olmaktan çıkarıp aksiyon alınabilir hale getirmek.
*   **İşler**:
    *   İstatistik kartındaki "Toplam İzleme", "Ortalama Puan" ve "Haftalık Hedef" ilerlemesi artık `insightsProvider`/`weeklyGoalProvider`'dan geliyor (önceden sabit "42", "8.7" gibi uydurma değerlerdi).
    *   "Tümünü Gör" butonları artık gerçekten Günlük sekmesine geçiyor (yeni `mainShellTabIndexProvider` ile context'siz sekme değişimi).
    *   Mevcut izleme serisi (streak) rozeti eklendi.
    *   Yeni "Bu Hafta Ne İzlesem?" öneri kartı: kütüphanede olup hiç izlenmemiş filmlerden (favoriler öncelikli) gün bazlı deterministik bir öneri sunuyor, "Başka Öner" ile yenilenebiliyor (yeni `unwatchedMoviesProvider`).
    *   Tür dağılımı için mevcut Insights ekranındaki `GenreChartCard` widget'ı doğrudan yeniden kullanıldı (kod tekrarı yok).

#### **✅ v0.9.4: İzleme Yoğunluğu Haritası - Yıl Gezinme ve Tam Ekran Uyumu**
*   **Hedef**: Isı haritasının sadece kayan son 365 günü göstermesini ve telefon ekranlarına sığmamasını (yatay kaydırma gerektirmesini) çözmek.
*   **İşler**:
    *   Harita artık kayan pencere yerine seçili takvim yılına (1 Ocak - 31 Aralık) göre çalışıyor; başlığa `‹ Yıl ›` gezinme kontrolü eklendi, en eski veri yılından öteye ve gelecek yıllara gidilemiyor.
    *   Açılışta/yıl değiştirildiğinde otomatik olarak ilgili uca (içinde bulunulan yılda bugüne, geçmiş yıllarda Ocak'a) odaklanma.
    *   Yatay kaydırma tamamen kaldırıldı; hücre boyutu `LayoutBuilder` ile ekran genişliğine göre dinamik hesaplanıyor, tüm yıl her cihazda tek bakışta sığıyor.
    *   Üstteki toplam sayaç artık yanıltıcı tüm-zamanlı toplam yerine sadece o an görüntülenen yılın gerçek toplamını gösteriyor.

#### **✅ v0.9.5: İzleme Tarihi Doğrulaması**
*   **Hedef**: Bir filmin/dizinin çıkış tarihinden önceki bir tarihte "izlendi" olarak kaydedilebilmesini engellemek (ör. 2021'de çıkan bir yapımı 2006'da izledim denilememeli).
*   **İşler**:
    *   "İzleme Kaydı Ekle" tarih seçicisinin (`add_watch_record_sheet.dart`) `firstDate`'i artık sabit `2000` değil, `movieData['release_date']`'ten hesaplanıyor.
    *   Çıkış tarihi bilinmiyorsa veya gelecekteyse (henüz vizyona girmemiş yapım) geniş bir aralığa/bugüne düşülerek çökme engelleniyor.

#### **✅ v0.9.6: Bölüm Bazlı Süre Takibi (TV Dizileri)**
*   **Hedef**: TMDb'nin dizi başına döndürdüğü tek, sabit `episode_run_time` değerinin (ör. "Son Yaz" için 120 dk) her izleme kaydına aynen uygulanması yerine, gerçekte kaç bölüm izlendiğine göre ölçeklenebilmesini sağlamak.
*   **İşler**:
    *   `WatchRecords` tablosuna `episodeCount` (varsayılan 1) eklendi; "İzleme Kaydı Ekle" formuna (sadece diziler için) bir bölüm sayacı eklendi.
    *   Günlük/İçgörüler'deki "Toplam Süre" hesaplamaları artık `runtime × episodeCount` kullanıyor.
    *   **Bulunan ve düzeltilen gerçek hata**: Sayaç başta üst sınırsızdı (26 bölümlük bir dizide 26'nın ötesine çıkabiliyordu) **ve** "aktif izlemiyorsan" varsayılanı yanlışlıkla dizinin **tüm bölüm sayısına** eşitlenmişti — bu, aynı diziyi aktif modu kullanmadan birkaç kez loglayan bir kullanıcının Günlük'ünde "Toplam Süre"nin binlerce saate şişmesine yol açtı (gerçek kullanımda gözlemlendi: 1067 saat). Düzeltme: sayaç artık dizinin gerçek bölüm sayısıyla sınırlı **ve** varsayılanı her zaman **1 bölüm** (kullanıcı isterse elle yükseltebilir).

#### **✅ v0.9.7: "Aktif İzliyorum" — Dizi Bölüm Takip Sistemi**
*   **Hedef**: Bir diziyi bölüm bölüm takip ederken, her yeni bölümü loglarken "kaçıncı bölüm" bilgisini elle hesaplamak zorunda kalmadan, sistemin nerede kaldığını hatırlaması.
*   **İşler**:
    *   `Movies.totalEpisodes` (TMDb'den, önbelleklenmiş) ve `UserMovieSettings.isActivelyWatching` / `lastWatchedEpisode` alanları eklendi.
    *   "İzleme Kaydı Ekle" formuna diziye bağlı kalıcı bir "Aktif İzliyorum" anahtarı eklendi: açıkken sistem sıradaki bölümü otomatik önerip onaylatıyor; son bölüme ulaşınca anahtar otomatik kapanıp dizi "Tamamlandı" sayılıyor.
    *   Film Detay ekranına salt-okunur "İzleniyor (X/Y)" / "Tamamlandı" durum göstergesi eklendi.
    *   Günlük listesinde (tablo ve kart görünümü) tamamlanan diziler için yeşil ✓ rozeti eklendi.
    *   Yedekleme (export/import) yeni alanları destekliyor, eski yedeklerle geriye dönük uyumlu.

#### **✅ v0.9.8: Ana Sayfa ve Günlük'te Hızlı Bölüm Ekleme**
*   **Hedef**: Aktif izlenen bir dizinin sıradaki bölümünü loglamak için her seferinde tam "İzleme Kaydı Ekle" formunu (tarih/saat/ruh hali/mekan/not/etiket) açmak zorunda kalmamak.
*   **İşler**:
    *   Yeni `activelyWatchingProvider` ve paylaşılan `logNextEpisode` fonksiyonu (Ana Sayfa ve Günlük'ün aynı mantığı kullanması, birbirinden sapmaması için).
    *   **Ana Sayfa**: "Aktif İzlediklerin" yatay poster kartı listesi — poster üzerindeki "+" rozetine dokununca sadece puan soran minik bir diyalogla bölüm ekleniyor.
    *   **Günlük**: Kullanıcı geri bildirimiyle tasarım değişti — büyük kart listesi yerine, tablo/kart görünümünde diziye ait **en son kayda**, "Puanım" sütununun altında kompakt bir **"4/26 ➕"** etiketi eklendi. Dokununca **hiçbir ekran/diyalog açmadan**, son verilen puan otomatik kullanılarak bölüm anında kaydediliyor.
    *   **Bulunan ve düzeltilen görsel hata**: Bu etiket önce tablo görünümünde puanla aynı satıra (Row+Spacer) sıkıştırılmıştı; dar sütunda üst üste binip taşıyordu. Puan ve etiket artık alt alta (Column) diziliyor.

#### **✅ v0.9.9: Film/Dizi ID Çakışması — Kök Neden Düzeltmesi (Composite Key)**
*   **Hedef**: v0.7.6'da `isTv` alanı şemaya eklenmişti ama **primary key'in parçası yapılmamıştı** — bu yüzden aynı sayısal TMDb ID'sini paylaşan bir film ile bir dizi (TMDb'de film/dizi ID namespace'leri ayrı sayaçlardan geldiği için bu mümkün) hâlâ aynı veritabanı satırında çakışabiliyordu. Gerçek kullanıcı hatası: bir dizi ("Son Yaz") için günlüğe eklenen kayıt, daha sonra aynı ID'yi paylaşan bir filmin ("Whale Music") eklenmesiyle üzerine yazılıyor, kart hâlâ eski ismi gösterse de tıklanınca yanlış yapımı açıyordu.
*   **İşler**:
    *   **Şema (v8 migration)**: `Movies.primaryKey` → `{tmdbId, isTv}`; `UserMovieSettings.primaryKey` → `{tmdbId, isTv}`; `CustomListMovies.primaryKey` → `{listId, movieId, isTv}`; `WatchRecords`e yeni `isTv` sütunu. SQLite'ta PK/FK constraint'leri yerinde değiştirilemediği için migration, veri kaybı olmadan (tablo yeniden adlandır → yeni şemayla oluştur → veriyi kopyala → eskisini sil) 4 tabloyu da yeniden inşa ediyor.
    *   Tüm okuma/yazma katmanı (`database_provider.dart`, `movie_repository.dart`, `episode_logging.dart`, arama/favori/sıralama/özel liste akışları — toplam ~20 dosya) `tmdbId` yerine `(tmdbId, isTv)` composite anahtarına geçirildi (yeni `MovieKey` typedef'i).
    *   **Bağımsız gerçek bir hata da düzeltildi**: Takvim ekranından bir izleme kaydına tıklandığında `MovieDetailScreen`'e `isTv` parametresi hiç geçilmiyordu (her zaman varsayılan `false`), bu da takvimden açılan dizilerin her zaman film olarak sorgulanmasına yol açıyordu.
    *   Aynı kök nedenden kaynaklanan kozmetik/nadir edge-case'ler de düzeltildi: aynı ID'li film+dizi aynı ekranda göründüğünde Hero animasyon tag çakışması, `ReorderableListView`'de duplicate `ValueKey` riski, çevrimdışı arama sonuçları birleştirmesinde üzerine yazma, İçgörüler'deki "tekil yapım" sayımında çift sayım, yedekleme (backup) dışa aktarımında eksik `isTv` alanı.
    *   Mevcut testler (`movie_repository_test.dart`, `home_screen_render_test.dart`, `journal_screen_render_test.dart`, `movie_detail_screen_render_test.dart`, `insights_provider_test.dart`, `insights_screen_render_test.dart`, `contribution_heatmap_render_test.dart`, `actively_watching_quick_add_test.dart`, `journal_quick_advance_tag_test.dart`) yeni composite anahtar imzalarına göre güncellendi; `dart analyze lib` temiz, `flutter test` 20/20 geçiyor; web'de Ana Sayfa/Keşfet/Günlük ekranları elle doğrulandı.
    *   **Ayrı, bu kapsamın dışında bırakılan bulgu**: Yedekleme (export/import), `CustomLists`/`CustomListMovies` tablolarını (özel koleksiyonlar) hiç yedeklemiyor — takip görevi olarak işaretlendi, henüz uygulanmadı.

---

### **Aşama 3: MVP Tamamlanması (v1.0.0)**

#### **✅ v1.0.0: MVP Lansmanı ve Kararlı Sürüm**
*   **Hedef**: Uygulamanın tüm temel işlevlerinin (Arama, Detay Çekme, Çoklu İzleme Kaydı, Detaylı İstatistikler/Heatmap, Dizi Takip Sistemi) kararlı bir şekilde yayına hazır hale getirilmesi.
*   **Not**: Kullanıcı kararıyla yapay zeka entegrasyonu (Gemini AI), otomatik bulut yedekleme ve ek yedekleme özellikleri kapsam dışı bırakılmıştır. v0.9.9 itibarıyla tüm hedeflenen özellikler tamamlanmıştır.

---

## 📈 Proje Durumu

Uygulama planlanan tüm MVP aşamalarını başarıyla tamamlamıştır ve yayına hazırdır.


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

### **Aşama 4: Post-Launch İyileştirmeler (v1.0.x)**

#### **✅ v1.0.1: Dinamik Arka Plan Sistemi (Sinemasal Renk Efekti)**
*   **Hedef**: Her sayfada ekranda görünen film posterlerinin baskın renklerine göre arka planın canlı ve pürüzsüz şekilde değişmesi.
*   **İşler**:
    *   `DynamicBackgroundProvider` (Riverpod `StateNotifier`) ile merkezi renk yönetim sistemi kuruldu.
    *   `DynamicBackgroundWrapper` widgetı oluşturuldu: `BackdropFilter` yerine donanım hızlandırmalı 4 katmanlı `RadialGradient` animasyonu (web uyumlu, dikey çizgi artefaktsız).
    *   `AppNetworkImage` bileşenine `VisibilityDetector` entegrasyonu ile ekrana giren posterlerin renkleri asenkron olarak çıkarılıp kayıt edildi.
    *   Web'de `palette_generator` CORS kısıtlamasına karşı `?cors=1` proxy parametresi eklendi.
    *   Sekme değişimlerinde eski renklerin sızmasını önlemek için `deactivate()` yaşam döngüsü hook'u eklendi.

#### **✅ v1.0.2: Web Uyumluluğu ve Yerleşim Kararlılığı Düzeltmeleri**
*   **Hedef**: Web tarayıcısında görüntülenen iframe simülatöründe oluşan dikey çizgi bozulmalarını, sayfa kayma ve zıplama sorunlarını gidermek.
*   **İşler**:
    *   `DynamicBackgroundWrapper` içindeki iç içe `Scaffold` yapısı kaldırıldı; sadece `Stack` döndürülerek Flutter'ın tek kök Scaffold kuralına uyuldu — tüm sayfa kayma ve zıplama sorunları çözüldü.
    *   Keşfet sayfasının boş durumundaki `Column` yapısı `SizedBox(width: double.infinity)` ile sarmalanarak içeriğin tam ortada hizalanması sağlandı.
    *   `VisibilityDetector`'ın `updateInterval = Duration.zero` ayarı sadece widget test ortamında uygulanacak şekilde kısıtlandı; debug/release modda render döngüsüne müdahale etmesi engellendi.

#### **✅ v1.0.3: Dinamik Arka Plan Sisteminin Yeniden Tasarımı (Sayfa Tabanlı Mimari)**
*   **Hedef**: Kaydırma sırasındaki kasılma/zıplama sorununu köklü olarak çözmek; web'de CORS nedeniyle `palette_generator`'ın renk çıkaramadığı durumlarda arka planın çalışmaya devam etmesini sağlamak; renk kaynağını her sayfanın veri modeliyle doğrudan ilişkilendirmek.
*   **İşler**:
    *   **`VisibilityDetector` tamamen kaldırıldı.** `AppNetworkImage` artık arka plan sistemiyle hiçbir şekilde iletişim kurmuyor; hafif, bağımsız bir resim gösterme bileşenine dönüştürüldü. Bu değişiklik kaydırma sırasındaki kasılma ve zıplama sorununu kalıcı olarak çözdü.
    *   **Sayfa tabanlı renk koordinasyonu**: Tüm arka plan güncellemeleri artık `WidgetsBinding.instance.addPostFrameCallback()` aracılığıyla render döngüsünden bağımsız olarak tetikleniyor.
    *   **Ana Sayfa**: `allWatchRecordsProvider` izlenerek son izlenen **3 filmin** posterleri renk kaynağı olarak kullanılıyor.
    *   **Keşfet Sayfası**: Arama sonuçlarının **ilk filmi** renk kaynağı olarak kullanılıyor; sorgu boşsa veya sonuç yoksa arka plan temizleniyor.
    *   **Film Detay**: Sayfaya girildiğinde ilgili filmin poster rengi uygulanıyor; sayfa kapatıldığında (`dispose`) önceki sayfanın renkleri otomatik olarak geri yükleniyor.
    *   **Günlük / Takvim / Ayarlar**: Bu sekmelere geçildiğinde arka plan renkleri temizlenerek varsayılan koyu temaya dönülüyor (`clearColors()`).
    *   **HSL Fallback**: Web'de CORS nedeniyle `palette_generator` görsel renk çıkartamazsa, filmin başlığından deterministik bir HSL rengi üretiliyor — arka plan sistemi her koşulda çalışıyor.
    *   `DynamicBackgroundNotifier`'a `updateMoviesFromList`, `updateMoviesFromMapList` ve `clearColors` metodları eklendi.
    *   Renk çıkarma hatalarında HSL fallback rengi hem state'e hem cache'e yazılıyor; hatalı `ApiConstants.imageHost` referansı `ApiConstants.imagePathW500` ile düzeltildi.
    *   20 otomatik test başarıyla geçiyor; `MovieDetailScreen` `ConsumerStatefulWidget`'a dönüştürüldü ve `dispose()` içindeki `ref.read()` çağrıları `try/catch` ile korundu.

#### **✅ v1.0.4: Günlük Kayıtları Düzenleme ve Akıllı Bölüm Sayısı Doldurma**
*   **Hedef**: Günlük kayıtlarını esnetmek, yanlış girilen verileri (tarih, bölüm sayısı) doğrudan liste üzerinden düzenleyebilmek veya silebilmek. Ayrıca dizi izlerken tekrar eden manuel girişleri azaltmak.
*   **İşler**:
    *   Günlük sayfasında bir kayda basılı tutulunca açılan Önizleme (Preview) ekranına "Tarih ve Saat Düzenleme", "Bölüm Sayısı Düzenleme" (diziler için) ve "Kaydı Sil" özellikleri eklendi.
    *   `showDatePicker`, `showTimePicker` ve özel bölüm giriş dialoglarıyla, sayfa değiştirmeden ve anında listeye yansıyan veri güncellemesi.
    *   Kayıt ekleme (`add_watch_record_sheet.dart`) formunda, "Aktif İzliyorum" kapalıysa "Kaç bölüm izledin?" seçeneğinin varsayılan olarak dizinin **toplam bölüm sayısına** eşitlenmesi sağlandı (böylece tüm diziyi bitirenler için otomatik tamamlama).
    *   Drift `WatchRecords` tablosu işlemleri (deleteWatchRecord, updateWatchRecord) native/web platformları için ayrıştırılarak eklendi.

---

### **Aşama 5: Büyük Sürümler & Sosyal Entegrasyonlar (v1.1.0 - v1.3.x)**

#### **✅ v1.1.0 (Faz 3): Dizi Desteği & Çoklu Sezon İzleme Takip Sistemi**
*   **Hedef**: Dizilerin ve sezonların bölüm bazlı takibi için gerekli altyapıyı ve arayüz entegrasyonunu tamamlamak.
*   **İşler**:
    *   TMDb servisinin (`tmdb_service.dart`) dizi yaratıcılarını (creators) algılayacak şekilde güncellenmesi ve film/dizi yönetmen bilgisinin ayrıştırılması.
    *   Dizi izleme kayıtlarında veritabanı şemasının composite keys (`movieId`, `isTv`) ile çakışmaları tamamen engelleyecek hale getirilmesi.
    *   "Aktif İzliyorum" modunun varsayılan olarak en son kalınan bölümden başlatılması ve son bölüme ulaşınca otomatik tamamlanması.

#### **✅ v1.2.0 (Faz 4): Topluluk Akışı & Etkileşimli Yorum Sistemi**
*   **Hedef**: Kullanıcıların izleme günlüklerini paylaşabileceği dinamik bir sosyal akış ve yorum altyapısı kurmak.
*   **İşler**:
    *   Firestore üzerinde `logs` koleksiyonu ile tüm kullanıcıların paylaşımlarını bir araya getiren Topluluk Akışı (Community Feed) sayfası oluşturulması.
    *   Gönderilere beğeni (star) bırakma ve gerçek zamanlı yorum yapabilme altyapısının (`comments_sheet.dart`) entegre edilmesi.
    *   Kullanıcı avatarları ve kullanıcı isimleriyle sosyal profillere yönlendirme linklerinin kurulması.

#### **✅ v1.3.0 (Faz 5): Sosyalleşme & Takip Sistemi ve Akış Filtreleme**
*   **Hedef**: Kullanıcılar arası takip etme/bırakma mekanizmalarını kurmak ve sosyal akışı kişiselleştirmek.
*   **İşler**:
    *   Firestore'da `follows` koleksiyonu oluşturularak takipçi/takip edilen takibi ve kullanıcı belgelerinde sayaçların güncellenmesi.
    *   Sosyal Profil ekranının (`user_profile_screen.dart`) tasarlanması, diğer kullanıcıların profillerinde "Takip Et / Takibi Bırak" butonu ve o kişilerin günlük poster listelerinin görüntülenmesi.
    *   Topluluk Akışına "Tümü" ve "Takip Ettiklerim" filtre sekmelerinin eklenmesi.

#### **✅ v1.3.1: Hata Çözümleri & Arayüz Cilalaması**
*   **Hedef**: Büyük sürümlerin ardından gelen kullanıcı geri bildirimleriyle donma hatalarını gidermek ve arayüzü kusursuzlaştırmak.
*   **İşler**:
    *   **Giriş/Çıkış Yüklenme Hatası**: Riverpod stream dinleyicilerindeki caching/initial data sorunu çözülerek çıkış yapıp tekrar girildiğinde donması engellendi.
    *   **Dizi Yönetmen Düzeltmesi**: Firestore'daki `movieDirector` ile `DiaryLogModel`'deki `director` alan uyuşmazlığı giderildi, eski kayıtları da koruyacak geriye dönük uyumluluk filtreleri eklendi.
    *   **İstatistik Kartları Redesign**: Kutucuklar 2x2 grid yapısına geçirilerek büyütüldü ve yanlarına ikonlar eklenerek premium bir görünüme kavuşturuldu.
    *   **Sürelerin Güne Çevrilmesi**: Toplam izleme süreleri 24 saati geçtiğinde gün formatına (`7g23s30dk` gibi) çevrilecek şekilde güncellendi.
    *   **Filtre Çubuğunun Kaldırılması**: Ekran sadeleştirilerek Günlük sayfasındaki filtre çubukları kaldırıldı.
    *   **Sekme Çubuğu (TabBar) Ortalama & Yazı Büyütme**: Sekmeler tam ekran genişliğine yayılacak şekilde ortalandı, yazı boyutu 15px'e çıkarıldı ve "Analiz" olarak kısaltıldı. Tıklama esnasında oluşan kare renk taşması (splash) dairesel hale getirildi.
    *   **Zaman Kıyaslama Paneli Dinamik Karşılaştırmalar**: "Bu Sürede Neler Yapabilirdin?" kartı, her ekran açılışında 16 farklı eğlenceli ve ilginç seçenek arasından rastgele 1 tanesini seçecek ve özel emojisiyle gösterecek şekilde güncellendi.

#### **✅ v1.3.2: İzleme Girişi Sadeleştirmesi ve Kaydırma Çubuğu Optimizasyonu**
*   **Hedef**: Günlük kayıt formunu sadeleştirmek, mobil ekranlarda istatistik taşmasını engellemek ve kaydırma çubuklarını tamamen temizleyerek mobil kaydırma deneyimi sunmak.
*   **İşler**:
    *   **Saat Seçiminin Kaldırılması**: Film/dizi günlüğe eklenirken saat bilgisinin elle girilmesi zorunluluğu (ve seçici alanı) formdan tamamen kaldırıldı.
    *   **İstatistik Paneli Taşma Çözümü**: Mobil ekran genişliğinde (<500px) İstatistik Dashboard'undaki mini veri kartlarının taşmasını önlemek amacıyla `_buildMiniStat` bileşenleri `FittedBox` ile sarmalandı, yazılar dar ekranlarda otomatik olarak küçülecektir.
    *   **Scrollbar'ların Komple Kaldırılması**: Uygulama genelinde afişlerin üzerine binen veya çirkin görüntü oluşturan tüm kaydırma çubukları hem Flutter (`CineFileScrollBehavior`) hem de tarayıcı (Gölge DOM / Shadow DOM) seviyesinde tamamen görünmez kılındı.
    *   **Fareyle Kaydırma (Mouse Drag to Scroll) Desteği**: Masaüstü tarayıcılarda yatay listelerin dokunmatik ekranlardaki gibi fareyle sürüklenerek (mouse-drag) veya izleme paneliyle akıcı şekilde kaydırılabilmesi sağlandı.

#### **✅ v1.3.3: Topluluk Akışına Gizlilik/Paylaşım Kontrolü**
*   **Hedef**: v1.2.0'da kurulan Topluluk Akışı'nın, kullanıcı onayı olmadan HER izleme kaydını (özel notlar dahil) herkese açık göstermesini durdurmak; paylaşımı kullanıcının açıkça seçtiği (opt-in) bir davranışa çevirmek.
*   **İşler**:
    *   `WatchRecords` tablosuna (Drift, schema v9, veri kaybı olmayan migration) ve `DiaryLogModel`e (Firestore) `isPublic` alanı eklendi — varsayılan **gizli (false)**; `isPublic` alanı olmayan tüm eski kayıtlar da geriye dönük olarak gizli sayılıyor.
    *   Kayıt ekleme formuna (`add_watch_record_sheet.dart`) ve günlük kaydı önizleme/düzenleme dialoguna (`watch_record_preview_dialog.dart`) "Topluluğa Paylaş" switch'i eklendi; otomatik bölüm loglaması (`episode_logging.dart`) her zaman gizli olarak kaydediyor.
    *   `community_feed_provider.dart` sorgusu `isPublic == true` filtresiyle sınırlandırıldı (kullanıcının kendi profilindeki "Son İzlediklerim" bölümü hâlâ tüm kayıtlarını gösteriyor).
    *   Projeye ilk kez `firestore.rules` ve `firestore.indexes.json` eklendi ve production'a deploy edildi — artık sunucu tarafında da gizli kayıtlar, başkasının profil/paylaşım bilgisi ve kimlik taklidiyle yazma engelleniyor (emulator'da 18 senaryoluk otomatik testle doğrulandı).

#### **✅ v1.3.4: Dizi Günlük Kaydı, Tarih Seçici ve Günlük Tablosu Cilalaması**
*   **Hedef**: Bir diziyi günlüğe eklerken "bitirdim mi yoksa hâlâ mı izliyorum" niyetini doğru varsayılanla yakalamak, eski bir tarihi seçerken ay ay geri gitme zorunluluğunu kaldırmak, kayıt formundan kaydetmeden çıkılamaması sorununu gidermek ve Günlük tablo görünümündeki hizalama/boyut sorunlarını düzeltmek.
*   **İşler**:
    *   **"Tüm Sezonu Bitirdim" Varsayılanı**: `add_watch_record_sheet.dart`'ta "Aktif İzliyorum" kapalıyken artık **"Tüm sezonu bitirdim"** (varsayılan seçili) ile **"Belirli sayıda bölüm"** arasında açık bir seçim var. Önceden varsayılan sessizce "1 bölüm izlendi" olarak kaydediyordu; artık varsayılan davranış diziyi doğrudan tamamlanmış (`lastWatchedEpisode = totalEpisodes`, `isActivelyWatching = false`) işaretliyor. Bu kayıt için sayılan bölüm sayısı, önceden loglanmış bölümler varsa sadece **kalanları** sayıyor (v0.9.6'daki "her ekleme tüm seriyi tekrar izlemiş gibi sayar" bug'ının tekrarlanmaması için delta hesaplaması korundu).
    *   **Elle Bölüm Sayısı Girişi**: "Belirli sayıda bölüm" seçildiğinde artık stepper'ın yanında sayıyı doğrudan yazabilen bir metin kutusu var — 786 bölümlük bir diziyi "+" ile tek tek tıklamak yerine direkt yazılabiliyor; toplam bölüm sayısını aşan girişler otomatik sınıra çekiliyor.
    *   **Kayıt Formunu Kapatma Butonu**: "Günlüğe İzleme Kaydı Ekle" sheet'inde daha önce açık bir kapatma (✕) butonu yoktu; içerik uzun olduğunda (özellikle dizi bölüm takibi açıkken) sheet tüm ekranı kaplayıp dışarı tıklanacak alan bırakmıyor, kaydetmeden çıkmayı imkânsız kılıyordu. Başlığa `Navigator.pop` çağıran bir ✕ butonu eklendi.
    *   **Tarih Seçicide Yıl Atlama**: `PremiumDatePicker`'da eski bir yılı seçmek için ay okuyla tek tek geri gitmek gerekiyordu. Başlığa (`Ay Yıl`) dokununca açılan bir **yıl ızgarası** eklendi; seçili yıla otomatik kaydırılıyor, bir yıla dokununca takvim doğrudan o yıl/aya atlıyor.
    *   **Günlük Tablosu Hizalama Düzeltmesi**: Tablo görünümünde "Puanım" sütunu sola hizalıydı; aktif izlenen bir dizinin son kaydında altına eklenen "Bölüm X/Y +" etiketiyle birlikte satırın ortasında ayrık/çakışan bir kutu gibi görünüyordu (kart görünümü zaten sağa hizalıydı, tutarsızlık vardı). Sütun sağa hizalandı, yıldız/puan/etiket ikonları büyütüldü.
    *   Tüm değişiklikler için widget testleri eklendi (`add_watch_record_episode_tracking_test.dart`, yeni `premium_date_picker_test.dart`); `dart analyze lib` temiz, `flutter test` 24/24 geçiyor.

#### **✅ v1.4.0: Topluluk Keşfi, Kullanıcı Arama ve Gerçek "Post" Sistemi**
*   **Hedef**: Topluluk Akışı'nı, kullanıcıların birbirini bulabildiği ve yapılandırılmış içerik paylaşabildiği gerçek bir sosyal akışa dönüştürmek — kullanıcı adına göre arama/keşif eklemek, akışın en üstüne (serbest metinli bir gönderi kutusu OLMADAN) yapılandırılmış bir paylaşım kutusu koymak, ve "paylaşım" kavramını `logs.isPublic` bayrağının yeniden yorumlanmasından gerçek, bağımsız, kalıcı "post" nesnelerine taşımak.
*   **İşler**:
    *   **Kullanıcı Arama/Keşif**: Yeni `user_search_provider.dart`/`user_search_screen.dart` — kullanıcı adına göre case-insensitive prefix araması (`usernameLower` alanı, `AuthController.signUp()`'ta otomatik yazılıyor; mevcut kullanıcılar için bir kerelik backfill script'i çalıştırıldı). Topluluk Akışı'na arama ikonu, boş "Takip Ettiklerim" durumuna "Kullanıcı Ara" CTA'sı eklendi. Paylaşılan `FollowButton` widget'ı + `toggleFollow` helper'ı ile takip et/bırak mantığı tek yere toplandı.
    *   **Profil Gizlilik Düzeltmesi**: `watchRecordsForUserProvider`, başkasının profiline bakan bir ziyaretçiye o kişinin **özel** kayıtlarını da sorgulatıp `permission-denied` hatası veriyordu (Firestore rules bunu reddediyordu). Sorguya, sahibi olmayan görüntüleyiciler için `isPublic == true` filtresi eklendi.
    *   **Gerçek Post Modeli**: Topluluk Akışı artık `logs` koleksiyonunu `isPublic` ile filtrelemek yerine yeni bir `posts` koleksiyonunu okuyor (`community_post_model.dart`). Her paylaşım eylemi kendi bağımsız, kalıcı post'unu oluşturuyor — biri diğerinin içine gömülmüyor (önceki "kullanıcının tüm açık kayıtlarını tek kartta topla" tasarımı, yeni bir paylaşımın eski bir toplu paylaşımın içinde kaybolmasına yol açan gerçek bir bug'a neden olmuştu, bu yüzden tamamen kaldırıldı):
        *   **Film Paylaş**: `share_movie_picker_sheet.dart` ile tek bir günlük kaydı seçilir, `share_compose_sheet.dart` ile zorunlu bir mesaj yazılır ("çok güzel filmdi bitirdim" gibi), o anki film/puan/mod bilgisiyle donmuş bir `movie` tipi post oluşturulur.
        *   **Günlüğünü Paylaş**: Aynı seçim ekranının çoklu-seçim modu; seçilen kayıtlar donmuş bir `entries` dizisi olarak tek bir `diary_snapshot` post'una gömülür — post oluşturulduktan SONRA günlüğe eklenen yeni filmler o postu **asla** etkilemez (`user_public_diary_screen.dart` artık canlı bir sorgu değil, doğrudan post'un kendi donmuş listesini gösteriyor).
        *   **Koleksiyon Paylaş**: Film/günlük paylaşımlarının aksine bilinçli olarak **canlı senkronize** — `CustomLists` tablosuna (Drift, schema v10) `isPublic` sütunu eklendi; paylaşılan bir koleksiyon her düzenlemede (`movie_repository.dart`'taki `_mirrorSharedCollection`) yeni `shared_collections/{ownerId_listId}` Firestore belgesine otomatik yeniden yazılıyor, görüntüleyiciler `sharedCollectionProvider` ile bunu canlı izliyor (`shared_collection_detail_screen.dart`). Koleksiyon yönetim ekranına (`custom_list_detail_screen.dart`) "Toplulukla paylaşılıyor" rozeti + "Paylaşımı Durdur" aksiyonu eklendi. Web build'de bu özellik devre dışı (yalnızca native/Drift tarafı aynalanıyor).
        *   Topluluk Akışı'nın en üstüne bir "paylaşım kutusu" eklendi (`community_feed_screen.dart`) — X/Twitter tarzı görünüyor ama dokunulduğunda serbest metin yazmak yerine `share_options_sheet.dart`'ın üç yapılandırılmış seçeneğini açıyor.
        *   Kayıt formundaki eski "Topluluğa Paylaş" anahtarı "Profilimde Göster" olarak yeniden adlandırıldı ve artık sadece profildeki "Son İzlediklerim" görünürlüğünü kontrol ediyor — Topluluk Akışı'ndaki paylaşımlarla tamamen bağımsız, ayrı bir mekanizma.
    *   `firestore.rules`'a `posts`, `posts/{id}/comments` ve `shared_collections` blokları eklendi ve production'a deploy edildi.
    *   `GlassContainer`'a şeffaf bir `Material` sarmalayıcı eklendi — içindeki `ListTile`/`CheckboxListTile` dokunma efektlerinin görünmez olduğu (Flutter'ın kendi assertion'ı) önceden var olan bir hatayı da düzeltti (`AddToListSheet` dahil).
    *   Kapsamlı yeni test dosyaları eklendi (kullanıcı arama, profil gizliliği regresyonu, post oluşturma/render, donmuş günlük snapshot regresyonu, canlı koleksiyon senkron regresyonu); `dart analyze lib` temiz, `flutter test` 45/45 geçiyor.

#### **✅ v1.4.1: Topluluk Akışı Başlık/Arama Deneyimi ve Premium Poster Şeridi**
*   **Hedef**: Topluluk Akışı'nda kullanıcı aramasını Günlük ekranındaki gibi sayfa içi hale getirmek ve post kartlarındaki poster önizlemesini daha okunaklı/etkileşimli bir tasarıma kavuşturmak.
*   **İşler**:
    *   Topluluk Akışı başlığına profil avatarı eklendi; kullanıcı arama artık ayrı bir sayfaya gitmeden (Günlük ekranındaki arama alanı deseniyle aynı şekilde) sayfa içinde açılıp kapanıyor.
    *   Günlük/Koleksiyon post kartlarındaki üst üste binen küçük poster şeridi (`_PosterFilmstrip`), büyük ve yatay kaydırılabilir bir film şeridine dönüştürüldü — "+N" rozeti, hover/dokunmatikte büyüme+gölge geri bildirimi eklendi.
    *   `firestore.rules`'a önceki oturumda production'a deploy edilmiş olan `shared_collections` kuralları commit'e yansıtıldı (kod ile sunucu kuralları arasındaki tutarsızlık giderildi).
    *   Bekleyen küçük düzeltmeler: bazı ekranlarda eksik olan `TextEditingController`/`ScrollController` dispose çağrıları tamamlandı (bellek sızıntısı), `drift/web.dart` deprecation uyarısı bilinçli bir `ignore` yorumuyla susturuldu.

#### **✅ v1.4.2: Ana Sayfa Premium Yeniden Tasarımı ve Senkron/Performans Düzeltmeleri**
*   **Hedef**: Ana Sayfa'yı sinematik bir odak noktasına kavuşturmak; bunu yaparken Ana Sayfa ile Günlük arasında ortaya çıkan gerçek veri tutarsızlıklarını ve performans sorunlarını gidermek.
*   **İşler**:
    *   Ana Sayfa'ya sinematik hero banner eklendi (öncelik sırası: aktif izlenen dizi carousel > "Bu Hafta Ne İzlesem?" önerisi > son izlenen film), header'a accent-color glow halkası ve tutarlı `textTheme` tipografisi (yeni `labelSmall` stili dahil) uygulandı; ekran `widgets/` alt klasörüne bölündü (`home_header_bar`, `home_hero_banner`, `home_hero_carousel`, `home_stats_dashboard`, `home_content_lists`).
    *   **Bulunan ve düzeltilen gerçek hata**: "+" ile bölüm ilerletme (Ana Sayfa'daki "Aktif İzlediklerin" şeridi ve Günlük'teki hızlı etiket) artık günlüğe sahte/yeni bir kayıt eklemiyor — sadece ilerleme sayacını (`lastWatchedEpisode`/`isActivelyWatching`) güncelliyor. Ortak `advanceEpisodeProgress` fonksiyonuna taşındı (`episode_logging.dart`); eski davranış her dokunuşta Günlük'te sanki yeni bir yapım eklenmiş gibi görünen fazladan kayıtlar biriktiriyordu.
    *   Bu eski hatanın geçmişte bıraktığı mükerrer kayıtları toplu tespit edip temizleyen bir araç Ayarlar → Veri Yönetimi & Yedekleme altına eklendi (`duplicate_cleanup.dart`, `duplicate_cleanup_screen.dart`) — aynı gün için birden fazla kayıt bulunan dizi/filmleri gruplar, en ileri ilerlemeyi yansıtan kaydı tutup gerisini siler ve ilerleme sayacını doğru değere geri yazar.
    *   **Bulunan ve düzeltilen ikinci gerçek hata**: `allWatchRecordsProvider`, `movie_settings` (bölüm ilerlemesi, favoriler vb.) değişikliklerini artık canlı dinliyor — önceden Ana Sayfa ile Günlük arasında gösterilen bölüm numarası tutarsız kalıyor, Günlük'teki "+" dokunuşu o ekranı güncellemiyordu. İki Firestore akışı (`logs` + `movie_settings`) artık ana akışı her ayar değişikliğinde yeniden kurup kısa süreliğine "yükleniyor" durumuna düşürmeden, manuel olarak tek bir çıktıda birleştiriliyor (bunun sebep olduğu görsel titreme de ayrıca ortadan kalktı).
    *   **Performans**: poster/backdrop görselleri artık ekranda gösterildikleri boyuta göre decode ediliyor (`memCacheWidth`/`Height`, `cacheWidth`/`Height`); küçük liste öğelerindeki (poster rozetleri, satır kartları) pahalı `BackdropFilter` bulanıklığı kaldırılıp düz yarı saydam dolguya geçildi (yeni `GlassContainer.useBlur` parametresi); gereksiz arka plan/scroll rebuild'leri önlendi.
    *   Günlük'ün üst mini istatistik paneli, Ana Sayfa'daki cam panel tasarım diliyle (aynı ikon+metin düzeni, paylaşılan `textTheme` stilleri) yeniden tasarlandı.

#### **✅ v1.4.3: Film/Dizi Detay Sayfasında Kaydırma Sırasında Yukarı Zıplama Düzeltmesi**
*   **Hedef**: Film/Dizi Detay sayfasında aşağı doğru kaydırırken sayfanın anlık olarak en yukarı zıplamasını gidermek (kullanıcı bildirimiyle bulundu).
*   **İşler**:
    *   **Kök neden 1**: `DynamicBackgroundWrapper`, aktif poster rengi yokken düz bir `Container`, renk geldiğinde ise bir `Stack` döndürüyordu. Renk çıkarma asenkron olduğu için bu geçiş kaydırma sırasında gerçekleşebiliyordu; aynı ağaç konumunda widget tipi değişince Flutter altındaki her şeyi (sayfanın `ScrollController`'ı dahil) yok edip yeniden kuruyordu. Artık her zaman aynı `Stack` şekli döndürülüyor, renk yokluğu/varlığı sadece degradelerin opacity'siyle ifade ediliyor.
    *   **Kök neden 2 (asıl tetikleyici)**: `movie_detail_screen.dart`'ta arka plan görseli ve siyah maske, `backdropOpacity > 0` (yani kaydırma tam 200px'i geçtiğinde 0 olan) koşuluyla Stack'in `children` listesinden komple çıkarılıyordu. Liste uzunluğu değişince, key verilmemiş listede elemanları konumlarına göre eşleştiren Flutter, kaydırma alanının bağlı olduğu Element'i yanlış eşleştirip yok edip yeniden kuruyor, bu da `ScrollController`'ın pozisyonunu sıfırlayıp sayfayı tepeye zıplatıyordu. Artık bu iki widget her zaman ağaçta kalıyor (`backdropPath != null` dışında scroll'a bağlı bir koşulları yok), görünürlüğü zaten var olan `Opacity(opacity: backdropOpacity)` sağlıyor.

#### **✅ v1.4.4: Keşfet Çökme Düzeltmesi ve "Günlüğe İzleme Kaydı Ekle" Formu İyileştirmeleri**
*   **Hedef**: Keşfet ekranındaki poster grid'inin hata metniyle çökmesini gidermek; kayıt ekleme formunu daha erişilebilir ve zengin hale getirmek (kullanıcı bildirimleriyle bulundu).
*   **İşler**:
    *   **Bulunan ve düzeltilen gerçek hata**: Keşfet'in poster grid'i `AppNetworkImage`'a esnek hücreleri doldurmak için `width: double.infinity` veriyordu; v1.4.2'deki decode-boyutu optimizasyonu bu sonsuz değeri `dpr` ile çarpıp `.round()` çağırınca `Unsupported operation: Infinity` hatası posterlerin yerine basılıyordu. `app_network_image.dart`'ta `cacheWidth`/`cacheHeight` ve `memCacheWidth`/`memCacheHeight` hesaplamaları artık genişlik/yüksekliğin `isFinite` olup olmadığını da kontrol ediyor.
    *   **"Kaydı Günlüğe Ekle" butonu her zaman görünür**: Buton, uzun formlarda (özellikle dizi bölüm takibi açıkken) kaydırma yapılmadan erişilemez hale geliyordu. Artık kaydırılabilir form alanlarının dışında, sheet'in altına sabitlenmiş ayrı bir katman (sheet yüksekliği ekranın %92'siyle sınırlı).
    *   **Sabit üst başlık + sürükleyerek kapatma**: Tutamaç çubuğu + başlık + kapatma butonu da kaydırma alanının dışına alındı — form kaydırılsa bile her zaman görünür kalıyor, ayrıca en tepedeyken bu bölgeden aşağı sürüklemek artık iç `SingleChildScrollView` tarafından yutulmadığı için sheet'in varsayılan sürükleyerek kapatma jesti bu alandan çalışıyor.
    *   **Ruh Hali / Nerede İzledin / Kiminle İzledin / Özel Etiketler**: Dört alanın seçenek listeleri genişletildi (Ruh Hali 7→16, Nerede İzledin 4→9, Kiminle İzledin 4→8, Etiketler 5→12) ve tamamı çok satıra bölünüp taşan `Wrap` yerine tek satır, yatay kaydırılabilir listelere (`ListView.separated`) dönüştürüldü. Eski `ActionChip`ler yerine paylaşılan, daha zarif bir hap (pill) tasarımı (`_SuggestionChipRow`) kullanıldı; Ruh Hali'nde seçili emoji artık ince bir accent-glow gölgesiyle vurgulanıyor. Kaydırılabilir satırların taşma gölgesi ilk halde sheet'in kenar boşluğunu aşıp cihaz çerçevesine kadar gidiyordu (`Clip.none` hatası) — varsayılan kırpmaya (`hardEdge`) geri dönülerek düzeltildi.

#### **✅ v1.4.5: Gerçek Uygulama İkonu ve Açılış Ekranı (Marka Kimliği)**
*   **Hedef**: Uygulama o zamana kadar hiç özelleştirilmemiş Flutter şablon ikonunu ve mavi varsayılan splash ekranını gerçek CineFile marka kimliğiyle değiştirmek (kullanıcı bildirimiyle bulundu — `flutter_launcher_icons`/`flutter_native_splash` hiç kurulmamıştı).
*   **İşler**:
    *   Kullanıcının sağladığı "sinema bileti" temalı CineFile logosundan (`CineFileLOGO/Cinefilenbkv3.png`, 1254×1254, şeffaf arka plan) iki türetilmiş varlık üretildi: `assets/icon/app_icon.png` (kamera/yıldız/saat + "CineFile" wordmark + mozaik dokuyu içeren, küçük "EST. 2026"/"TICKET ID" metinlerini dışarıda bırakan kare kırpma — tam bilet illüstrasyonu ikon boyutunda okunaksız kalıyordu) ve `assets/icon/app_icon_foreground.png` (Android adaptive icon için %25 güvenli kenar boşluklu, dairesel/squircle maskede kırpılmayacak versiyon). Tam detaylı bilet, açılış ekranı için `assets/icon/splash_logo.png` olarak aynen korundu (büyük ekranda tüm detaylar okunaklı).
    *   `flutter_launcher_icons: 0.14.4` ve `flutter_native_splash: 2.4.8` dev bağımlılık olarak eklendi; `pubspec.yaml`'a her ikisi için de yapılandırma bloğu eklendi (Android/iOS/Web/Windows ikonları, adaptive icon arka planı `AppTheme.backgroundColor` (`#0B0D13`) ile eşleşiyor).
    *   **iOS App Store uyumluluğu**: `remove_alpha_ios: true` + `background_color_ios: "#0B0D13"` ile ikondaki şeffaflık kaldırılıp uygulamanın koyu temasıyla aynı renge düz olarak yassılaştırıldı (Apple şeffaf ikonu reddediyor).
    *   `dart run flutter_launcher_icons` ve `dart run flutter_native_splash:create` çalıştırılarak Android (mipmap + adaptive icon + `android12splash`), iOS (`AppIcon.appiconset` + launch storyboard), web (favicon + maskable ikonlar) ve Windows ikonları/splash'leri gerçek marka görseliyle güncellendi.

---

### **Aşama 6: Veri Bütünlüğü, Sosyal Olgunlaşma ve Kod Kalitesi (v1.5.0 - v1.6.0) — Planlanan**

#### **✅ v1.5.0: Yedekleme Bütünlüğü, Gizlilik ve Premium Profil Tasarımı**
*   **Hedef**: v0.9.9'da bilinçli olarak kapsam dışı bırakılan eksik yedekleme ve işlevsiz profil düzenlemeyi çözmek; gizlilik açıklarını kapatmak ve profil arayüzünü ultra-premium görsel standartlara taşımak.
*   **İşler**:
    *   **✅ Tam Yedekleme (Backup & Restore)**: Ayarlar → Veri Yönetimi export/import akışına `CustomLists` ve `CustomListMovies` tablolarının dahil edilmesi (tamamlandı; hem Web hem de Native için yedekleme ve geriye dönük uyumlu geri yükleme entegre edildi).
    *   **✅ Gizlilik Güncellemesi (Email Privacy)**: Kullanıcıların birbirlerinin e-posta adreslerini görememesi için profil ekranlarındaki e-posta (Gmail) gösterim alanı tamamen kaldırıldı.
    *   **✅ Profil Düzenleme & Hazır Avatarlar**: Kullanıcı adı ve biyografi düzenleme desteği Firestore ile entegre edildi. Firebase Storage ücretli plan gereksinimlerini aşmak için 8 adet sinema temalı hazır DiceBear avatar seçici entegre edildi. Profil cam kartının sağ üst köşesine hızlı düzenleme kalem ikonu yerleştirildi.
    *   **✅ Görsel Revizyon & Cam Kartlar (Glassmorphism)**: Profil bilgileri degradeli buzlu cam kart (`GlassContainer`) içine yerleştirildi, avatarın arkasına sinematik mor/altın radyal ışık huzmeleri ve degrade halka çerçeve yerleştirildi. İstatistikler yarı saydam hap kapsüllerine dönüştürüldü. Bölüm başlıklarının soluna neon dikey çizgiler yerleştirildi.
    *   **✅ Favori Vitrinim (Showcase Shelf)**: Kullanıcının 5 adede kadar en sevdiği yapımı sergileyebileceği, posterleri üst üste binen yatay raf paneli tasarlandı.
        *   Kartlar arası mesafenin dar ekranlarda taşmasını önlemek amacıyla `LayoutBuilder` ile dinamik yelpaze genişliği (`spacing`) hesaplaması eklendi.
        *   Kart geçişlerindeki takılma/glitch hatalarını önlemek için `ValueKey` entegrasyonu yapıldı; animasyon eğrisi fiziksel yaylanma hissi sunan `Curves.easeOutBack` olarak güncellendi.
        *   Vitrin başlığı ve doğrudan vitrini düzenlemeyi sağlayan özel kalem ikonu raf kutusunun içine konumlandırıldı.
    *   **✅ Premium Seçim Paneli (`_PremiumFeaturedSelectorDialog`)**: Vitrini düzenle butonu için klasik gri Material diyalog kutusu tamamen kaldırılarak, **film afiş önizlemeli (40x60px), tür çipli (Film/Dizi) ve parlayan dairesel onay halkalı özel bir buzlu cam dialog kutusu** kodlandı. Degrade "Kaydet" ve minimalist "İptal" butonları eklendi.

#### **✅ v1.5.1: Kişisel Film/Dizi Önerisi Motoru**
*   **Hedef**: v0.9.3'teki "Bu Hafta Ne İzlesem?" kartından farklı olarak — o sadece kütüphanede zaten var olup izlenmemiş yapımları öneriyor — kullanıcının izleme geçmişinden çıkarılan bir zevk profiliyle, kütüphanede hiç olmayan **yeni** film/dizi keşifleri sunmak.
*   **İşler**:
    *   **✅ TMDb Puan Rozeti & Özet Kartları**: Detay sayfasına TMDb `vote_average` ve `vote_count` bilgileriyle şık bir rozet (badge) yerleştirildi. Bu premium tasarım dili (lacivert arka plan ve açık yeşil sınır çizgisi), sayfadaki diğer 3 özet kartına ("Puanım", "Yönetmen", "Ortam") da yansıtılarak görsel bütünlük sağlandı.
    *   **✅ Zevk Profili & Discover Sorgusu**: Kullanıcının en çok izlediği tür/yönetmen/oyunculardan (`allWatchRecordsProvider` + `insightsProvider`'ın zaten hesapladığı istatistiklerin yeniden kullanılması) çıkarılan basit bir ağırlıklı profil, TMDb `/discover/movie` ve `/discover/tv` uç noktalarını sorguluyor; kütüphanede (herhangi bir `WatchRecords`/`UserMovieSettings` kaydı) zaten bulunan yapımlar eleniyor (`recommendations_provider.dart`).
    *   **✅ "Sana Özel" Şeridi**: Ana Sayfa'ya yatay kaydırılabilir öneri şeridi eklendi (`HomeRecommendationsList`), her karta dokununca Film Detay sayfasına gidiyor.
    *   **✅ "Neden önerildi?" Etiketi**: Her öneri kartı `RecommendationItem.reason` alanıyla kısa bir açıklama gösteriyor (ör. "Christopher Nolan filmlerini sevdiğin için").
    *   **✅ Boş/Küçük Kütüphane Fallback**: <5 kayıtlı veya `insights == null` kullanıcılar için TMDb popüler film/dizi listesine (`getPopularMovies`/`getPopularTvShows`) düşülüyor.

#### **✅ v1.5.1a: Yaklaşan Çıkışlar İçin Yerel Bildirim**
*   **Hedef**: "İzleyeceklerim" listesine eklenen ama henüz vizyona/yayına girmemiş bir film/dizinin çıkış tarihini kullanıcının elle takip etmesini gerektirmeden, çıkış günü geldiğinde otomatik hatırlatmak — mevcut Takvim sekmesiyle ve v0.9.5'te zaten doğrulanan `release_date` verisiyle doğal olarak örtüşen bir özellik.
*   **İşler**:
    *   **✅ Yeni bağımlılık**: `flutter_local_notifications` ve `timezone` paketleri projeye entegre edildi.
    *   **✅ İzleme Listesi Butonu**: Film Detay sayfasına favori butonunun yanına bookmark simgeli İzleme Listesi ("İzleyeceklerim") butonu eklendi; veritabanı senkronu kuruldu.
    *   **✅ Bildirim Zamanlama Servisi (`NotificationService`)**: Çıkış gününde saat sabah 10:00'a `zonedSchedule` üzerinden bildirim zamanlayan, iptal eden ve periyodik senkronize eden altyapı oluşturuldu.
    *   **✅ Bildirime Dokununca Yönlendirme**: Bildirimlere tıklandığında uygulamanın açılıp doğrudan ilgili yapımın detay sayfasına yönlendirilmesi (deep-linking) sağlandı.
    *   **✅ Ayarlar ve İzin Yönetimi**: Ayarlar sayfasına "Çıkış Hatırlatıcıları" açma/kapama anahtarı eklendi, opt-in olarak izin isteme süreçleri ve otomatik senkronizasyon entegre edildi.
    *   **✅ Çıkış Tarihi Doğrulaması**: Sadece gelecekteki çıkışlar için bildirim planlanır, geçmiştekiler elenir. Uçuş sırasındaki değişiklikler uygulama açılışında otomatik güncellenir.

#### **✅ v1.5.2: Kod Kalitesi ve Dosya Bölme Cilası**
*   **Hedef**: CLAUDE.md'deki 300-400 satır kuralını aşan ekranları `widgets/` alt klasörlerine bölmek, önceki denetimde bulunan (sessiz catch, `kIsWeb` sızıntısı, EOL bağımlılık) sorunları gidermek ve test kapsamını/güvenilirliğini artırmak.
*   **İşler**:
    *   **✅ Dosya Bölme** — CLAUDE.md'nin "state callback/parametre olarak geçilir, State'in private alanlarına doğrudan erişilmez" kuralına uyularak 9 dosya bölündü:
        *   `user_profile_screen.dart` 1327 → 150 satır (8 widget dosyası)
        *   `community_feed_screen.dart` 956 → 375 satır (3 widget dosyası)
        *   `contribution_heatmap.dart` 734 → 253 satır (4 yardımcı dosya: grid/legend/badges/utils)
        *   `insights_misc_cards.dart` 580 satır → 5 bağımsız widget dosyasına ayrıştırıldı (dosya silindi)
        *   `custom_list_detail_screen.dart` 525 → 234 satır (4 widget dosyası)
        *   `movie_detail_screen.dart` 853 → 527 satır (5 widget dosyası)
        *   `search_screen.dart` 476 → 192 satır (3 widget dosyası)
        *   `journal_screen.dart` 661 → 365 satır (4 widget dosyası + saf mantık `journal_logic.dart`)
        *   `settings_screen.dart` 614 → 117 satır (6 widget dosyası)
        *   `add_watch_record_sheet.dart` 606 → 507 satır (3 dosya — form state yoğunluğu nedeniyle bilinçli olarak eşiğin biraz üzerinde bırakıldı)
        *   Not: `database_provider.dart` (836), `settings_provider.dart` (554), `insights_provider.dart` (436), `tmdb_service.dart` (422), `movie_repository.dart` (413) bilinçli olarak kapsam dışı bırakıldı — bunlar widget/ekran değil, provider/servis katmanı dosyaları (CLAUDE.md'nin "Widget dosya boyutu" kuralı ekranları hedefliyor).
    *   **✅ Önceki denetim bulgularının düzeltilmesi**: `movie_detail_screen.dart` ve `recommendations_provider.dart`'taki sessiz `catch (_) {}` blokları loglanır/kullanıcıya bildirilir hale getirildi; `duplicate_cleanup.dart`'taki elle yazılmış `kIsWeb` dallanması `MovieRepository.deleteWatchRecordsByIds` metoduna taşındı; discontinued `palette_generator` paketi kaldırılıp yerine Flutter'a gömülü `ColorScheme.fromImageProvider` (`material_color_utilities`) geçirildi.
    *   **✅ Test güvenilirliği**: `widget_test.dart`'ın gerçek bir TMDb ağ isteği tetikleyip (Ana Sayfa'nın öneri şeridi üzerinden) test teardown'ında "Timer is still pending" ile başarısız olması kök nedenine inilerek düzeltildi (`recommendationsProvider` test override'ı). `NotificationService`, `flutter_local_notifications`'ın test ortamında platform kanalı olmadığı için attığı (ve zaten yakalanıp loglanan, ama gürültülü) `LateInitializationError`'ları artık test ortamını tespit edip atlıyor.
    *   `dart analyze lib` ve `flutter test` (59/59) her adımdan sonra çalıştırılıp temiz/yeşil tutuldu.

#### **🔜 v1.6.0: "CineFile Wrapped" — Paylaşılabilir Yıllık Özet**
*   **Hedef**: Mevcut İçgörüler verisini (yönetmen/tür/puan dağılımı, streak, toplam süre — zaten v0.8.x'te hesaplanıyor) yıl sonunda tek, görsel olarak zengin ve dışa aktarılabilir bir "özet kart" haline getirerek hem kullanıcıya değer katmak hem de organik paylaşım/keşif kanalı açmak.
*   **İşler**:
    *   Mevcut `insightsProvider` çıktısından türeyen, belirli bir takvim yılına odaklı yeni bir `yearInReviewProvider`.
    *   Dikey, story/poster formatında bir özet ekranı (en çok izlenen film/dizi, toplam süre, en aktif ay, puan ortalaması, streak rekoru) — zaten var olan `GenreChartCard`, zaman kıyaslama kartı gibi bileşenlerin yeniden kullanılması (kod tekrarı yok).
    *   `share_plus` (zaten bağımlılıklarda mevcut) ile ekran görüntüsünü PNG olarak dışa aktarıp paylaşma.
    *   İsteğe bağlı: Topluluk Akışı'na bu özeti `post` tipi olarak (v1.4.0'daki `movie`/`diary_snapshot`/`collection` post modeline dördüncü bir `year_review` tipi eklenerek) paylaşabilme.

#### **🔜 v1.6.1: Bildirimler, İçerik Yönetimi ve Admin Moderasyonu**
*   **Hedef**: Topluluk özelliklerini (v1.2-v1.4) "yayınla ve unut" aşamasından çıkarıp, kullanıcıların etkileşimden haberdar olduğu, kendi içeriğini yönetebildiği **ve** uygunsuz içeriğin sahipsiz kalmadığı olgun bir sosyal deneyime taşımak.
*   **İşler**:
    *   Firestore `notifications` koleksiyonu: bir gönderi beğenildiğinde/yorumlandığında veya yeni bir takipçi kazanıldığında bildirim üretimi; Topluluk Akışı başlığına okunmamış sayacı olan bir zil ikonu.
    *   Kullanıcının kendi gönderisini/yorumunu silebilmesi (şu an sadece oluşturma var, silme yok).
    *   Web build'de devre dışı bırakılan "Koleksiyon Paylaş" (canlı senkron) özelliğinin web/Drift-web tarafına da taşınması.
    *   Temel kullanıcı engelleme (`blocked_users` alt koleksiyonu) — engellenen kullanıcının gönderileri akıştan ve profil aramasından filtrelenir.
    *   **Admin Hesabı ve Moderasyon Paneli**: Cloud Functions/Custom Claims gerektirmeyen, mevcut client-only Flutter+Firestore mimarisine uygun hafif bir model — yeni bir Firestore `admins` koleksiyonu (`{uid}` belgesi varlığı = admin), `firestore.rules`'a `isAdmin()` yardımcı fonksiyonu (`exists(/databases/$(db)/documents/admins/$(request.auth.uid))`) eklenerek adminlerin **herhangi bir** `posts`/`comments`/`logs` belgesini (sahibi olmasa da) silebilmesi ve bir kullanıcıyı `users/{uid}.suspended = true` ile askıya alabilmesi.
        *   Admin ekleme/çıkarma **elle** Firebase Console'dan yapılır (ilk sürümde uygulama içi "admin ata" arayüzü **yok** — bu, bir admin'in başka bir admin oluşturup yetkiyi client tarafından kontrolsüz genişletmesini engelleyen bilinçli bir kısıt).
        *   Uygulama içinde yeni bir gizli `admin_panel_screen.dart` — sadece `isAdmin` (kullanıcının `admins` koleksiyonundaki varlığı `AuthController` açılışında bir kerelik kontrol edilip cache'lenir) true dönen kullanıcılara Ayarlar altında görünen bir giriş noktası. Bekleyen "şikayet edildi" gönderi/yorum kuyruğu, tek dokunuşla silme, kullanıcı askıya alma/kaldırma.
        *   Gönderi/yorum için basit bir kullanıcı **şikayet (report)** aksiyonu (`reports` koleksiyonu: `targetId`, `targetType`, `reporterId`, `reason`, `createdAt`) — admin panelindeki kuyruğun veri kaynağı.
        *   `suspended = true` olan kullanıcılar `firestore.rules` seviyesinde yeni post/yorum/beğeni oluşturamaz; giriş yaptıklarında uygulama içi bir bilgilendirme ekranı gösterilir (hesap engellenmemiş, sadece topluluk yazma yetkisi kısıtlanmış — kendi günlüğüne native tarafta kayıt tutmaya devam edebilir).
        *   Not: Bu, ölçeklenebilir/kurumsal bir yetkilendirme sistemi değil, tek geliştiricili küçük ölçekli bir topluluk için "yeterince güvenli" bir çözüm — kullanıcı sayısı büyürse Custom Claims + Cloud Functions'a geçiş ayrı bir görev olarak değerlendirilmeli.

---

## 📈 Proje Durumu

Uygulama planlanan tüm MVP aşamalarını ve büyük sosyal özellikleri (Faz 3, 4, 5) başarıyla tamamlamıştır. v1.4.x serisi arayüz/marka cilası ile kapandı. Sıradaki odak (v1.5.0-v1.6.0): açık kalan veri güvenliği eksiklerini kapatmak, sosyal özellikleri bildirim/yönetim katmanıyla olgunlaştırmak, büyüyen dosyaları CLAUDE.md kurallarına göre bölmek ve yıl sonu özet özelliğiyle yeni bir kullanıcı değeri eklemek.


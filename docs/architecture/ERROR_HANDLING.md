# CineFile hata işleme politikası

Her `catch` bloğu aşağıdaki üç sonuçtan birini açıkça seçer:

1. **Kullanıcı geri bildirimi:** Kullanıcının başlattığı işlem başarısızsa ekran,
   toast veya snackbar sonucu anlaşılır biçimde gösterir.
2. **Merkezi gözlemleme:** Uygulama çalışmaya devam ederken veri, ağ, depolama
   veya dışa aktarma hatası oluşursa `reportError` çağrılır. Sentry kapalı yerel
   geliştirmede aynı olay bağlam etiketiyle konsola yazılır.
3. **Bilinçli yoksayma:** Yalnızca beklenen ve kullanıcı sonucunu bozmayan
   fallback/teardown durumlarında kullanılır; gerekçe `catch` bloğunda yazılır.

## Mevcut kararlar

| Alan | Karar | Gerekçe |
|---|---|---|
| Koleksiyon paylaşımı, sıralama ve üyelik | Kullanıcı mesajı + `reportError` | Kullanıcının istediği yazma işlemi tamamlanmamıştır. |
| Yinelenen kayıt temizliği | Toplu sonuç mesajı + her başarısız grup için `reportError` | Kısmi başarı kullanıcıya gösterilir; hangi grubun neden başarısız olduğu gözlemlenir. |
| Öneri kaynakları | Kısmi/boş sonuç + `reportError` | Bir kaynak çökünce diğer öneriler kullanılabilir, fakat üretim hatası sessiz kalmaz. |
| İlişki ağı kişi araması ve PNG üretimi | Mevcut boş/başarısız UI sonucu + `reportError` | Arama veya dışa aktarma hatası kullanıcı akışını etkiler. |
| Uygulama ayarları, güvenli API anahtarı ve web koleksiyon deposu | Bellekte fallback + `reportError` | Uygulama açılabilir kalır; kalıcılık kaybı üretimde izlenir. |
| Bozuk ilişki ağı kredi önbelleği | Cache miss + `reportError` | Ağdan yeniden yükleme mümkündür; bozuk veri kaydı görünür kalır. |
| Widget `dispose` sırasında dinamik arka plan temizliği | Bilinçli yoksayma | Riverpod teardown yarışı yalnızca kozmetik temizliği etkiler. |
| Firebase web plugin tekrar kaydı | Bilinçli yoksayma | Başlangıç ve retry aynı idempotent kaydı çağırabilir. |
| TMDb movie→TV ve çevrimdışı kredi fallback'leri | Bilinçli yoksayma | İlk denemenin başarısızlığı alternatif veri yolunu seçen normal kontrol akışıdır. |
| Repository/TMDb alt katmanında loglayıp yeniden fırlatılan hatalar | Üst katmana aktarım | Kullanıcı mesajı veya merkezi raporlama, işlemin sahibi olan üst sınırda yapılır; çift rapor üretilmez. |

`reportError` bağlam etiketleri kullanıcı adı, e-posta, izleme notu veya API
anahtarı içermez. URL ve exception metinlerindeki anahtar benzeri sorgu
parametreleri gönderilmeden önce `redactSecrets` ile temizlenir.

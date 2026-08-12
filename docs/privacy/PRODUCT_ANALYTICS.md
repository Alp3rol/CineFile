# Ürün analitiği sözleşmesi

Ürün analitiği varsayılan olarak kapalıdır. Kullanıcı Gizlilik Merkezi'nden açık
izin vermedikçe olay toplanmaz. Geliştirme ve test sürümleri, izin açık görünse
bile üretim analitiğine olay göndermez.

## İzin verilen özel olaylar

| Olay | Anlamı |
|---|---|
| `onboarding_completed` | Onboarding tamamlandı |
| `first_watch_recorded` | Cihazdaki ilk izleme kaydı oluşturuldu |
| `search_result_opened` | Arama sonucundan detay açıldı |
| `detail_watch_recorded` | Detay ekranından izleme kaydı oluşturuldu |
| `first_collection_created` | Cihazdaki ilk koleksiyon oluşturuldu |
| `wrapped_viewed` | Wrapped görüntülendi |
| `wrapped_shared` | Wrapped paylaşma eylemi tamamlandı |

Olaylara parametre eklenmez. Yapım adı, TMDb kimliği, arama metni, not, yorum,
puan, kullanıcı kimliği ve serbest metin kesinlikle gönderilmez. Yeni olay veya
parametre yalnızca bu sözleşme ve otomatik test birlikte güncellenerek eklenir.

Ölçüm açıkken Firebase Analytics ayrıca `first_visit`, `page_view` ve
`session_start` gibi standart, içeriksiz platform olayları üretebilir. Bunlar
CineFile'ın özel ürün olayları değildir ve kişisel günlük içeriği eklenmez.

Gerçek dönüşüm ve 7/30 günlük geri dönüş raporları, yeterli gerçek kullanıcı
trafiği oluşana kadar hazırlanmaz.

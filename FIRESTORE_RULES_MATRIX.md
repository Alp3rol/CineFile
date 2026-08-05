# Firestore Yazma İzin Matrisi

Bu tablo `firestore.rules` için istemciden yapılabilen create/update/delete
işlemlerinin beklenen sözleşmesidir. `test_rules/rules.test.mjs` her satırın izin
verilen ve reddedilen taraflarını Firestore emulatoründe doğrular.

| Koleksiyon | Create | Update | Delete |
|---|---|---|---|
| `users/{uid}` | Yalnız hesap sahibi, kendine ait alınmış kullanıcı adıyla | Profil alanları yalnız sahibi; takip sayaçları yalnız eşleşen takip batch'iyle | İstemciden yasak |
| `users/{uid}/movie_settings/*` | Yalnız sahibi | Yalnız sahibi | Yalnız sahibi |
| `users/{uid}/graph_overrides/*` | Yalnız sahibi | Yalnız sahibi | Yalnız sahibi |
| `usernames/{name}` | Oturumdaki kullanıcının kendi UID kaydı | Yasak | Yalnız kaydın sahibi |
| `logs/{id}` | Yalnız yazar; kimlik alanları profile bağlı, sayaçlar sıfır | İçerik yalnız yazar; yıldız/yorum sayacı yalnız doğrulanmış atomik geçişle | Yalnız yazar |
| `logs/{id}/comments/{id}` | Kimlik profile bağlı ve üst sayaç aynı batch'te +1 | Yasak | Yalnız yazar ve üst sayaç aynı batch'te -1 |
| `posts/{id}` | Yalnız yazar; kimlik alanları profile bağlı, sayaçlar sıfır | İçerik yalnız yazar; yıldız/yorum sayacı yalnız doğrulanmış atomik geçişle | Yalnız yazar |
| `posts/{id}/comments/{id}` | Kimlik profile bağlı ve üst sayaç aynı batch'te +1 | Yasak | Yalnız yazar ve üst sayaç aynı batch'te -1 |
| `shared_collections/{id}` | Yalnız sahibi ve profile bağlı kimlikle | Yalnız sahibi; sahiplik devredilemez | Yalnız sahibi |
| `follows/{from}_{to}` | Yalnız takip eden; iki profil sayacı aynı batch'te değişir | Yasak | Yalnız takip eden; iki sayaç aynı batch'te azalır |

Genel varsayılan: tabloda açıkça izin verilmeyen yazma işlemleri reddedilir.

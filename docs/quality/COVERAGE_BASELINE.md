# CineFile coverage tabanı — 5 Ağustos 2026

Başarılı [CI çalışması](https://github.com/Alp3rol/CineFile/actions/runs/30970693139)
üzerinden ölçülen başlangıç değerleri:

| Kapsam | Karşılanan satır | Toplam satır | Oran | CI alt sınırı |
|---|---:|---:|---:|---:|
| Tüm uygulama | 9.601 | 18.947 | %50,67 | %50 |
| `domain` katmanı | 532 | 643 | %82,74 | %80 |

`tool/check_coverage.dart`, coverage testinden üretilen `coverage/lcov.info`
dosyasını okur ve iki sınırdan biri karşılanmazsa CI'ı başarısız kılar. Böylece
genel kapsam %50'nin, saf iş mantığı kapsamı da %80'in altına sessizce düşemez.

Yeni veya önemli ölçüde yenilenen domain kodunda dosya/değişiklik bazında en az
%80 kapsam hedeflenir. Toplu domain kapısı bunun taban korumasıdır; kod
incelemesinde yeni dosyanın kendi kapsamı ayrıca değerlendirilmelidir.

Taban değerleri yalnızca kasıtlı bir test stratejisi değişikliğinde, yeni CI
raporunun kanıtı ve yol haritası notuyla birlikte güncellenmelidir.

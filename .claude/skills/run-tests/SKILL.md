---
name: run-tests
description: Kullanıcı testleri çalıştırmak ya da geçip geçmediğini görmek istediğinde kullan.
allowed-tools: Bash(.claude/skills/run-tests/run-tests.sh*)
---

# Testleri çalıştır

Testleri kendin sayma; sayıları script verir.

## Adımlar
1. Mod seç: Kullanıcı UI testlerini de istiyorsa `all`, aksi halde `unit`.
2. Script'i repo kökünden, Bash `timeout: 600000` ile çalıştır:
   `.claude/skills/run-tests/run-tests.sh unit` ya da `.claude/skills/run-tests/run-tests.sh all`
3. Script'in çıktısını bir kod bloğu içinde OLDUĞU GİBİ göster. Yorum, özet ya da ek açıklama katma.
4. Sonuç KALDI ise ve kullanıcı isterse: "Log:" satırındaki dosyada başarısız testin adını ara, hata mesajını bul ve çıktının altına ekle.

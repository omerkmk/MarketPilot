---
name: ios-review
description: MarketPilot'taki ViewModel ve ViewController dosyalarını projenin MVVM kurallarına göre denetler. Kullanıcı bir ViewModel'i ya da ViewController'ı review etmek, MVVM kurallarına uyulup uyulmadığını ya da bir VC'nin manager'larla doğrudan konuşup konuşmadığını kontrol etmek istediğinde kullan. Test dosyaları, README ya da commit mesajları için kullanma.
---

# iOS MVVM review

Bu skill sadece okur ve raporlar. Dosyalarda değişiklik yapma; düzeltme önerilerini rapora yaz.

## Adımlar
1. Review edilecek dosyayı ve referans olarak `MarketPilot/Features/Products/List/ProductListViewModel.swift` dosyasını oku.
2. Aşağıdaki kontrol listesini sırayla uygula.
3. Raporu aşağıdaki formatta ver.

## ViewModel kontrolleri
- `@MainActor final class` olarak tanımlı.
- Sadece `Foundation` import ediyor; `UIKit` import etmiyor, `UIView`, `UIColor`, `UIImage` gibi tipler tutmuyor.
- Bağımlılıklar `init` ile ve protokol tipinde alınıyor (ör. `CartManagerProtocol`).
- Durum `private(set)`; yalnızca private bir `update…` metoduyla değişiyor ve o metot ilgili `on…Changed` closure'ını çağırıyor.
- VC'ye bildirim closure ile yapılıyor; Combine ya da RxSwift kullanılmıyor.
- Tek doğru kaynak: Her aksiyondan sonra durum manager'dan yeniden okunuyor; `quantity + 1` gibi yerel bir hesap yok.
- Her kullanıcı aksiyonu durumu güncelleyen metodu çağırıyor, unutulan yok.
- Aynı kural iki yerde yazılmamış (DRY); ör. "adet → durum" çevirisi tek bir fonksiyonda.
- Navigasyon yapmıyor; ekran açma işi AppCoordinator'ın.

## ViewController kontrolleri
- Manager'ları (`CartManager`, `FavoriteManager`) doğrudan çağırmıyor; kullanıcı aksiyonlarını ViewModel'e iletiyor.
- "Ne gösterilecek" kararını kendisi vermiyor; ViewModel'in durumunu çiziyor.
- Başka bir ekranı kendisi açmıyor; coordinator'a closure ile bildiriyor.

## Rapor formatı
- Her bulgu için: `dosya:satır` · ihlal edilen kural · neden sorun · önerilen düzeltme.
- Sonra uyulan kuralların kısa bir listesi.
- Bulgu yoksa "Bulgu yok" yaz; bulgu uydurma.
- Cart ve Favorites ekranları henüz MVVM'e taşınmadı. Onları review ederken bu durumu hata olarak değil, "bilinen borç" olarak işaretle.

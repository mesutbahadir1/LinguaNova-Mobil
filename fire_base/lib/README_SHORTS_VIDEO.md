# Shorts Video Screen - YouTube Shorts/Instagram Reels Benzeri Video Player

Bu dosya, LinguaNova uygulamasına eklenen yeni Shorts video player özelliğini açıklar.

## Özellikler

### 🎥 Tam Ekran Video Deneyimi
- **Dikey Tasarım**: Instagram Reels ve YouTube Shorts benzeri tam ekran deneyim
- **Otomatik Oynatma**: Video yüklendiğinde otomatik başlar
- **Döngü**: Video bittiğinde otomatik olarak baştan başlar
- **Portrait Lock**: Ekran sadece dikey modda kilitli

### 🎮 Minimal Kontroller
- **Play/Pause**: Ekrana dokunarak video durdurulabilir/devam ettirilebilir
- **İleri/Geri YOK**: Video scrubbing mümkün değil (Shorts benzeri)
- **Otomatik Gizlenen Kontroller**: 3 saniye sonra kontroller otomatik gizlenir

### 🎯 Quiz Entegrasyonu
- **Alt Buton**: Ekranın altında her zaman görünür "Take Quiz" butonu
- **Kolay Erişim**: Video izleme deneyimini bozmadan quiz'e erişim

## Dosya Yapısı

```
ui/views/quiz/
├── shorts_video_screen.dart     # Yeni tam ekran video player
├── content_detail_screen.dart   # Güncellenmiş - video için yönlendirme
└── quiz_flow_screen.dart       # Quiz akışı (değişmedi)
```

## Teknik Detaylar

### Kullanılan Paketler
- `youtube_player_flutter`: YouTube video oynatma
- `flutter/services`: Orientation kontrolü
- `flutter/material`: UI bileşenleri

### Önemli Metodlar

#### `_initializePlayer()`
- YouTube URL'den video ID çıkarır
- YoutubePlayerController'ı yapılandırır
- Auto-play ve loop özelliklerini aktif eder

#### `_showHideControls()`
- Kontrolleri gösterir/gizler
- 3 saniye sonra otomatik gizleme
- Dokunmatik geri bildirim

#### `_navigateToQuiz()`
- Quiz ekranına yönlendirme
- Video bilgilerini taşır

### UI Katmanları

1. **Video Layer**: Tam ekran YouTube player
2. **Control Layer**: Play/pause kontrolleri (şartlı görünür)
3. **Top Layer**: Geri butonu ve başlık (şartlı görünür)
4. **Bottom Layer**: Take Quiz butonu (her zaman görünür)

## Kullanım

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ShortsVideoScreen(
      itemId: 123,
      title: "Video Başlığı",
      videoUrl: "https://youtube.com/watch?v=...",
    ),
  ),
);
```

## Entegrasyon

`ContentDetailScreen` artık video tipinde (`type == 2`) otomatik olarak `ShortsVideoScreen`'e yönlendirme yapar:

```dart
// content_detail_screen.dart içinde
if (widget.type == 2 && widget.content.isNotEmpty) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShortsVideoScreen(
          itemId: widget.itemId,
          title: widget.title,
          videoUrl: widget.content,
        ),
      ),
    );
  });
  return;
}
```

## Tasarım Hedefleri

✅ **Tam Ekran Deneyim**: Shorts/Reels benzeri immersive deneyim  
✅ **Minimal Kontroller**: Sadece gerekli kontroller  
✅ **Kolay Quiz Erişimi**: Alt bölümde her zaman erişilebilir  
✅ **Otomatik Döngü**: Video bittiğinde tekrar başlama  
✅ **Dokunmatik Kontrol**: Basit tap ile play/pause  

## Gelecek Geliştirmeler

- [ ] Video kalitesi seçenekleri
- [ ] Ses seviyesi kontrolü  
- [ ] Video paylaşma özelliği
- [ ] Yorum sistemi
- [ ] Beğeni/dislike sistemi 
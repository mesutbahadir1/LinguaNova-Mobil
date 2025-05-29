import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'quiz_flow_screen.dart';

class ShortsVideoScreen extends StatefulWidget {
  final int itemId;
  final String title;
  final String videoUrl;

  const ShortsVideoScreen({
    super.key,
    required this.itemId,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<ShortsVideoScreen> createState() => _ShortsVideoScreenState();
}

class _ShortsVideoScreenState extends State<ShortsVideoScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Portrait mode için ekranı kilitle
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl.trim());
      
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true, // Shorts benzeri otomatik başlat
            mute: false,
            loop: true, // Video bittiğinde tekrar başlat
            forceHD: false,
            enableCaption: false,
            captionLanguage: 'en',
            hideControls: false, // Kendi kontrol panelimizi yapalım
            controlsVisibleAtStart: false,
            startAt: 0,
          ),
        );
      } else {
        // Direkt ID olabilir
        String possibleId = widget.videoUrl.trim();
        if (!possibleId.contains('youtube.com') && !possibleId.contains('youtu.be')) {
          _controller = YoutubePlayerController(
            initialVideoId: possibleId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              loop: true,
              forceHD: false,
              enableCaption: false,
              hideControls: false,
              controlsVisibleAtStart: false,
              startAt: 0,
            ),
          );
        }
      }

      // Player event listeners
      _controller?.addListener(_playerListener);
    } catch (e) {
      print("Video player initialization error: $e");
    }
  }

  void _playerListener() {
    if (_controller != null && mounted) {
      setState(() {
        _isPlayerReady = _controller!.value.isReady;
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizFlowScreen(
          itemId: widget.itemId,
          type: 2, // Video type
          contentTitle: widget.title,
        ),
      ),
    );
  }

  void _showHideControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    // 3 saniye sonra kontrolleri otomatik gizle
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    // Orientation lock'u kaldır
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Ana video player - merkez ve uygun boyutta
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: _controller != null
                    ? AspectRatio(
                        aspectRatio: 16 / 9, // Standard video ratio
                        child: YoutubePlayer(
                          controller: _controller!,
                          showVideoProgressIndicator: false,
                          aspectRatio: 16 / 9,
                          onReady: () {
                            setState(() {
                              _isPlayerReady = true;
                            });
                          },
                          onEnded: (YoutubeMetaData metaData) {
                            // Video bittiğinde baştan başlat (loop için)
                            _controller!.seekTo(Duration.zero);
                            _controller!.play();
                          },
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white54,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Video yüklenemiyor",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Video üzerine dokunmatik alan - tam ekran
            Positioned.fill(
              child: GestureDetector(
                onTap: _showHideControls,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // Loading indicator
            if (!_isPlayerReady && _controller != null)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),

            // Üst kısım - geri butonu ve başlık
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Merkez play/pause butonu - video üzerinde
            if (_showControls)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Alt kısım - Take Quiz butonu - her zaman en altta
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video control info - sadece kontroller görünürken
                    if (_showControls)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Pause/resume by tapping",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Take Quiz butonu - her zaman görünür ve en altta
                    GestureDetector(
                      onTap: _navigateToQuiz,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade700,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.quiz,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Take Quiz",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Alt güvenlik alanı
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
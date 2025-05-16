// Implementation of the content detail screen that integrates with the new quiz flow
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/io_client.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../../app/constants/app_config.dart';
import '../../../models/content_models.dart';
import 'quiz_flow_screen.dart';

class ContentDetailScreen extends StatefulWidget {
  final int itemId;
  final int type; // 1 = Article, 2 = Video, 3 = Audio
  final String title;
  final String content; // Article text, video URL, or audio URL

  const ContentDetailScreen({
    super.key,
    required this.itemId,
    required this.type,
    required this.title,
    required this.content,
  });

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  // For video player
  YoutubePlayerController? _videoController;

  // For audio player
  AudioPlayer? _audioPlayer;
  bool isPlaying = false;
  double _sliderValue = 0.0;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Initialize video player if this is a video
    if (widget.type == 2 && widget.content.isNotEmpty) {
      _initializeVideoPlayer();
    }

    // Initialize audio player if this is audio
    if (widget.type == 3 && widget.content.isNotEmpty) {
      _setupAudio();
    }
  }

  void _initializeVideoPlayer() {
    try {
      // Try to extract videoId directly from URL
      final videoId = YoutubePlayer.convertUrlToId(widget.content.trim());
      print("Attempting to extract video ID from: ${widget.content.trim()}");

      if (videoId != null) {
        print("Successfully extracted video ID: $videoId");
        _videoController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      } else {
        // Fallback: Handle URLs with additional parameters or try direct ID
        String possibleId = widget.content.trim();
        // Check if content looks like an ID rather than a URL
        if (!possibleId.contains('youtube.com') && !possibleId.contains('youtu.be')) {
          print("Content might be a direct ID: $possibleId");
          _videoController = YoutubePlayerController(
            initialVideoId: possibleId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        } else {
          print("Could not extract YouTube video ID from URL: ${widget.content}");
        }
      }
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  Future<void> _setupAudio() async {
    try {
      _audioPlayer = AudioPlayer();

      // Initialize audio session
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech());

      String cleanAudioUrl = widget.content.trim();
      print("Attempting to load audio from URL: $cleanAudioUrl");

      // Set audio source
      await _audioPlayer!.setUrl(cleanAudioUrl);

      // Get total duration
      _totalDuration = await _audioPlayer!.duration ?? Duration.zero;
      if (_totalDuration == Duration.zero) {
        _totalDuration = (await _audioPlayer!.load()) ?? Duration.zero;
      }
      print("Loaded audio duration: $_totalDuration");

      // Listen to position stream
      _audioPlayer!.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _sliderValue = position.inSeconds.toDouble();
          });
        }
      });

      // Listen to player state changes
      _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print("Could not load audio: $e");
    }
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer?.pause();
    } else {
      _audioPlayer?.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizFlowScreen(
          itemId: widget.itemId,
          type: widget.type,
          contentTitle: widget.title,
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
          floating: false,
          pinned: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Hero image with gradient overlay
                CachedNetworkImage(
                  imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g8.png",
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color.fromRGBO(31, 31, 57, 0.7),
                        const Color.fromRGBO(31, 31, 57, 1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with subtle decoration
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.purple.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                // Article metadata
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.article_outlined, color: Colors.white70, size: 12),
                            SizedBox(width: 5),
                            Text(
                              "Article",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.white70, size: 12),
                            SizedBox(width: 5),
                            Text(
                              "5 min read",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Article content in styled container with better typography
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(47, 47, 66, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SelectableText(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Take Quiz button with improved styling
                GestureDetector(
                  onTap: _navigateToQuiz,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade500, Colors.purple.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Take Quiz",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent() {
    if (_videoController == null) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text("Video yüklenirken bir sorun oluştu",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              Text("URL: ${widget.content}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 30),
              _buildCompleteButton(),
            ],
          )
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Video card with shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade700, Colors.purple.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: YoutubePlayer(
                      controller: _videoController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.white,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.purple,
                        handleColor: Colors.purpleAccent,
                      ),
                      onEnded: (metaData) {
                        print("Video ended");
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Video info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(47, 47, 66, 1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Video metadata
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.videocam, color: Colors.white70, size: 14),
                            SizedBox(width: 5),
                            Text(
                              "Video Lesson",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Video description
                  const Text(
                    "",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Quiz button with improved styling
            GestureDetector(
              onTap: _navigateToQuiz,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade500, Colors.purple.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.quiz, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Take Quiz",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioContent() {
    if (_audioPlayer == null) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text("Ses dosyası yüklenirken bir sorun oluştu",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              Text("URL: ${widget.content}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 30),
              _buildCompleteButton(),
            ],
          )
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Audio visualization and player area
          Container(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromRGBO(47, 47, 66, 1),
                  const Color.fromRGBO(31, 31, 57, 1),
                ],
              ),
            ),
            child: Column(
              children: [
                // Album artwork with reflection effect
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Shadow/reflection for 3D effect
                    Container(
                      margin: const EdgeInsets.only(top: 260, left: 20, right: 20),
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          radius: 0.5,
                        ),
                      ),
                    ),
                    // Album artwork
                    Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.shade800,
                                Colors.blue.shade900,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Image 
                              CachedNetworkImage(
                                imageUrl: "https://source.unsplash.com/300x300/?music",
                                fit: BoxFit.cover,
                                height: 260,
                                width: 260,
                              ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                              // Title on the artwork
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(0, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Audio type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.headphones, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Audio Lesson",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Progress bar with animated colors
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StreamBuilder<Duration>(
                    stream: _audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return Column(
                        children: [
                          // Time indicators
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  _formatDuration(_totalDuration),
                                  style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Custom slider
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 8,
                              activeTrackColor: Colors.purpleAccent,
                              inactiveTrackColor: Colors.grey.shade800,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayColor: Colors.purpleAccent.withOpacity(0.3),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                            ),
                            child: Slider(
                              value: _sliderValue.clamp(0, _totalDuration.inSeconds.toDouble()),
                              max: _totalDuration.inSeconds.toDouble(),
                              min: 0,
                              onChanged: (value) {
                                _audioPlayer!.seek(Duration(seconds: value.toInt()));
                                setState(() {
                                  _sliderValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Play/Pause button with better styling
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 70,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ],
            ),
          ),
          
          // Audio description and quiz button section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Take Quiz button with neon-like glow
                GestureDetector(
                  onTap: _navigateToQuiz,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade500, Colors.purple.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Take Quiz",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildCompleteButton() {
    return ElevatedButton(
      onPressed: _navigateToQuiz,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Take Quiz",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _getContentTypeTitle(),
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContentBasedOnType(),
    );
  }

  String _getContentTypeTitle() {
    switch (widget.type) {
      case 1:
        return "Article";
      case 2:
        return "Video";
      case 3:
        return "Audio";
      default:
        return "Content";
    }
  }

  Widget _buildContentBasedOnType() {
    switch (widget.type) {
      case 1:
        return _buildArticleContent();
      case 2:
        return _buildVideoContent();
      case 3:
        return _buildAudioContent();
      default:
        return const Center(child: Text("Unknown content type", style: TextStyle(color: Colors.white)));
    }
  }
}
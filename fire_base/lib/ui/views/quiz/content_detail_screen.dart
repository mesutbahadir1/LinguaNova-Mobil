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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Article image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g8.png",
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 16),
          // Article content
          Text(
            widget.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildCompleteButton(),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // Video player area with nice styling similar to VideoDetailScreen
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.purple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: YoutubePlayer(
                controller: _videoController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.white,
                onEnded: (metaData) {
                  print("Video ended");
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),
          // Using modern done button like in VideoDetailScreen
          GestureDetector(
            onTap: _navigateToQuiz,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 200,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Colors.purple.shade500, Colors.purple.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Take Quiz",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    if (_audioPlayer == null) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album artwork similar to AudioDetailScreen
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
              image: const DecorationImage(
                image: NetworkImage("https://source.unsplash.com/300x300/?music"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Title
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Audio Lesson",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          StreamBuilder<Duration>(
            stream: _audioPlayer!.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              return Column(
                children: [
                  Slider(
                    value: _sliderValue.clamp(0, _totalDuration.inSeconds.toDouble()),
                    max: _totalDuration.inSeconds.toDouble(),
                    min: 0,
                    activeColor: Colors.greenAccent,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      _audioPlayer!.seek(Duration(seconds: value.toInt()));
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          _formatDuration(_totalDuration),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Play/Pause button
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 80,
              color: Colors.greenAccent,
            ),
            onPressed: _togglePlayPause,
          ),

          const Spacer(),

          // Take Quiz Button - similar to AudioDetailScreen but branded for quiz
          ElevatedButton(
            onPressed: _navigateToQuiz,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  "Take Quiz",
                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
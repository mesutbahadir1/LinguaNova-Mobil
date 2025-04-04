import 'package:fire_base/ui/views/program/audio/audio_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../../exercise/exercise_screen.dart';

class AudioDetailScreen extends StatefulWidget {
  final AudioItem item;

  const AudioDetailScreen({super.key, required this.item});


  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  double _sliderValue = 0.0;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    _audioPlayer = AudioPlayer();

    // Ses oturumunu başlat
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    try {
      await _audioPlayer.setUrl(widget.item.url);

      // Sesin toplam süresini alıyoruz
      _totalDuration = (await _audioPlayer.load())!;

      // Pozisyon stream'ini dinliyoruz
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _sliderValue = position.inSeconds.toDouble();
        });
      });
    } catch (e) {
      print("Ses çalınamadı: $e");
    }
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Now Playing",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Albüm kapağı gibi görsel
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
                image: const DecorationImage(
                  image: NetworkImage("https://source.unsplash.com/300x300/?music"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Başlık ve açıklama
            const Text(
              "Handmade Podcast",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Playing from Libsyn",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Progress Bar
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                // Fallback to Duration.zero if the snapshot is null
                final position = snapshot.data ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: _sliderValue,
                      max: _totalDuration.inSeconds.toDouble(),
                      min: 0,
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.grey,
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                    ),
                    Row(
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
                  ],
                );
              },
            ),
            // Play / Pause Butonu
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 80,
                color: Colors.greenAccent,
              ),
              onPressed: _togglePlayPause,
            ),

            const Spacer(),

            // Done Butonu
            ElevatedButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseScreen(itemId: widget.item.id,type: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

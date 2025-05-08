import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fire_base/ui/views/program/video/video_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/constants/app_config.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<VideoItem> videoList = [];

  int? userId;
  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchVideos();
  }
  void _loadUserIdAndFetchVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('userId');

    if (id != null) {
      setState(() {
        userId = id;
      });
      fetchVideos();
    }
  }

  Future<void> fetchVideos() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {

      final levelResponse = await ioClient.get(
        Uri.parse('${HTTPS_URL}/api/User/level/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (levelResponse.statusCode == 200) {
        int level = int.parse(levelResponse.body);

        final response = await ioClient.get(
          Uri.parse('${HTTPS_URL}/api/UserVideoProgress/GetVideosByUserAndLevel?userId=${userId}&level=${level}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            videoList = data.map((item) => VideoItem.fromJson(item)).toList();
          });
        } else {
          throw Exception('Failed to load videos');
        }
      }else {
        throw Exception('Failed to load id');
      }


    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Videos",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: videoList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: videoList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = videoList[index];
            return VideoCard(item: item);
          },
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoItem item;

  const VideoCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(47, 47, 66, 1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: const Color(0xFFD3D3D3),
            width: 0.7,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(item.isCompleted ? 0 : 12.0),
                topRight: Radius.circular(item.isCompleted ? 0 : 12.0),
              ),
              child: CachedNetworkImage(
                imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g2.png",
                height: MediaQuery.of(context).size.height * 0.11,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: AutoSizeText(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoItem {
  final int id;
  final String title;
  final String videoUrl;
  final bool isCompleted;

  VideoItem({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.isCompleted,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'],
      title: json['title'],
      videoUrl: json['url'],
      isCompleted: json['isCompleted'],
    );
  }
}

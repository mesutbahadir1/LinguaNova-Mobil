import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/constants/app_config.dart';
import '../../../models/content_models.dart';
import 'content_detail_screen.dart';

class ContentListScreen extends StatefulWidget {
  final int type; // 1 = Article, 2 = Video, 3 = Audio

  const ContentListScreen({
    super.key,
    required this.type,
  });

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  
  // Tür bazlı olarak kullanılacak listeler
  List<ArticleProgressDto> articles = [];
  List<VideoProgressDto> videos = [];
  List<AudioProgressDto> audios = [];
  
  int? userId;
  int? userLevel;

  @override
  void initState() {
    super.initState();
    print('ContentListScreen(type: ${widget.type}): initState called');
    _loadUserIdAndFetchContent();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ContentListScreen(type: ${widget.type}): didChangeDependencies called');
    
    // Her zaman yeniden yükle
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      _loadUserIdAndFetchContent();
    }
  }
  
  // Sayfalar arası geçişlerde de tetiklenebilmesi için
  @override
  void didUpdateWidget(ContentListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('ContentListScreen(type: ${widget.type}): didUpdateWidget called');
    
    // Eğer widget tipi değiştiyse veya eski ve yeni widget farklıysa içeriği yeniden yükle
    if (oldWidget.type != widget.type) {
      setState(() {
        isLoading = true;
      });
      _loadUserIdAndFetchContent();
    }
  }

  void _loadUserIdAndFetchContent() async {
    print('ContentListScreen(type: ${widget.type}): Loading content...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('userId');
    int? storedLevel = prefs.getInt('userLevel');

    if (id != null) {
      print('ContentListScreen(type: ${widget.type}): User ID: $id, stored level: $storedLevel');
      setState(() {
        userId = id;
        // First try to use stored level if available
        if (storedLevel != null) {
          userLevel = storedLevel;
        }
      });
      
      // Always fetch the latest level
      await _getUserLevel(id);
      
      // Then fetch content with the updated level
      await fetchContent(id);
      print('ContentListScreen(type: ${widget.type}): Content loading completed. Level: $userLevel');
    } else {
      print('ContentListScreen(type: ${widget.type}): No user ID found');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _getUserLevel(int userId) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {
      final response = await ioClient.get(
        Uri.parse('${HTTPS_URL}/api/User/level/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        int level = int.parse(response.body.trim());
        
        // Store the level in shared preferences for future use
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userLevel', level);
        
        setState(() {
          userLevel = level;
        });
        print('User level: $level');
      } else {
        print('Failed to fetch user level: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user level: $e');
    }
  }

  Future<void> fetchContent(int userId) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {
      if (userLevel == null) {
        print('User level is not available, retrying level fetch...');
        await _getUserLevel(userId);
        
        // If still null after retry, show error and try to get from cache
        if (userLevel == null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int? cachedLevel = prefs.getInt('userLevel');
          
          if (cachedLevel != null) {
            setState(() {
              userLevel = cachedLevel;
            });
            print('Using cached level: $cachedLevel');
          } else {
            setState(() {
              isLoading = false;
            });
            print('Could not retrieve user level');
            return;
          }
        }
      }

      // İçerik tipine göre farklı URL kullanıyoruz
      String url = '';
      switch (widget.type) {
        case 1: // Article
          url = '${HTTPS_URL}/api/UserArticleProgress/GetArticlesByUserAndLevel?userId=$userId&level=$userLevel';
          break;
        case 2: // Video
          url = '${HTTPS_URL}/api/UserVideoProgress/GetVideosByUserAndLevel?userId=$userId&level=$userLevel';
          break;
        case 3: // Audio
          url = '${HTTPS_URL}/api/UserAudioProgress/GetAudiosByUserAndLevel?userId=$userId&level=$userLevel';
          break;
        default:
          throw Exception("Invalid content type");
      }

      print('Fetching content from URL: $url');
      final response = await ioClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Content response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Save successful response timestamp
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastSuccessfulFetch_type${widget.type}', DateTime.now().millisecondsSinceEpoch);
        
        List<dynamic> data = json.decode(response.body);
        
        print('Content type: ${widget.type}, Found ${data.length} items');
        if (data.isNotEmpty) {
          print('First item in response: ${data[0]}');
        } else {
          print('No items found in response');
        }
        
        setState(() {
          switch (widget.type) {
            case 1: // Article
              articles = data.map((item) => ArticleProgressDto.fromJson(item)).toList();
              print('Parsed ${articles.length} articles');
              break;
              
            case 2: // Video
              videos = data.map((item) => VideoProgressDto.fromJson(item)).toList();
              if (videos.isNotEmpty) {
                print('Parsed ${videos.length} videos. First video URL: ${videos[0].url}');
              } else {
                print('No videos parsed');
              }
              break;
              
            case 3: // Audio
              audios = data.map((item) => AudioProgressDto.fromJson(item)).toList();
              if (audios.isNotEmpty) {
                print('Parsed ${audios.length} audio items. First audio URL: ${audios[0].url}');
              } else {
                print('No audio items parsed');
              }
              break;
          }
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        print('No content found: ${response.body}');
        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to fetch content: ${response.statusCode}, ${response.body}');
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load content for type ${widget.type}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToContentDetail(int itemId, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentDetailScreen(
          itemId: itemId,
          type: widget.type,
          title: title,
          content: content,
        ),
      ),
    ).then((_) {
      // Refresh list when returning
      setState(() {
        isLoading = true;
      });
      _loadUserIdAndFetchContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _getContentTypeTitle(),
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _getContentCount() == 0
              ? Center(
                  child: Text(
                    "No content available for level ${userLevel ?? 'unknown'}",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : _buildContentBasedOnType(),
    );
  }
  
  int _getContentCount() {
    switch (widget.type) {
      case 1: return articles.length;
      case 2: return videos.length;
      case 3: return audios.length;
      default: return 0;
    }
  }

  String _getContentTypeTitle() {
    switch (widget.type) {
      case 1:
        return "Articles";
      case 2:
        return "Videos";
      case 3:
        return "Audio Lessons";
      default:
        return "Content";
    }
  }

  Widget _buildContentBasedOnType() {
    switch (widget.type) {
      case 1:
        return _buildArticleGrid();
      case 2:
        return _buildVideoList();
      case 3:
        return _buildAudioList();
      default:
        return Center(child: Text("Unknown content type", style: TextStyle(color: Colors.white)));
    }
  }

  // Article Grid Layout (similar to KnowledgeScreen)
  Widget _buildArticleGrid() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return GestureDetector(
          onTap: () => _navigateToContentDetail(
            article.id,
            article.title,
            article.content,
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(47, 47, 66, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFD3D3D3), width: 0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Article Design
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6B73FF),
                            Color(0xFF9B59B6),
                            Color(0xFF8E44AD),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ArticlePatternPainter(),
                            ),
                          ),
                          // Article icon and text
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.article_outlined,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Article",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Completed Badge
                    if (article.isCompleted)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Completed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // Content area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Bottom section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Article icon
                          Row(
                            children: [
                              Icon(
                                Icons.article_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Article",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          // Read button
                          ElevatedButton(
                            onPressed: () => _navigateToContentDetail(
                              article.id,
                              article.title,
                              article.content,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: article.isCompleted ? Colors.green : Colors.purple,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              article.isCompleted ? "Review" : "Read",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Video List Layout (similar to VideoScreen style but in list format)
  Widget _buildVideoList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () => _navigateToContentDetail(
            video.id,
            video.title,
            video.url,
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(47, 47, 66, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFD3D3D3), width: 0.7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Video Design
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B6B),
                            Color(0xFFFF8E53),
                            Color(0xFFFF5722),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: CustomPaint(
                              painter: VideoPatternPainter(),
                            ),
                          ),
                          // Play button and video elements
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Video",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (video.isCompleted)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Completed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // Video details
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Colors.white70,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Video",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _navigateToContentDetail(
                              video.id,
                              video.title,
                              video.url,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: video.isCompleted ? Colors.green : Colors.purple,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              video.isCompleted ? "Review" : "Watch",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Audio List Layout (similar to AudioScreen but with a different appearance)
  Widget _buildAudioList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];
        return GestureDetector(
          onTap: () => _navigateToContentDetail(
            audio.id,
            audio.title,
            audio.url,
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(47, 47, 66, 1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFD3D3D3), width: 0.7),
            ),
            child: Row(
              children: [
                // Audio thumbnail with headphone icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.headphones,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                // Audio details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: audio.isCompleted
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    audio.isCompleted ? Icons.check_circle : Icons.headphones,
                                    color: audio.isCompleted ? Colors.green : Colors.white70,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    audio.isCompleted ? "Completed" : "Audio",
                                    style: TextStyle(
                                      color: audio.isCompleted ? Colors.green : Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Listen button
                            ElevatedButton(
                              onPressed: () => _navigateToContentDetail(
                                audio.id,
                                audio.title,
                                audio.url,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: audio.isCompleted ? Colors.green : Colors.purple,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(80, 32),
                              ),
                              child: Text(
                                audio.isCompleted ? "Review" : "Listen",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom painters for background patterns
class ArticlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() + size.height, size.height),
        paint,
      );
    }

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (i + 1) / 6,
          size.height * (i + 1) / 6,
        ),
        20,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VideoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw squares
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (i + 1) / 5,
          size.height * (i + 1) / 5,
          30,
          30,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
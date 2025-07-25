import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/app/constants/app_config.dart';
import 'package:fire_base/auth/login.dart';
import 'package:fire_base/chatbot/generative_text_view.dart';
import 'package:fire_base/services/authService.dart';
import 'package:fire_base/ui/views/account/account_screen.dart';
import 'package:fire_base/ui/views/knowledge/knowledge_screen.dart';
import 'package:fire_base/ui/views/program/audio/audio_screen.dart';
import 'package:fire_base/ui/views/program/program_screen.dart';
import 'package:fire_base/ui/views/program/video/video_screen.dart';
import 'package:fire_base/ui/views/progress/progress_screen.dart';
import 'package:fire_base/ui/views/quiz/content_list_screen.dart';
import 'package:fire_base/widgets/bottom_bar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants/light_mode_colors.dart';
import '../auth/google_login/google_auth.dart';
import '../models/activity_model.dart';
import '../models/post_model.dart';
import '../models/user_progress_model.dart';
import '../provider/user_provider.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool isLoading = true;
  int totalCount=0;
  String userName = "User"; // Varsayılan değer
  int learnedCount=0;
  List<UserProgressModel> _activities = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<PostsModel> _posts = [
    PostsModel(
        id: 1,
        title: "Artificial Intelligence",
        image: 'assets/images/a1.jpeg'),
    PostsModel(
        id: 2,
        title: "Cyber Security",
        image: 'assets/images/a3.jpeg'),
    PostsModel(
        id: 3,
        title: "Full Stack Java",
        image: 'assets/images/a2.jpeg'),
  ];

  int? userId;
  @override
  void initState() {
    super.initState();
    _loadUserId();
    _checkForRefresh();
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });

    if (userId != null) {
      _fetchUserProgress(userId!);
      _fetchUserName(userId!);
    }
  }
  Future<void> _fetchUserName(int userId) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);
    try {
      final response = await http.get(
        Uri.parse('${HTTPS_URL}/api/User/username/${userId}'),
      );

      if (response.statusCode == 200) {
        print("Raw response: ${response.body}");

        var responseData = response.body;

        if (responseData.startsWith('"') && responseData.endsWith('"')) {
          responseData = responseData.substring(1, responseData.length - 1);
        }

        try {
          var jsonData = jsonDecode(responseData);
          if (jsonData is Map && jsonData.containsKey('value')) {
            responseData = jsonData['value'];
          } else if (jsonData is String) {
            responseData = jsonData;
          }
        } catch (e) {
          print("JSON parse error: $e");
        }

        print("Processed username: $responseData");

        setState(() {
          userName = responseData;
        });
      } else {
        print('Failed to load username: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> _fetchUserProgress(int userId) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${HTTPS_URL}/api/User/progress/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progressResponse = UserProgressResponse.fromJson(data);
        int calculatedTotalCount = progressResponse.audioProgress.totalActivityCount +
            progressResponse.articleProgress.totalActivityCount +
            progressResponse.videoProgress.totalActivityCount;

        int calculatedLearnedCount = progressResponse.audioProgress.completedActivityCount +
            progressResponse.articleProgress.completedActivityCount +
            progressResponse.videoProgress.completedActivityCount;

        setState(() {
          _activities = [
            progressResponse.audioProgress,
            progressResponse.articleProgress,
            progressResponse.videoProgress,
          ];
          totalCount = calculatedTotalCount;
          learnedCount = calculatedLearnedCount;
          isLoading = false;
        });
      } else {
        print('Failed to load progress data: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching progress data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

// Add this method to check if Home should refresh
  void _checkForRefresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastTab = prefs.getInt('lastContentTab');

    // If we're coming back to Home tab (index 0), refresh the data
    if (lastTab == 0) {
      print('Home: Refreshing data due to tab navigation');
      if (userId != null) {
        await _fetchUserProgress(userId!);
        await _fetchUserName(userId!);
      }
    }
  }

  // Modify your existing onIndexChanged callback in the build method:
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      bottomNavigationBar: BottomBarBuilder.buildBottomNavigationBar(
        context,
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // If navigating to Home tab, refresh the data
          if (index == 0 && userId != null) {
            _fetchUserProgress(userId!);
            _fetchUserName(userId!);
          }
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ContentListScreen(key: UniqueKey(), type: 1);
      case 2:
        return ContentListScreen(key: UniqueKey(), type: 3);
      case 3:
        return ContentListScreen(key: UniqueKey(), type: 2);
      case 4:
        return ChatView();
      default:
        return _buildHomeContent();
    }
  }

  // 1. _buildHomeContent içinde Consumer ekliyoruz:
  Widget _buildHomeContent() {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              height: 180,
              color: LightModeColors.HOME_HEADER_CONTAINER_COLOR,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to LinguaNova',
                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lets start learning',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountScreen(),
                          ),
                        );
                      },
                      child: SvgPicture.asset('assets/icons/avatar.svg', height: 48),
                    ),
                  ),
                ],
              ),
            ),
            // Buradan sonrası aynı kalıyor.
            Transform.translate(
              offset: const Offset(0, -55),
              child: _buildTotalLearnedContainer(context),
            ),
            Transform.translate(
              offset: const Offset(0, -35),
              child: _buildProgramCartContents(),
            ),
            Expanded(
              child: _buildActivityContents(context),
            ),
          ],
        );
  }


  Widget _buildTotalLearnedContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromRGBO(47, 47, 66, 1),
        border: Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learned total for this level',
                style: TextStyle(color: Color.fromRGBO(133, 133, 151, 1), fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                '${learnedCount}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                ' / ${totalCount} exercise',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                width: 300,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Positioned(
                left: 0,
                child: Container(
                  height: 7,
                  width: 300 * (learnedCount/totalCount), // Calculated as 300 * (46 / 60)
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orangeAccent.shade100,
                        Colors.orangeAccent.shade400,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCartContents() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: index == 0 ? 25 : 0),
            child: _postsListView(_posts[index]),
          );
        },
      ),
    );
  }

  Widget _buildActivityContents(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 150,
      decoration: BoxDecoration(
        color: Color.fromRGBO(47, 47, 66, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD3D3D3), width: 0.7),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _activities.isEmpty
          ? Center(
        child: Text(
          'No activity data available',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 0),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          // Determine content type based on title
          int contentType = 1; // Default to Article
          if (_activities[index].title.contains("Listening")) {
            contentType = 3;
          } else if (_activities[index].title.contains("Video")) {
            contentType = 2;
          }
          
          return GestureDetector(
            onTap: () {
              // Navigate to the ContentListScreen with the appropriate type
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContentListScreen(
                    type: contentType,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircularProgressIndicator(
                color: Colors.white,
                value: _activities[index].completedActivityCount /
                    _activities[index].totalActivityCount,
              ),
              title: Text(
                _activities[index].title,
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_activities[index].completedActivityCount}/${_activities[index].totalActivityCount}",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _postsListView(PostsModel post) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ContentListScreen with type 1 (Article)
        // You can modify this to choose different types based on your needs
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentListScreen(
              type: 1, // Article type
            ),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  post.image!,
                  height: 178,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _preloadUserLevel() async {
    if (userId == null) return;
    
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
        
        // Store level in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userLevel', level);
      }
    } catch (e) {
      print('Error preloading user level: $e');
    }
  }
}


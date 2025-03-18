import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/auth/login.dart';
import 'package:fire_base/chatbot/generative_text_view.dart';
import 'package:fire_base/services/authService.dart';
import 'package:fire_base/ui/views/knowledge/knowledge_screen.dart';
import 'package:fire_base/ui/views/program/program_screen.dart';
import 'package:fire_base/ui/views/progress/progress_screen.dart';
import 'package:fire_base/widgets/bottom_bar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app/constants/light_mode_colors.dart';
import '../auth/google_login/google_auth.dart';
import '../models/activity_model.dart';
import '../models/post_model.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bottom Navigation Bar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<PostsModel> _posts = [
    PostsModel(
        id: 1,
        title: "Artificial Intelligence",
        image: 'https://blog.lewolang.com/images/caa060e9d090a761b399310670dba684.jpg?w=400&h=300&fit=crop'),
    PostsModel(
        id: 2,
        title: "Cyber Security",
        image: 'https://expressenglish.ae/wp-content/uploads/2022/02/tips-improve-english.jpg'),
    PostsModel(
        id: 3,
        title: "Full Stack Java",
        image: 'https://media.istockphoto.com/id/1047570732/vector/english.jpg?s=612x612&w=0&k=20&c=zgafUJxCytevU-ZRlrZlTEpw3mLlS_HQTIOHLjaSPPM='),
  ];

  final List<ActivityModel> _activities = [
    ActivityModel(id: 1, title: "Listening Section", completedActivityCount: 12, totalActivityCount: 24),
    ActivityModel(id: 2, title: "Article Section", completedActivityCount: 30, totalActivityCount: 44),
    ActivityModel(id: 3, title: "Video Section", completedActivityCount: 5, totalActivityCount: 24),
  ];

  @override
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
        return const KnowledgeScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return const ProgramScreen();
      case 4:
        return ChatView();
      default:
        return _buildHomeContent();
    }
  }

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
                    'Hi, Mesut',
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
                child: GestureDetector(onTap: () {
                 AuthServices().signOut();
                },child: SvgPicture.asset('assets/icons/avatar.svg', height: 48)),
              ),
            ],
          ),
        ),
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
                'Learned today',
                style: TextStyle(color: Color.fromRGBO(133, 133, 151, 1), fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                '46 min',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                ' / 60min',
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
                  width: 230, // Calculated as 300 * (46 / 60)
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
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 0),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircularProgressIndicator(color: Colors.white,
              value: _activities[index].completedActivityCount / _activities[index].totalActivityCount,
            ),
            title: Text(
              _activities[index].title,
              style: TextStyle(fontSize: 15,color: Colors.white),
            ),
            trailing: Text(
              "${_activities[index].completedActivityCount}/${_activities[index].totalActivityCount}",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _postsListView(PostsModel post) {
    return Container(
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
            child: CachedNetworkImage(
              height: 178,
              width: double.infinity,
              fit: BoxFit.cover,
              imageUrl: post.image!,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

        ],
      ),
    );
  }
}


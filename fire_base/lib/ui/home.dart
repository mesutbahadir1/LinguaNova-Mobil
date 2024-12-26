import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/auth/login.dart';
import 'package:fire_base/services/authService.dart';
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
  bool loading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<PostsModel> _posts = [
    PostsModel(
        id: 1,
        title: "Artificial Intelligence",
        image: 'https://app.talentifylab.com/storage/instructors/384f0f43-e921-445b-a016-99660014dfc4/images/program_cover_image/resized/bCfllFp4MALfnt48NiODP4hsNYCK87v21AdqS1DF_resized.jpeg'),
    PostsModel(
        id: 2,
        title: "Cyber Security",
        image: 'https://app.talentifylab.com/storage/instructors/384f0f43-e921-445b-a016-99660014dfc4/images/program_cover_image/resized/bCfllFp4MALfnt48NiODP4hsNYCK87v21AdqS1DF_resized.jpeg'),
    PostsModel(
        id: 3,
        title: "Full Stack Java",
        image: 'https://app.talentifylab.com/storage/instructors/f6aa19b5-27fc-48b8-9bcc-3e192ed23a41/images/program_cover_image/resized/gg6eMIRmZ9goZoFlps4Hbdni11nsWbrznGL188fS_resized.jpeg'),
    PostsModel(
        id: 4,
        title: "SDET / QA Full Stack",
        image: 'https://talentifylab.com/_next/image?url=http%3A%2F%2Fapp.talentifylab.com%2Fstorage%2Finstructors%2Ff49b555d-fc92-4386-a7c3-eb6a70befdc2%2Fimages%2Fprogram_cover_image%2Fresized%2FWC84RIWk7k7D6NxUsHgoo9uXiA8lE8tkh102fp1g_resized.jpeg&w=750&q=75'),
  ];

  final List<ActivityModel> _activities = [
    ActivityModel(id: 1, title: "Listening Section", completedActivityCount: 12, totalActivityCount: 24),
    ActivityModel(id: 2, title: "Article Section", completedActivityCount: 30, totalActivityCount: 44),
    ActivityModel(id: 3, title: "Writing Section", completedActivityCount: 5, totalActivityCount: 24),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      bottomNavigationBar: BottomBarBuilder.buildBottomNavigationBar(context),
      body: Column(
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
                  child: SvgPicture.asset('assets/icons/avatar.svg', height: 48),
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
      ),
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

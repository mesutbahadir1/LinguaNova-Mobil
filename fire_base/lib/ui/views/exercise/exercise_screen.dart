import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/io_client.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/constants/app_config.dart';
import '../../../models/exercise_list_model.dart';
import 'exercise_question_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final int itemId;
  final int type; // 1 = Article, 2 = Video, 3 = Audio

  const ExerciseScreen({
    super.key,
    required this.itemId,
    required this.type,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ExerciseListModel> exerciseList = [];
  int? userId;
  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchExercise();
  }

  void _loadUserIdAndFetchExercise() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('userId');

    if (id != null) {
      setState(() {
        userId = id;
      });
      fetchExercises();
    }
  }

  Future<void> fetchExercises() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    String url = '';
    switch (widget.type) {
      case 1: // Article
        url = '${HTTPS_URL}/api/UserTestProgress/ArticleTests/${userId}/${widget.itemId}';
        break;
      case 2: // Video
        url = '${HTTPS_URL}/api/UserTestProgress/VideoTests/${userId}/${widget.itemId}';
        break;
      case 3: // Audio (şimdilik hazır değil)
         url = '${HTTPS_URL}/api/UserTestProgress/AudioTests/${userId}/${widget.itemId}';
         break;
      default:
        throw Exception("Invalid type provided");
    }

    final response = await ioClient.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        exerciseList = data.map((item) => ExerciseListModel.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load exercises for type ${widget.type}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Exercise List",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildExerciseContainer(),
      ),
    );
  }

  Widget _buildExerciseContainer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1,
      ),
      itemCount: exerciseList.length,
      itemBuilder: (context, index) {
        final ExerciseListModel entry = exerciseList[index];
        final bool isCompleted = entry.isCorrect;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseQuestionScreen(exercise: entry, type: widget.type,),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(47, 47, 66, 1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFD3D3D3),
                    width: 0.7,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g3.png",
                        height: MediaQuery.sizeOf(context).height * 0.11,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AutoSizeText(
                        "Questions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        minFontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          color: Colors.purple,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            "Multiple Answer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.0),
                        topLeft: Radius.circular(12.0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
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
                ),
            ],
          ),
        );
      },
    );
  }
}

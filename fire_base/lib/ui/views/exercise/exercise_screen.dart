import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/ui/views/exercise/exercise_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/exercise_list_model.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ExerciseListModel> exerciseList = [
    ExerciseListModel(
        id: 1,
        title: "Java Introduction",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g8.png",
        exerciseType: "Single Answer",
        isComplete: true),
    ExerciseListModel(
        id: 2,
        title: "Java Introduction",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g2.png",
        exerciseType: "Multiple Answer",
        isComplete: false),
    ExerciseListModel(
        id: 3,
        title: "Java Introduction",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g3.png",
        exerciseType: "Fill in the blank",
        isComplete: false),
    ExerciseListModel(
        id: 4,
        title: "Java Introduction",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g4.png",
        exerciseType: "True/False",
        isComplete: true),
  ];

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
        final bool isCompleted = entry.isComplete;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExerciseQuestionScreen(),
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
                        imageUrl: entry.imageUrl,
                        height: MediaQuery.sizeOf(context).height * 0.11,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AutoSizeText(
                        entry.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
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
                            entry.exerciseType,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                      borderRadius: BorderRadius.only(topRight: Radius.circular(12.0), topLeft: Radius.circular(12.0)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Center(
                      child: Text(
                        "Completed",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

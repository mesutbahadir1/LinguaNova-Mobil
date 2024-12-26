import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/ui/views/exercise/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/knowledge_library_model.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final int knowledgeId=1;

  const KnowledgeDetailScreen({super.key});

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  KnowledgeLibraryModel? knowledge;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.knowledgeId == 1) {
      knowledge = KnowledgeLibraryModel(
          id: widget.knowledgeId,
          title: "Agile Framework",
          imageUrl:
              "https://images.pexels.com/photos/1102909/pexels-photo-1102909.jpeg?cs=srgb&dl=pexels-jplenio-1102909.jpg&fm=jpg",
          knowledgeType: "Agile Project Management",
          contents: [
            "Choosing the right project management methodology is essential. This allows you to organize your work, standardize tasks and processes, organize time, estimate costs, and minimize risks. The right methodology helps you to be more efficient.",
            "Our platform goes beyond simply delivering content. It embraces the power of technology to provide personalized learning paths, adaptive assessments, and collaborative tools.",
            "Experience dynamic learning with live & video lessons, quizzes, hands-on projects, and dedicated mentoring. Earn certificates showcasing your achievement.",
          ]);
    } else if (widget.knowledgeId == 2) {
      knowledge = KnowledgeLibraryModel(
          id: widget.knowledgeId,
          title: "Project Management",
          imageUrl: "https://cdn.pixabay.com/photo/2013/04/03/12/05/tree-99852_640.jpg",
          knowledgeType: "Project Management Methodologies",
          contents: [
            "Through cutting-edge technology and a refined curriculum led by experienced instructors, users cultivate both technical and soft skills. The system acts as a supportive companion, monitoring progress and providing motivation to help achieve career objectives.",
            "Join Talentifylab where learning transforms into an exhilarating journey of discovery and achievement. With each step, users earn points, climb the ranks in our league, and challenge themselves to reach new heights of knowledge and skill.",
            "Our platform offers a diverse array of question banks featuring various questioning types, including fill-in-the-blank, true/false, multiple choice, and more."
          ]);
    } else if (widget.knowledgeId == 3) {
      knowledge = KnowledgeLibraryModel(
          id: widget.knowledgeId,
          title: "Java Framework",
          imageUrl:
              "https://webneel.com/daily/sites/default/files/images/daily/09-2019/beautiful-tree-photography-christophe-kiciak.jpg",
          knowledgeType: "Java Framework Management",
          contents: [
            "This dynamic approach ensures that students engage with the material in multiple ways, fostering deeper understanding and retention.",
            "Our AI system empowers individuals to craft personalized and effective resumes tailored to their unique strengths and experiences."
                "With guidance from instructors, your resume will be refined and market-ready, ensuring you stand out to potential employers. Moreover, our support doesn't end there.",
            "Instructors and mentors are on hand to assist you in navigating job opportunities and the application process, providing valuable insights and guidance every step of the way."
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${knowledge!.title}",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildKnowledgeContainer(),
    );
  }

  Widget _buildKnowledgeContainer() {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              knowledge!.knowledgeType,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: knowledge!.imageUrl,
                  height: MediaQuery.sizeOf(context).height * 0.33,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => {
                        setState(() {
                          if (selectedIndex > 0) {
                            selectedIndex--;
                          }
                        })
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                      hoverColor: Colors.transparent,
                    ),
                    Expanded(
                      child: Text(
                        knowledge!.contents[selectedIndex],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20,color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () => {
                        setState(() {
                          if (selectedIndex < knowledge!.contents.length - 1) {
                            selectedIndex++;
                          }
                        })
                      },
                      icon: const Icon(Icons.arrow_forward_ios_outlined),
                      hoverColor: Colors.transparent,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      if (selectedIndex == knowledge!.contents.length - 1)
        Positioned(
          bottom: 50,
          right: 20,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.purple,
            ),
            child: Text(
              "Complete",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
    ]);
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/knowledge_library_list_model.dart';
import '../../../widgets/bottom_bar_builder.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<KnowledgeLibraryListModel> knowledgeList = [
    KnowledgeLibraryListModel(
        id: 1,
        title: "Agile Framework",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g8.png",
        knowledgeType: "Agile Project Management",
        isComplete: true),
    KnowledgeLibraryListModel(
        id: 2,
        title: "Project Management",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g2.png",
        knowledgeType: "Project Management Methodologies",
        isComplete: false),
    KnowledgeLibraryListModel(
        id: 3,
        title: "Java Framework",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g3.png",
        knowledgeType: "Java Project Management",
        isComplete: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Knowledge Library",
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      bottomNavigationBar: BottomBarBuilder.buildBottomNavigationBar(context),
      floatingActionButton: BottomBarBuilder.buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildKnowledgeLibraryContainer(),
      ),
    );
  }

  //extract it to widget? - same usage for exercise list screen
  Widget _buildKnowledgeLibraryContainer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.95,
      ),
      itemCount: knowledgeList.length,
      itemBuilder: (context, index) {
        final KnowledgeLibraryListModel entry = knowledgeList[index];
        final bool isCompleted = entry.isComplete;
        int id=entry.id;

        return GestureDetector(
          onTap: () {
            print("dsffs");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KnowledgeDetailScreen(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
                        height: MediaQuery.of(context).size.height * 0.11,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: AutoSizeText(
                        entry.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        //minFontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Center(
                            child: AutoSizeText(
                              maxLines: 2,
                              entry.knowledgeType,
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted) _completedTextContainer(),
            ],
          ),
        );
      },
    );
  }

  Widget _completedTextContainer() {
    return Positioned(
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
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'knowledge_detail_screen.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<KnowledgeItem> knowledgeList = [
      KnowledgeItem(
        id: 1,
        title: "Agile Framework",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g8.png",
        knowledgeType: "Agile Project",
        isComplete: true,
      ),
      KnowledgeItem(
        id: 2,
        title: "Project Management",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g2.png",
        knowledgeType: "Project Management Methodologies",
        isComplete: false,
      ),
      KnowledgeItem(
        id: 3,
        title: "Java Framework",
        imageUrl: "https://app.talentifylab.com/vendor/website/resized-images/e.g3.png",
        knowledgeType: "Java Project Management",
        isComplete: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Knowledge Library",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.95,
                ),
                itemCount: knowledgeList.length,
                itemBuilder: (context, index) {
                  final item = knowledgeList[index];
                  return KnowledgeCard(item: item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KnowledgeCard extends StatelessWidget {
  final KnowledgeItem item;

  const KnowledgeCard({
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
            builder: (context) => const KnowledgeDetailScreen(),
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
            if (item.isComplete)
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
                topLeft: Radius.circular(item.isComplete ? 0 : 12.0),
                topRight: Radius.circular(item.isComplete ? 0 : 12.0),
              ),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                height: MediaQuery.of(context).size.height * 0.11,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: AutoSizeText(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Center(
                child: AutoSizeText(
                  item.knowledgeType,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KnowledgeItem {
  final int id;
  final String title;
  final String imageUrl;
  final String knowledgeType;
  final bool isComplete;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.knowledgeType,
    required this.isComplete,
  });
}

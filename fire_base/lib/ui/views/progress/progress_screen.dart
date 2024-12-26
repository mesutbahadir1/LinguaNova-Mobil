import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProgressItem> progress = [
      ProgressItem(
        id: 1,
        title: "Article Completed",
        count: 1,
        color: const Color.fromRGBO(123, 123, 432, 1.5),
      ),
      ProgressItem(
        id: 2,
        title: "Total Points Gained",
        count: 52,
        color: const Color.fromRGBO(144, 331, 100, 1.2),
      ),
      ProgressItem(
        id: 3,
        title: "Exercise Finished",
        count: 4,
        color: const Color.fromRGBO(186, 324, 122, 1.2),
      ),
      ProgressItem(
        id: 4,
        title: "Total Time",
        count: 324,
        color: const Color.fromRGBO(130, 111, 32, 1.1),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Progress",
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
                ),
                itemCount: progress.length,
                itemBuilder: (BuildContext context, int index) {
                  return ProgressCard(item: progress[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final ProgressItem item;

  const ProgressCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(47, 47, 66, 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AutoSizeText(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.005,
                  color: Colors.white,
                ),
                Text(
                  '${item.count}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressItem {
  final int id;
  final String title;
  final int count;
  final Color color;

  ProgressItem({
    required this.id,
    required this.title,
    required this.count,
    required this.color,
  });
}


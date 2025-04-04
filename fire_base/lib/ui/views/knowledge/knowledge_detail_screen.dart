import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_base/ui/views/exercise/exercise_screen.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/knowledge_library_model.dart';
import 'knowledge_screen.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final KnowledgeItem item; // KnowledgeItem'ı alacağız

  const KnowledgeDetailScreen({super.key, required this.item}); // Item'ı constructor'dan al

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.item.title, // Title'ı item'dan al
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
    return Container(
      padding: const EdgeInsets.all(16.0), // Padding artırıldı
      child: SingleChildScrollView( // Scrollable yapıldı, içerik çok uzun olabilir
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Daily Article" metninin stilini düzenledik
            Text(
              "Daily Article",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Görsel boyutları ve konumlandırması
                CachedNetworkImage(
                  imageUrl: "https://images.pexels.com/photos/1102909/pexels-photo-1102909.jpeg?cs=srgb&dl=pexels-jplenio-1102909.jpg&fm=jpg",
                  height: MediaQuery.sizeOf(context).height * 0.33,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    widget.item.content, // Content'i item'dan al
                    style: TextStyle(fontSize: 18, color: Colors.white, height: 1.6), // Satır yüksekliği eklendi
                    textAlign: TextAlign.justify, // Metni hizala
                  ),
                ),
                _buildCompleteButton()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: ElevatedButton(
        onPressed: () {
          // id parametresini ExerciseScreen'e geçiyoruz
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseScreen(
                itemId: widget.item.id, // id'yi parametre olarak geçir
                type: 1,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(
          "Complete",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

import '../../../app/constants/app_config.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  List<Map<String, dynamic>> comments = [];

  // Form için kontrolcüler
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController stockIdController = TextEditingController(); // StockId için kontrolcü

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    // Geçici olarak SSL sertifika doğrulamasını devre dışı bırakma
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    final response = await ioClient.get(Uri.parse('${HTTPS_URL}/api/Comment/GetAllComments'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        comments = data.map((e) => {'id': e['id'], 'title': e['title']}).toList();
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> createComment() async {
    final stockId = int.tryParse(stockIdController.text); // Kullanıcıdan alınan stockId
    if (stockId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Stock ID!')),
      );
      return;
    }

    // Yorum verilerini hazırlama
    final Map<String, dynamic> commentData = {
      'title': titleController.text,
      'content': contentController.text,
    };

    // Geçici olarak SSL sertifika doğrulamasını devre dışı bırakma
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {
      final response = await ioClient.post(
        Uri.parse('${HTTPS_URL}/api/Comment/CreateComment/$stockId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(commentData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment created successfully!')),
        );
        fetchComments(); // Yorumları yeniden çek
        titleController.clear();
        contentController.clear();
        stockIdController.clear();
      } else {
        // API tarafından döndürülen hata mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create comment: ${response.body}')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Program",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Yorum ekleme formu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: stockIdController,
                  decoration: const InputDecoration(
                    labelText: 'Stock ID',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: createComment, // Yorum ekleme fonksiyonu
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Add Comment'),
                ),
              ],
            ),
          ),
          // Yorumlar listesi
          comments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    "ID: ${comments[index]['id']} - ${comments[index]['title']}",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

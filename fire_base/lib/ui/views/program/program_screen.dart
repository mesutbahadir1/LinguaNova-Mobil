import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController articleIdController = TextEditingController();
  TextEditingController levelController = TextEditingController();

  Future<void> updateUserArticleProgress(int id) async {
    // Kullanıcıdan alınan verileri birleştirip JSON formatında hazırlama
    final userId = int.tryParse(userIdController.text); // Kullanıcıdan alınan UserId
    final articleId = int.tryParse(articleIdController.text); // Kullanıcıdan alınan ArticleId
    final level = int.tryParse(levelController.text); // Kullanıcıdan alınan Level

    if (userId == null || articleId == null || level == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values for UserId, ArticleId, and Level!')),
      );
      return;
    }

    // 'isCompleted' değerini true olarak ayarlama
    final Map<String, dynamic> userArticleProgressData = {
      'id': id,
      'userId': userId,
      'articleId': articleId,
      'level': level,
      'isCompleted': true,  // Buradaki değeri 'true' yapıyoruz
    };

    // Geçici olarak SSL sertifika doğrulamasını devre dışı bırakma
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    try {
      final response = await ioClient.put(
        Uri.parse('http://10.0.62.204:5040/api/UserArticleProgress/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userArticleProgressData),
      );

        final newLocation = response.headers['location'];
        if (newLocation != null) {
          final redirectedResponse = await ioClient.put(
            Uri.parse(newLocation),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(userArticleProgressData),
          );
          if (redirectedResponse.statusCode == 204) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('UserArticleProgress updated successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update UserArticleProgress: ${redirectedResponse.body}')),
            );
          }
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
      appBar: AppBar(
        title: const Text('Update UserArticleProgress'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: articleIdController,
              decoration: const InputDecoration(labelText: 'Article ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Level'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final id = int.tryParse(idController.text);
                if (id != null) {
                  updateUserArticleProgress(id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid ID!')),
                  );
                }
              },
              child: const Text('Update Progress'),
            ),
          ],
        ),
      ),
    );
  }
}

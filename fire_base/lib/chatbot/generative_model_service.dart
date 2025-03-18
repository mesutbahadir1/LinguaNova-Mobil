import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerativeChatService {
  final String apiKey = 'AIzaSyDrXaLQbM43gzVftWiSZajFbsrWRsLWf6A'; // Güvenli şekilde saklayın
  final String modelName = 'gemini-2.0-flash';
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String> sendMessage(String message) async {
    final Uri url = Uri.parse('$baseUrl/$modelName:generateContent?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['candidates'][0]['content']['parts'][0]['text'] ?? "No response";
    } else {
      return "Error: ${response.body}";
    }
  }
}
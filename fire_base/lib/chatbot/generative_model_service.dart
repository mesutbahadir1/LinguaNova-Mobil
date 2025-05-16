import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/constants/app_config.dart';

class GenerativeChatService {
  final String baseUrl = '$HTTPS_URL/api/chatbot';
  String _history = ''; // Private variable to store chat history

  // General Chat Mode
  Future<String> sendMessage(String message) async {
    // API isteği göndermek
    final Uri url = Uri.parse('$baseUrl/chat');

    // JSON formatında mesaj ve geçmişi API'ye gönder
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "UserMessage": message,
        "History": _history
      }),
    );

    if (response.statusCode == 200) {
      // AI cevabını al
      final aiResponse = response.body;

      // Geçmişi güncelle: Kullanıcı mesajını ve AI yanıtını ekle
      _history += 'You: $message\nAI: $aiResponse\n';

      return aiResponse; // Yanıtı döndür
    } else {
      print('API Hatası: ${response.statusCode} - ${response.body}');
      return 'An error occurred while processing your request. Please try again.';
    }
  }

  // Grammar Check Mode
  Future<String> checkGrammar(String text) async {
    final Uri url = Uri.parse('$baseUrl/grammar');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(text),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Grammar API Error: ${response.statusCode} - ${response.body}');
      return 'An error occurred while checking your grammar. Please try again.';
    }
  }

  // Vocabulary Mode
  Future<String> explainVocabulary(String word) async {
    final Uri url = Uri.parse('$baseUrl/vocabulary');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(word),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Vocabulary API Error: ${response.statusCode} - ${response.body}');
      return 'An error occurred while explaining the word. Please try again.';
    }
  }

  // Clear history function
  void clearHistory() {
    _history = ''; // Reset history
  }

  // Get history (optional)
  String getHistory() {
    return _history;
  }
}
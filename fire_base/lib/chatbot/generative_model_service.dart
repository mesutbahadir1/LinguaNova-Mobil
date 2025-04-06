import 'dart:convert';
import 'package:http/http.dart' as http;

class GenerativeChatService {
  final String baseUrl = 'http://192.168.1.157:5040/api/chatbot';
  String _history = ''; // Private variable to store chat history

  // Mesajları göndermek için
  Future<String> sendMessage(String message) async {
    // API isteği göndermek
    final Uri url = Uri.parse('$baseUrl/chat');
    //

    // JSON formatında mesaj ve geçmişi API'ye gönder
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "UserMessage": message,
        "History": _history // Geçmiş mesajlarla birlikte
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
      return 'Bir hata oluştu: ${response.statusCode}';
    }
  }

  // Geçmişi temizleme fonksiyonu
  void clearHistory() {
    _history = ''; // Geçmişi sıfırla
  }

  // Geçmişi almak için (isteğe bağlı)
  String getHistory() {
    return _history;
  }
}
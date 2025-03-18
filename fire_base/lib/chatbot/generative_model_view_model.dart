import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'generative_model_service.dart';

class ChatViewModel extends ChangeNotifier {
  final List<String> _messages = [];
  final GenerativeChatService _chatService;

  ChatViewModel(this._chatService);

  List<String> get messages => _messages;

  void sendMessage(String message) async {
    final response = await _chatService.sendMessage(message);
    _messages.add("You: $message");
    _messages.add("AI: $response");
    notifyListeners();
  }

  static ChatViewModel create(BuildContext context) {
    return ChatViewModel(
      Provider.of<GenerativeChatService>(context, listen: false),
    );
  }
}
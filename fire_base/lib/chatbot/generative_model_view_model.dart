import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'generative_model_service.dart';
import 'chat_modes.dart';

class ChatViewModel extends ChangeNotifier {
  final List<String> _messages = [];
  final GenerativeChatService _chatService;
  ChatMode _currentMode = ChatMode.chat;

  ChatViewModel(this._chatService);

  List<String> get messages => List.unmodifiable(_messages);
  ChatMode get currentMode => _currentMode;

  void setMode(ChatMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      clearChat();
      notifyListeners();
    }
  }

  void sendMessage(String message) async {
    String response;

    // Add user message to the list
    _messages.add("You: $message");
    notifyListeners();

    // Get response based on current mode
    switch (_currentMode) {
      case ChatMode.chat:
        response = await _chatService.sendMessage(message);
        break;
      case ChatMode.grammar:
        response = await _chatService.checkGrammar(message);
        break;
      case ChatMode.vocabulary:
        response = await _chatService.explainVocabulary(message);
        break;
    }

    // Add AI response to the list
    _messages.add("AI: $response");
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _chatService.clearHistory();
    notifyListeners();
  }

  static ChatViewModel create(BuildContext context) {
    return ChatViewModel(
      Provider.of<GenerativeChatService>(context, listen: false),
    );
  }
}
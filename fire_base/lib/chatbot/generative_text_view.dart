import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generative_model_view_model.dart';
import 'chat_modes.dart';
import 'novi_title.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: NoviTitle(
          text: 'Novi',
          textColor: Colors.white,
          glowColor: const Color(0xFF4B5EFF),
          fontSize: 26,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1A35),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A1A35), // Arka plan koyu mavi
        ),
        child: Column(
          children: [
            // Mode Selection Bar
            _buildModeSelectionBar(),

            // Chat Messages
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, chatViewModel, child) {
                  final chatMessages = chatViewModel.messages;

                  if (chatMessages.isNotEmpty) {
                    _scrollToBottom();
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2A44), // Mesaj alanı koyu mavi ton
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: chatMessages.isEmpty
                        ? _buildWelcomeMessage(chatViewModel.currentMode)
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        final isUserMessage =
                        chatMessages[index].startsWith("You:");
                        return _buildMessageBubble(
                            chatMessages[index], isUserMessage);
                      },
                    ),
                  );
                },
              ),
            ),

            // Message Input
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelectionBar() {
    return Consumer<ChatViewModel>(
      builder: (context, chatViewModel, child) {
        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final mode in ChatMode.values)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      mode.displayName,
                      style: TextStyle(
                        color: chatViewModel.currentMode == mode
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: chatViewModel.currentMode == mode,
                    selectedColor: const Color(0xFF4B5EFF), // Açık mavi renk
                    backgroundColor: const Color(0xFF1C2A44),
                    onSelected: (selected) {
                      if (selected) {
                        chatViewModel.setMode(mode);
                      }
                    },
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage(ChatMode mode) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getModeIcon(mode),
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                mode.welcomeTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                mode.welcomeMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon(ChatMode mode) {
    switch (mode) {
      case ChatMode.chat:
        return Icons.chat_bubble_outline;
      case ChatMode.grammar:
        return Icons.spellcheck;
      case ChatMode.vocabulary:
        return Icons.menu_book;
    }
  }

  Widget _buildMessageBubble(String message, bool isUserMessage) {
    // Mesajı temizle (örneğin "You: " veya "Novi: " kısmını kaldır)
    String cleanedMessage = message.startsWith("You: ")
        ? message.substring(5)
        : message.startsWith("Novi: ")
        ? message.substring(6)
        : message;

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUserMessage
              ? const Color(0xFF4B5EFF) // Kullanıcı mesajı için açık mavi
              : const Color(0xFF0A1A35),
          borderRadius: BorderRadius.circular(20).copyWith(
            topLeft: isUserMessage ? const Radius.circular(20) : const Radius.circular(5),
            topRight: isUserMessage ? const Radius.circular(5) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isUserMessage ? const Color(0xFF0A1A35) : const Color(0xFF4B5EFF),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Colors.black12 // Kullanıcı etiketi için hafif koyu arka plan
                    : const Color(0xFF4B5EFF), // AI etiketi için koyu mavi arka plan
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isUserMessage ? "You" : "Novi",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Novi mesajları için çift yıldızları kalın yapmak istiyoruz
            isUserMessage
                ? Text(
              cleanedMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            )
                : _buildFormattedMessage(cleanedMessage), // Novi mesajı için özel formatlama
          ],
        ),
      ),
    );
  }

// Çift yıldızları algılayıp kalın metin oluşturacak yardımcı metod
  Widget _buildFormattedMessage(String message) {
    // Çift yıldızları bulmak için düzenli ifade (regex) kullanıyoruz
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> textSpans = [];

    int lastIndex = 0;
    for (final match in boldPattern.allMatches(message)) {
      // Yıldızlardan önceki kısmı normal metin olarak ekle
      if (match.start > lastIndex) {
        textSpans.add(
          TextSpan(
            text: message.substring(lastIndex, match.start),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        );
      }

      // Yıldızlar arasındaki kısmı kalın olarak ekle
      textSpans.add(
        TextSpan(
          text: match.group(1), // Yıldızlar arasındaki metin
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold, // Kalın yazı tipi
            height: 1.4,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Kalan metni ekle (eğer varsa)
    if (lastIndex < message.length) {
      textSpans.add(
        TextSpan(
          text: message.substring(lastIndex),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      );
    }

    // Eğer hiç yıldız yoksa, metni olduğu gibi döndür
    if (textSpans.isEmpty) {
      return Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      );
    }

    // RichText ile biçimlendirilmiş metni döndür
    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C2A44), // Input alanı koyu mavi ton
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Consumer<ChatViewModel>(
        builder: (context, chatViewModel, child) {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    hintText: _getHintTextForMode(chatViewModel.currentMode),
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: const Color(0xFF4B5EFF), // Açık mavi renk
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        chatViewModel.sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white, // Simge rengini beyaza çevirdim, açık maviyle daha iyi kontrast sağlar
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getHintTextForMode(ChatMode mode) {
    switch (mode) {
      case ChatMode.chat:
        return "Ask me anything...";
      case ChatMode.grammar:
        return "Enter text for grammar check...";
      case ChatMode.vocabulary:
        return "Enter a word to learn about...";
    }
  }
}
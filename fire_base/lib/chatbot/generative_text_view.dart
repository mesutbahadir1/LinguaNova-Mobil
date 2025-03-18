import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generative_model_view_model.dart';

class ChatView extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('AI Chat', style: TextStyle(fontWeight: FontWeight.bold),)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.lightBlue.shade200, // Üst taraf daha açık mavi
                Colors.blue.shade300,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade200, // Üst taraf daha açık mavi
              Colors.blue.shade300,
              Colors.deepPurple.shade300, // Alt tarafa doğru mor geçiş
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, chatViewModel, child) {
                  final chatMessages = chatViewModel.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final isUserMessage =
                          chatMessages[index].startsWith("You:");
                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? Colors.lightBlue.shade100
                                    .withOpacity(0.8) // Kullanıcı mesajı
                                : Colors.deepPurple.shade100.withOpacity(0.8),
                            // AI mesajı
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(2, 3),
                              )
                            ],
                          ),
                          child: Text(
                            chatMessages[index],
                            style: TextStyle(
                              color: isUserMessage
                                  ? Colors.black87
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade500,
                    radius: 26,
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 22),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          Provider.of<ChatViewModel>(context, listen: false)
                              .sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

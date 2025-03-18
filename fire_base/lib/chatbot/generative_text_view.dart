import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generative_model_view_model.dart';

class ChatView extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'),
        backgroundColor: Colors.lightBlue, // Adjusted color
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, chatViewModel, child) {
                  final chatMessages = chatViewModel.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: chatMessages.length,
                    itemBuilder: (context, index) {
                      final isUserMessage = chatMessages[index].startsWith("You:");
                      return Align(
                        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isUserMessage ? Colors.lightBlue[100] : Colors.deepPurple[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            chatMessages[index],
                            style: TextStyle(
                              color: isUserMessage ? Colors.black : Colors.black,
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
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
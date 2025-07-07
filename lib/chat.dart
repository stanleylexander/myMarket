import 'package:flutter/material.dart';
import 'package:my_market/class/chat_message.dart';
// Import the model

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  List<ChatMessage> messages = [];
  int myUserId = 2; // Change this to the logged-in user's ID

  @override
  void initState() {
    super.initState();
    fetchMessages(); // You would fetch from API here
  }

  void fetchMessages() async {
    // TODO: Replace this with real API call
    setState(() {
      messages = [
        ChatMessage(
          id: 1,
          text: "Hello there!",
          userId: 1,
          username: "Seller",
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ChatMessage(
          id: 2,
          text: "Hi! I'm interested in your product.",
          userId: 2,
          username: "Customer",
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ];
    });
  }

  void sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          id: messages.length + 1,
          text: text,
          userId: myUserId,
          username: "You",
          timestamp: DateTime.now(),
        ),
      );
      _textController.clear();
    });

    // TODO: Send to backend
  }

  Widget buildMessage(ChatMessage msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(msg.text),
          const SizedBox(height: 4),
          Text(
            msg.timestamp.toString(),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => buildMessage(messages[index]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

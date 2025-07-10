// lib/private_chat.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PrivateChatPage extends StatefulWidget {
  final int receiverId;

  const PrivateChatPage({super.key, required this.receiverId});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  List messages = [];
  TextEditingController controller = TextEditingController();
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    if (userId == null) return;

    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422024/myMarket_getPrivateChat.php",
      ),
      body: {'user1': userId.toString(), 'user2': widget.receiverId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
      });
    }
  }

  Future<void> sendMessage() async {
    if (userId == null || controller.text.trim().isEmpty) return;

    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422024/myMarket_sendPrivateChat.php",
      ),
      body: {
        'text': controller.text,
        'user_id': userId.toString(),
        'receiver_id': widget.receiverId.toString(),
      },
    );

    if (response.statusCode == 200) {
      controller.clear();
      fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Penjual")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var msg = messages[index];
                bool isMe = msg['user_id'].toString() == userId.toString();
                return ListTile(
                  title: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(msg['text']),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Ketik pesan...",
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

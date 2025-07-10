import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import the model

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); //scroll controller (gk diajari) buat nantik chat nya auto kebawah keren ga tuh

  List<ChatMessage> messages = [];
  int myUserId = 0;

  @override
  void initState() {
    super.initState();
    loadUserId(); //ambil Id dari email yang sudah login
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadUserId() async {
    //ambil id nya dari email dr login,
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('_user_email');

    if (email == null || email.isEmpty) {
      print("Email not found in SharedPreferences");
      return;
    }

    final url = Uri.parse(
      'https://ubaya.xyz/flutter/160422029/myMarket_getIdEmail.php', //webservice nya ini
    );

    try {
      final response = await http.post(url, body: {'email': email});
      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        setState(() {
          myUserId = int.parse(
            result['user_id'].toString(),
          ); //kalau dapet, nanti disimpen di myUserID
        });
        fetchMessages();
      } else {
        print("Failed to fetch user_id: ${result['message']}");
      }
    } catch (e) {
      print("Error fetching user_id: $e");
    }
  }

  void fetchMessages() async {
    final url = Uri.parse(
      'https://ubaya.xyz/flutter/160422029/myMarket_getChat.php', //ambil dulu disini
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          messages = data.map((item) => ChatMessage.fromJson(item)).toList();
        });

        //scroll ke bawah kalau ada new message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut, //ini gatau yo, ease out buat animasi tok
            );
          }
        });
      } else {
        debugPrint('Error loading chat: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final url = Uri.parse(
      'https://ubaya.xyz/flutter/160422029/myMarket_sendChat.php',
    );

    try {
      final response = await http.post(
        url,
        body: {'text': text, 'user_id': myUserId.toString()},
      );

      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        _textController.clear();
        fetchMessages(); //refresh habis di send
      } else {
        debugPrint('Failed to send: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
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
              controller: _scrollController,
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
                      hintText: "Ketik Pesan anda di sini",
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

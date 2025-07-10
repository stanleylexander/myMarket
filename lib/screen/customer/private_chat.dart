import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrivateChatPage extends StatefulWidget {
  final int receiverId;

  const PrivateChatPage({super.key, required this.receiverId});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  List messages = [];
  TextEditingController controller = TextEditingController();
  String userId = '';
  Timer? refreshTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadUserIdAndStart();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUserIdAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("user_id") ?? '';
    fetchMessages();

    refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMessages();
    });
  }

  Future<void> fetchMessages() async {
    if (userId.isEmpty) return;

    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422029/MyMarket_getPrivateChat.php",
      ),
      body: {'user_id': userId, 'receiver_id': widget.receiverId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
      });

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
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422029/MyMarket_sendPrivateChat.php",
      ),
      body: {
        'text': controller.text,
        'user_id': userId,
        'receiver_id': widget.receiverId.toString(),
      },
    );

    if (response.statusCode == 200) {
      controller.clear();
      fetchMessages();
    }
  }

  Widget buildMessage(Map msg) {
    bool isMe = msg['user_id'].toString() == userId;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?u=${msg['user_id']}",
              ),
              radius: 18,
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.deepPurple[100] : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      msg['username'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  Text(msg['text'], style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(
                    msg['tanggal'] ?? '',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Penjual")),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Ketik pesan...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 22,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/chat.dart';
import 'package:my_market/screen/customer/private_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomList extends StatefulWidget {
  const ChatRoomList({super.key});

  @override
  State<ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  List<Map<String, dynamic>> rooms = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("user_id");
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422024/myMarket_chatRooms.php"),
      body: {"user_id": userId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        rooms = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: ListView(
        children: [
          // Group chat always on top
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.group)),
            title: const Text("Group Chat"),
            subtitle: const Text("Klik untuk bergabung"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
          ),
          const Divider(),

          // Loop through private chat rooms
          ...rooms.map((room) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(room["other_name"] ?? "Pengguna"),
              subtitle: Text(room["last_message"] ?? ""),
              trailing: Text(room["last_time"] ?? ""),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PrivateChatPage(receiverId: room["other_id"]),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

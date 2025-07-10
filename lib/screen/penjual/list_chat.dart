import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_market/screen/customer/private_chat.dart';

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  List<Map<String, dynamic>> buyers = [];
  int? sellerId;

  @override
  void initState() {
    super.initState();
    loadSeller();
  }

  Future<void> loadSeller() async {
    final prefs = await SharedPreferences.getInstance();
    sellerId = int.tryParse(prefs.getString("user_id") ?? "");
    if (sellerId != null) {
      fetchBuyers();
    }
  }

  Future<void> fetchBuyers() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422029/myMarket_listCustomer.php",
      ),
      body: {"user_id": sellerId.toString()},
    );

    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body);
      setState(() {
        buyers =
            raw
                .map(
                  (e) => {
                    "id": int.tryParse(e["id"].toString()) ?? 0,
                    "name": e["name"] ?? "Pembeli",
                  },
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat dari Pembeli")),
      body: ListView.builder(
        itemCount: buyers.length,
        itemBuilder: (context, index) {
          final buyer = buyers[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(buyer["name"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateChatPage(receiverId: buyer["id"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

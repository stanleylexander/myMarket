import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/screen/customer/private_chat.dart';

class ListChat extends StatefulWidget {
  const ListChat({super.key});

  @override
  State<ListChat> createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  List<Map<String, dynamic>> sellers = [];

  @override
  void initState() {
    super.initState();
    fetchSellers();
  }

  Future<void> fetchSellers() async {
    final response = await http.get(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_listSeller.php"),
    );

    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body);
      setState(() {
        sellers =
            raw
                .map(
                  (e) => {
                    "id": int.tryParse(e["id"].toString()) ?? 0,
                    "name": e["name"] ?? "Penjual",
                  },
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Penjual")),
      body: ListView.builder(
        itemCount: sellers.length,
        itemBuilder: (context, index) {
          final seller = sellers[index];
          return ListTile(
            leading: const Icon(Icons.store),
            title: Text(seller["name"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivateChatPage(receiverId: seller["id"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

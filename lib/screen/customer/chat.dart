// lib/screen/customer/chat.dart

import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final int sellerId;
  final String sellerName;

  const ChatScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat dengan $sellerName')),
      body: const Center(
        child: Text(
          'Halaman chat belum diimplementasikan.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_market/chat.dart';
import 'package:my_market/screen/login.dart';
import 'package:my_market/screen/penjual/kategori.dart';
import 'package:my_market/screen/penjual/produk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePenjual extends StatefulWidget {
  const HomePenjual({super.key});

  @override
  State<HomePenjual> createState() => _HomePenjualState();
}

class _HomePenjualState extends State<HomePenjual> {
  String _userId = "";

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePenjual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
          ),
        ],
      ),

      drawer: myDrawer(),
      body: const Center(child: Text("This is HomePenjual")),
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_userId),
            accountEmail: Text(_userId),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
          ListTile(
            title: const Text("Edit Produk"),
            leading: const Icon(Icons.shop),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InputProductPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Edit Kategori"),
            leading: const Icon(Icons.category),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ListKategoriPage(),
                ),
              );
              // Navigate to Edit Kategori screen (if exists)
            },
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout),
            onTap: doLogout,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_market/chat.dart';
import 'package:my_market/main.dart';
import 'package:my_market/screen/login.dart';
import 'package:my_market/screen/penjual/kategori.dart';
import 'package:my_market/screen/penjual/produk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePenjual extends StatefulWidget {
  final bool loginStatus;
  const HomePenjual({super.key, this.loginStatus = false});

  @override
  State<HomePenjual> createState() => _HomePenjualState();
}

class _HomePenjualState extends State<HomePenjual> {
  String _userId = "";
  bool loginMessage = false;

  @override
  void initState() {
    super.initState();
    loadUserId();

    if (widget.loginStatus) {
      loginMessage = true;

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            loginMessage = false;
          });
        }
      });
    }
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
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Penjual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Group Chat',
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
      body: Column(
        children: [ 
          if (loginMessage)
            Positioned(
            top: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Login berhasil!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: Text("This is HomePenjual"),
          ),
        ],
      ),
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(active_user),
            accountEmail: Text(active_user_email),
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

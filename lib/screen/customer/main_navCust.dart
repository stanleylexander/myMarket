// lib/screen/customer/main_navigator_customer.dart

import 'package:flutter/material.dart';
import 'package:my_market/chat.dart';
import 'package:my_market/screen/customer/cart.dart';
import 'package:my_market/screen/customer/home.dart';
import 'package:my_market/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigatorCustomer extends StatefulWidget {
  final bool loginStatus;
  const MainNavigatorCustomer({super.key, this.loginStatus = false});

  @override
  State<MainNavigatorCustomer> createState() => _MainNavigatorCustomerState();
}

class _MainNavigatorCustomerState extends State<MainNavigatorCustomer> {
  int _selectedIndex = 0;
  String _title = "Daftar Produk";

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const HomeCustomer(),
    const CartScreen(), // Halaman Pembelian / Keranjang
  ];

  void _onItemTapped(int index, String title) {
    setState(() {
      _selectedIndex = index;
      _title = title;
    });
    Navigator.pop(context); // Menutup drawer setelah item dipilih
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus semua data sesi
    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("user_role");

    // Kembali ke halaman login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyLogin()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'My Market Customer',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0, "Daftar Produk");
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Pembelian'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1, "Keranjang Belanja");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

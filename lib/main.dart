// lib/main.dart

import 'package:flutter/material.dart';
import 'package:my_market/screen/customer/main_navCust.dart';
import 'package:my_market/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Variabel global (jika masih diperlukan)
String active_user = "";
String active_user_id = "";
String active_user_role = "";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tidak perlu memanggil runApp di dalam .then()
  // Cukup tentukan widget mana yang akan jadi 'home'
  checkUser().then((Map<String, String> result) {
    Widget homePage;
    if (result['user_name'] == '') {
      homePage = MyLogin(); // Tentukan halaman login sebagai home
    } else {
      // Set variabel global jika perlu
      active_user = result['user_name'] ?? '';
      active_user_id = result['user_id'] ?? '';
      active_user_role = result['user_role'] ?? '';

      // Tentukan halaman berdasarkan role
      if (active_user_role == 'customer') {
        homePage = const MainNavigatorCustomer();
      } else {
        // Ganti dengan navigator untuk penjual jika sudah ada
        homePage = Scaffold(body: Center(child: Text("Halaman Penjual")));
      }
    }

    // Panggil runApp HANYA SEKALI di sini dengan MaterialApp
    runApp(MyApp(home: homePage));
  });
}

// Buat widget MyApp sebagai root
class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Properti 'home' ditentukan secara dinamis dari main()
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Fungsi checkUser tidak berubah
Future<Map<String, String>> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString("user_id") ?? '';
  String userName = prefs.getString("user_name") ?? '';
  String userRole = prefs.getString("user_role") ?? '';
  return {'user_id': userId, 'user_name': userName, 'user_role': userRole};
}

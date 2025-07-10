import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_market/screen/customer/main_navCust.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/screen/customer/home.dart';
import 'package:my_market/screen/penjual/home.dart';
import 'package:my_market/screen/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  String _user_email = "";
  String _user_password = "";
  String _error_login = "";
  bool _obscurePassword = true; // Untuk toggle show/hide password
  final _formKey = GlobalKey<FormState>(); // Untuk validasi form

  void doLogin() async {
    //SEMENTARA MASIH PAKE LOCAL, IP NYA DIGANTI SESUAI LAPTOP MASING-MASING,
    //login.php TARUH DI HTDOCS DAN URL SESUAIKAN DENGAN LOKASI login.php
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_login.php"),
      body: {'email': _user_email, 'password': _user_password},
    );

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", jsonResponse['id']?.toString() ?? '');
        prefs.setString("user_name", jsonResponse['name'] ?? '');
        prefs.setString("user_email", _user_email);
        prefs.setString("user_role", jsonResponse['role'] ?? '');

        String role = jsonResponse['role'];
        if (role == 'penjual') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePenjual(loginStatus: true)),
          );
        }
         else if (role == 'customer') {
          Navigator.pushReplacement(
            // Gunakan pushReplacement agar tidak bisa kembali ke login
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigatorCustomer(loginStatus: true)),
            );
        } else {
          setState(() {
            _error_login = "Unknown role: $role";
          });
        }
      } else {
        setState(() {
          _error_login = "Invalid username or password";
        });
      }
    } else {
      throw Exception('Failed to connect to API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
        child: Container(
          width: 400,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 1),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 5)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  "Sign in to myMarket",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid email id as abc@gmail.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    return null;
                  },  
                  onChanged: (value) {
                    setState(() {
                      _user_email = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _user_password = value;
                  },
                ),
              ),
              if (_error_login.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    _error_login,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        doLogin();
                      }
                    },
                    child: Text('Login', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New to myMarket? ", style: TextStyle(fontSize: 15)),
                    TextButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),)
    ));
  }
}

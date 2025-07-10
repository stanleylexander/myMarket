import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_market/screen/customer/main_navCust.dart';
import 'package:my_market/screen/penjual/home.dart';
import 'package:my_market/screen/register.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _user_email = "";
  String _user_password = "";
  String _error_login = "";
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  void doLogin() async {
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
            MaterialPageRoute(
              builder: (context) => const HomePenjual(),
            ),
          );
        } else if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigatorCustomer(),
            ),
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
      setState(() {
        _error_login = "Failed to connect to server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(width: 1),
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 0),
                    child: Image.asset(
                      'assets/logo-tokko.png',
                      width: 200,
                      height: 100,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Sign in to myMarket",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  //Email
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
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
                  //Password
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
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
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        _error_login,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  //Button Login
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 30,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            doLogin();
                          }
                        },
                        child: const Text('Login', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ),
                  //Routing to Register
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New to myMarket? ", style: TextStyle(fontSize: 15)),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Register()),
                            );
                          },
                          child: const Text(
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
          ),
        ),
      ),
    );
  }
}

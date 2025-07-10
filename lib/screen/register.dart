import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/screen/login.dart';

class MyRegister extends StatelessWidget {
  const MyRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Register')));
  }
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _user_email = "";
  String _user_name = "";
  String _user_password = "";
  String _user_role = "";

  void Submit() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_register.php"),
      body: {
        'name': _user_name,
        'email': _user_email,
        'password': _user_password,
        'role': _user_role,
      },
    );

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Register Successfully')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to connect to API');
    }

    // final response = await http
    //   .post(Uri.parse("https://ubaya.xyz/flutter/160422029/register.php"), body: {
    // 'email': _user_email,
    // 'username': _user_name,
    // 'password': _user_password,
    // 'role': _user_role
    // });
    // if(response.statusCode == 200){
    //   Map json = jsonDecode(response.body);
    //   if(json['result']=='success'){
    //     if(!mounted) return;
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sukses Register")));
    //   }
    // } else{
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
    //   throw Exception("Gagal membaca API");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // ✅ Tambahkan ini
          child: Form( // ✅ Gunakan Form di sini
            key: _formKey,
            child: Container(
              width: 400,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1),
                color: Colors.white,
                boxShadow: const [BoxShadow(blurRadius: 5)],
              ),
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
                    padding: EdgeInsets.only(bottom: 40),
                    child: Text(
                      "Sign up to myMarket",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@gmail.com',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _user_email = value;
                        });
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Email wajib diisi' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter secure password',
                      ),
                      onChanged: (value) {
                        _user_password = value;
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Password wajib diisi' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nama',
                        hintText: 'Masukkan nama pengguna',
                      ),
                      onChanged: (value) {
                        _user_name = value;
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Text("Pilih Job:", style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'penjual',
                              groupValue: _user_role,
                              onChanged: (value) {
                                setState(() {
                                  _user_role = value!;
                                });
                              },
                            ),
                            const Text("Penjual"),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'customer',
                              groupValue: _user_role,
                              onChanged: (value) {
                                setState(() {
                                  _user_role = value!;
                                });
                              },
                            ),
                            const Text("Customer"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 30,
                      width: 110,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Submit();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Login()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Harap semua form diisi")),
                            );
                          }
                        },
                        child: const Text('Register', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "Already have an account",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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

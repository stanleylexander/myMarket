import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/screen/login.dart';

class MyRegister extends StatelessWidget {
  const MyRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
    );
  }
}

class Register extends StatefulWidget{
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

  void Submit() async{

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_register.php"),
      body: {'name': _user_name, 'email': _user_email, 'password': _user_password, 'role': _user_role}
    );

      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] == 'success') {

          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Register Successfully')));
        }
      } else {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
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
      body:Center(
        child: Container(
          key: _formKey,
          height: 500,
          width: 400,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 1),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 5)]
          ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Sign up to myMarket",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter valid email id as abc@gmail.com'
                    ),
                    onChanged: (value) {
                      setState(() {
                        _user_email = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password'
                    ),
                    onChanged: (value) {
                      _user_password = value;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      hintText: 'Enter your username'
                    ),
                    onChanged: (value) {
                      _user_name = value;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        "Pilih Job:",
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                      SizedBox(width: 10,),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'penjual',
                            groupValue: _user_role,
                            onChanged: (value){
                              setState(() {
                                _user_role = value!;
                              });
                            },
                          ),
                          const Text("Penjual"),
                        ],
                      ),
                      SizedBox(width: 10,),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'customer',
                            groupValue: _user_role,
                            onChanged: (value) {
                              setState(() {
                                _user_role  = value!;
                              });
                            },
                          ),
                          const Text("Customer")
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 30,
                    width: 110,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState != null && !_formKey.currentState!.validate()){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Harap semua form diisi")));
                        } else{
                          Submit();
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent)
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
                    }, 
                    child: Text(
                      "Already have an account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      ),
                    )
                  ),
                )
              ]
            ),
        )
      )
    );
  }

}

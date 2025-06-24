import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/product.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeCustomer();
  }
}

class _HomeCustomer extends State<HomeCustomer>{
  List<Product> Ps = [];

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_productlist.php")
    );

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        List<Product> temp = [];
        for (var product in jsonResponse['data']) {
          temp.add(Product.fromJson(product));
        }
        setState(() {
          Ps = temp;
        });
      } else {
        print("API error: ${jsonResponse['message']}");
      }
    } else {
      throw Exception('Failed to connect API');
    }
  }


  @override 
  void initState() {
    super.initState();
    fetchData();
  }

  Widget DaftarProduct(List<Product> products){
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: (products[index].image != '') ? Image.network(
                  products[index].image,
                  width: 100,
                  height: 200,
                  errorBuilder: (context, error, stackTrace){
                    return const Icon(Icons.image, size: 70);
                  },
                ) : const Icon(Icons.ac_unit_rounded),
                title: GestureDetector(
                  child: Text(
                    products[index].name
                  ),
                  // onTap: (){
                  //   Navigator.push(context, MaterialPageRoute(builder: (context)=>detailProduct()));
                  // },
                ),
                subtitle: Text(
                  "Rp ${products[index].price}"
                ),
              )
            ],
            
          )
        );
      }
    );
    }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: Row(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              width: MediaQuery.of(context).size.width,
              child: (Ps.isNotEmpty) ? DaftarProduct(Ps) : const Text("Product Tidak Tersedia")
            )
          ],
        ),
      ),
    );
  }
}

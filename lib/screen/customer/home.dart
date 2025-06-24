import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/product.dart';
import 'package:my_market/class/category.dart';
import 'package:my_market/screen/customer/product_detail.dart';

class HomeCustomer extends StatefulWidget {
  const HomeCustomer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeCustomerState();
  }
}

class _HomeCustomerState extends State<HomeCustomer> {
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<Category> categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_productlist.php"),
    );

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          allProducts = List<Product>.from(
            jsonResponse['data'].map((i) => Product.fromJson(i)),
          );
          filteredProducts = allProducts;
        });
      }
    } else {
      throw Exception('Failed to connect API');
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422024/myMarket_categorylist.php",
      ),
    );
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          categories = List<Category>.from(
            jsonResponse['data'].map((i) => Category.fromJson(i)),
          );
        });
      }
    }
  }

  void _filterProducts(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      if (categoryId == null) {
        filteredProducts = allProducts;
      } else {
        filteredProducts =
            allProducts.where((p) {
              // Cek apakah list kategori produk mengandung ID yang dipilih
              return p.category?.any((c) => c.id == categoryId) ?? false;
            }).toList();
      }
    });
  }

  Widget DaftarProduct(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading:
                (products[index].image.isNotEmpty)
                    ? Image.network(
                      products[index].image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 50);
                      },
                    )
                    : const Icon(Icons.shopping_bag_outlined, size: 50),
            title: Text(
              products[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Rp ${products[index].price.toStringAsFixed(0)}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ProductDetailScreen(productId: products[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Filter Berdasarkan Kategori',
              border: OutlineInputBorder(),
            ),
            value: selectedCategoryId,
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text("Semua Kategori"),
              ),
              ...categories.map((Category category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
            ],
            onChanged: (int? newValue) {
              _filterProducts(newValue);
            },
          ),
        ),
        Expanded(
          child:
              filteredProducts.isNotEmpty
                  ? DaftarProduct(filteredProducts)
                  : Center(
                    child: Text(
                      allProducts.isEmpty
                          ? "Memuat data..."
                          : "Produk tidak ditemukan",
                    ),
                  ),
        ),
      ],
    );
  }
}

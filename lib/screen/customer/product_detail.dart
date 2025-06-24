import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/cart_item.dart';
import 'package:my_market/class/cart_manager.dart';
import 'package:my_market/class/category.dart';
import 'package:my_market/class/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422024/myMarket_productDetail.php",
      ),
      body: {"product_id": widget.productId.toString()},
    );

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          product = Product.fromJson(jsonResponse['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = jsonResponse['message'];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Failed to load data from server.';
        isLoading = false;
      });
    }
  }

  Widget buildCategoryChips(List<Category> categories) {
    return Wrap(
      spacing: 6,
      children:
          categories
              .map(
                (cat) => Chip(
                  label: Text(cat.name),
                  backgroundColor: Colors.blue.shade100,
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : product == null
              ? Center(child: Text(errorMessage))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    if (product!.image.isNotEmpty)
                      Image.network(
                        product!.image,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      )
                    else
                      const Icon(Icons.shopping_bag_outlined, size: 100),
                    const SizedBox(height: 16),
                    Text(
                      product!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${product!.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Stok: ${product!.stock}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product!.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Tambah ke Keranjang"),
                      onPressed: () {
                        CartManager.add(
                          CartItem(
                            productId: product!.id,
                            name: product!.name,
                            price: product!.price,
                            quantity: 1,
                            image: product!.image,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Produk ditambahkan ke keranjang"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),
                    if (product!.category != null &&
                        product!.category!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Kategori:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildCategoryChips(product!.category!),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}

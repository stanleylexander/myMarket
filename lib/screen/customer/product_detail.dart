// lib/screen/customer/product_detail.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/product.dart';
import 'package:my_market/screen/customer/chat.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;

  Future<void> fetchProductDetail() async {
    // Anda perlu membuat endpoint PHP baru untuk ini
    final response = await http.post(
      Uri.parse(
        "https://ubaya.xyz/flutter/160422029/myMarket_productdetail.php",
      ),
      body: {'id': widget.productId.toString()},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        setState(() {
          product = Product.fromJson(jsonResponse['data']);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail Produk")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product!.image.isNotEmpty)
              Center(
                child: Image.network(
                  product!.image,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              product!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Rp ${product!.price.toStringAsFixed(0)}",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.deepPurple),
            ),
            const SizedBox(height: 8),
            Text("Stok: ${product!.stock}"),
            const SizedBox(height: 16),
            const Text(
              "Deskripsi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(product!.description),
            const SizedBox(height: 16),
            const Text(
              "Kategori:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children:
                  product!.category
                      ?.map((cat) => Chip(label: Text(cat.name)))
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 16),
            const Text(
              "Penjual:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Anda perlu 'seller_name' & 'seller_id' dari PHP
            Text(product!.sellerName ?? 'Tidak diketahui'),
            const Divider(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("Tambah ke Keranjang"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product!.name} ditambahkan ke keranjang!"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Chat Penjual"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (product!.sellerId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            sellerId: product!.sellerId!,
                            sellerName: product!.sellerName ?? 'Penjual',
                          ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

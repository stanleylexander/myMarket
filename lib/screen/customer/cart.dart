import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/cart_item.dart';
import 'package:my_market/class/cart_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> checkout() async {
    final prefs = await SharedPreferences.getInstance();
    int customerId = int.parse(prefs.getString("user_id") ?? "1");

    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160422029/myMarket_checkout.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "customer_id": customerId,
        "total": CartManager.total,
        "items": CartManager.items.map((e) => e.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Pembayaran berhasil!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          CartManager.clear();
        });
      } else {
        showError(jsonResponse['message']);
      }
    } else {
      showError("Gagal terhubung ke server.");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Keranjang Belanja Kosong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tambahkan produk ke keranjang Anda",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shopping_bag, size: 30);
                        },
                      ),
                    )
                  : const Icon(Icons.shopping_bag, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${item.price.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                      (Match m) => '${m[1]}.',
                    )}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        setState(() {
                          CartManager.decreaseQuantity(item);
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() {
                          CartManager.increaseQuantity(item);
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Rp ${(item.price * item.quantity).toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                    (Match m) => '${m[1]}.',
                  )}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  CartManager.removeItem(item);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Belanja:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Rp ${CartManager.total.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                  (Match m) => '${m[1]}.',
                )}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: CartManager.items.isEmpty ? null : checkout,
              icon: const Icon(Icons.payment),
              label: const Text(
                "PROSES PEMBAYARAN",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Belanja"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: CartManager.items.isEmpty
                ? _buildEmptyCart()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                      return Future.value();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: CartManager.items.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(CartManager.items[index]);
                      },
                    ),
                  ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }
}
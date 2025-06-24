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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil")));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.items;

    return Column(
      children: [
        Expanded(
          child:
              cart.isEmpty
                  ? const Center(child: Text("Keranjang kosong"))
                  : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: Text(item.name),
                        subtitle: Text("Rp ${item.price} x ${item.quantity}"),
                        trailing: Text(
                          "Rp ${(item.price * item.quantity).toStringAsFixed(0)}",
                        ),
                      );
                    },
                  ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Total: Rp ${CartManager.total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: cart.isEmpty ? null : checkout,
                icon: const Icon(Icons.payment),
                label: const Text("Bayar Sekarang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

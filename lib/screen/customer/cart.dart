// lib/screen/customer/cart.dart

import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk simulasi
    final cartItems = [
      {'name': 'Kemeja Pria', 'price': 120000.00, 'qty': 1},
      {'name': 'Powerbank 10000mAh', 'price': 250000.00, 'qty': 1},
    ];

    double totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] as double) * (item['qty'] as int),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child:
                cartItems.isEmpty
                    ? const Center(child: Text("Keranjang Anda kosong."))
                    : ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return ListTile(
                          title: Text(item['name'] as String),
                          subtitle: Text(
                            "Rp ${(item['price'] as double).toStringAsFixed(0)}",
                          ),
                          trailing: Text("x ${item['qty'] as int}"),
                        );
                      },
                    ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Harga:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Rp ${totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed:
                      cartItems.isEmpty
                          ? null
                          : () {
                            // Simulasi pembayaran
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Pembayaran Berhasil"),
                                  content: const Text(
                                    "Terima kasih! Pesanan Anda akan segera diproses.",
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                  child: const Text("Bayar Sekarang"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

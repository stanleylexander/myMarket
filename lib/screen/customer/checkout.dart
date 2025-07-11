import 'package:flutter/material.dart';
import 'package:my_market/class/cart_item.dart';
import 'package:my_market/class/cart_manager.dart';
import 'package:my_market/screen/customer/home.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> items;

  const CheckoutScreen({super.key, required this.items});

  double get total =>
      items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void handleFakeCheckout(BuildContext context) {
    CartManager.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeCustomer()),
      (route) => false,
    );
  }

  String formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("x${item.quantity}"),
                  trailing: Text(
                    "Rp ${formatRupiah(item.price * item.quantity)}",
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontSize: 18)),
                    Text(
                      "Rp ${formatRupiah(total)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => handleFakeCheckout(context),
                    child: const Text("BAYAR", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_market/class/cart_item.dart';
import 'package:my_market/class/cart_manager.dart';
import 'package:my_market/screen/customer/checkout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading:
            item.image.isNotEmpty
                ? Image.network(item.image, width: 50, height: 50)
                : const Icon(Icons.shopping_bag),
        title: Text(item.name),
        subtitle: Text(
          "Rp ${(item.price).toStringAsFixed(0)} x ${item.quantity}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  CartManager.decreaseQuantity(item);
                });
              },
            ),
            Text(item.quantity.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  CartManager.increaseQuantity(item);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
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

  Widget _buildEmptyCart() {
    return const Center(child: Text("Keranjang kosong"));
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total: ", style: TextStyle(fontSize: 18)),
              Text(
                "Rp ${CartManager.total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  CartManager.items.isEmpty
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CheckoutScreen(
                                  items: List.from(CartManager.items),
                                ),
                          ),
                        ).then((_) => setState(() {}));
                      },
              child: const Text("PROSES PEMBAYARAN"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja")),
      body: Column(
        children: [
          Expanded(
            child:
                CartManager.items.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                      itemCount: CartManager.items.length,
                      itemBuilder:
                          (context, index) =>
                              _buildCartItem(CartManager.items[index]),
                    ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }
}

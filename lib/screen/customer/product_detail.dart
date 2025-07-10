import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/chat.dart';
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
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160422024/myMarket_productDetail.php"),
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
            errorMessage = jsonResponse['message'] ?? 'Failed to load product';
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to connect to server';
        isLoading = false;
      });
    }
  }

  Widget _buildCategoryChips(List<Category> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: categories
          .map((cat) => Chip(
                label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildImageSection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: product!.image.isNotEmpty
          ? Image.network(
              product!.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Gambar tidak tersedia', 
                        style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Icon(Icons.shopping_bag, size: 80, color: Colors.grey[400]),
            ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product!.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Rp ${product!.price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
            (Match m) => '${m[1]}.',
          )}",
          style: TextStyle(
            fontSize: 22,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Stok: ${product!.stock}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jumlah:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (quantity > 1) {
                  setState(() => quantity--);
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (quantity < product!.stock) {
                  setState(() => quantity++);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stok tidak mencukupi')),
                  );
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Produk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product!.description.isNotEmpty 
            ? product!.description 
            : 'Tidak ada deskripsi produk',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.shopping_cart),
        label: const Text(
          'Tambah ke Keranjang',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          CartManager.add(
            CartItem(
              productId: product!.id,
              name: product!.name,
              price: product!.price,
              quantity: quantity,
              image: product!.image,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Produk ditambahkan ke keranjang'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Image
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: _buildImageSection(),
            ),
          ),
          
          // Right side - Details
          Flexible(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                _buildQuantitySelector(),
                const SizedBox(height: 24),
                _buildDescriptionSection(),
                const SizedBox(height: 24),
                if (product!.category != null && product!.category!.isNotEmpty) ...[
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryChips(product!.category!),
                  const SizedBox(height: 24),
                ],
                _buildAddToCartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildHeaderSection(),
          const SizedBox(height: 16),
          _buildQuantitySelector(),
          const SizedBox(height: 24),
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          if (product!.category != null && product!.category!.isNotEmpty) ...[
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryChips(product!.category!),
            const SizedBox(height: 24),
          ],
          _buildAddToCartButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 229, 227, 233),
        child: const Icon(Icons.chat),
        tooltip: 'Chat Penjual',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchProductDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }
}
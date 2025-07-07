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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchCategories();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
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
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to connect API');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    }
  }

  void _filterProducts(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      if (categoryId == null) {
        filteredProducts = allProducts;
      } else {
        filteredProducts = allProducts.where((p) {
          return p.category?.any((c) => c.id == categoryId) ?? false;
        }).toList();
      }
    });
  }

  Widget _buildProductGridItem(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: product.image.isNotEmpty
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Rp ${product.price.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 13),
            Text(
              allProducts.isEmpty ? "Loading products..." : "No products found",
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (allProducts.isNotEmpty)
              TextButton(
                onPressed: () => _filterProducts(null),
                child: const Text('Reset filter'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // 6 columns
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75, // Adjust height box
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return _buildProductGridItem(filteredProducts[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    border: InputBorder.none,
                  ),
                  value: selectedCategoryId,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text("All Categories"),
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
            ),
          ),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }
}
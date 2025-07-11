import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/category.dart';
import 'package:my_market/class/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;

  List<Category> _allCategories = [];
  List<int> _selectedCategoryIds = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  // State untuk validasi gambar dari kode lama Anda
  bool _validImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _imageController = TextEditingController(text: widget.product.image);

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.product.image.isNotEmpty) {
      _validImage = await validateImage(widget.product.image);
    }

    await _fetchCategories();
    if (widget.product.category != null) {
      setState(() {
        _selectedCategoryIds =
            widget.product.category!.map((cat) => cat.id).toList();
      });
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://ubaya.xyz/flutter/160422029/myMarket_listcategory.php',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allCategories =
                body.map((item) => Category.fromJson(item)).toList();
          });
        }
      }
    } catch (e) {
      // Error handling
    }
  }

  // Logika validasi gambar dari kode lama Anda
  Future<bool> validateImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return false;
      final contentType = response.headers['content-type'];
      return contentType != null &&
          (contentType.contains('image/png') ||
              contentType.contains('image/jpeg') ||
              contentType.contains('image/gif'));
    } catch (_) {
      return false;
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse(
          "https://ubaya.xyz/flutter/160422029/myMarket_editProduct.php",
        ),
        body: {
          'id': widget.product.id.toString(),
          'name': _nameController.text,
          'description': _descController.text,
          'price': _priceController.text,
          'stock': _stockController.text,
          'image': _imageController.text,
          'categories': jsonEncode(_selectedCategoryIds),
        },
      );

      if (mounted) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        } else {
          final errorMessage =
              jsonResponse['message'] ??
              jsonResponse['error'] ??
              'Terjadi error tidak diketahui';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children:
              _allCategories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategoryIds.add(category.id);
                      } else {
                        _selectedCategoryIds.remove(category.id);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Produk")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Produk',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Nama harus diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                        ),
                        minLines: 3,
                        maxLines: 5,
                        validator:
                            (value) =>
                                value!.length < 10
                                    ? 'Deskripsi minimal 10 karakter'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Harga'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Harga tidak valid' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Stok tidak valid' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar',
                        ),
                        onChanged: (value) {
                          validateImage(value).then((isValid) {
                            if (mounted) {
                              setState(() {
                                _validImage = isValid;
                              });
                            }
                          });
                        },
                        validator:
                            (value) =>
                                value == null ||
                                        value.isEmpty ||
                                        !_validImage ||
                                        !Uri.parse(value).isAbsolute
                                    ? 'URL gambar tidak valid'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      if (_validImage)
                        Image.network(
                          _imageController.text,
                          height: 150,
                          fit: BoxFit.contain,
                        )
                      else
                        const Text('Gambar tidak valid atau belum dimasukkan'),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 20),
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _updateProduct,
                            child: const Text('Simpan Perubahan'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}

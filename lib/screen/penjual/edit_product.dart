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
      _selectedCategoryIds =
          widget.product.category!.map((cat) => cat.id).toList();
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
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['result'] == 'success') {
          if (mounted) {
            setState(() {
              _allCategories =
                  (body['data'] as List)
                      .map((item) => Category.fromJson(item))
                      .toList();
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat kategori: $e")));
      }
    }
  }

  Future<bool> validateImage(String url) async {
    try {
      if (!Uri.parse(url).isAbsolute) return false;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${jsonResponse['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
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
        const Text(
          "Kategori",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'URL Gambar tidak boleh kosong';
                          }
                          if (!_validImage) {
                            return 'URL gambar tidak valid atau tidak dapat diakses';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (_imageController.text.isNotEmpty)
                        _validImage
                            ? Image.network(
                              _imageController.text,
                              height: 150,
                              fit: BoxFit.contain,
                            )
                            : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Memvalidasi URL...'),
                            ),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 20),
                      _isSubmitting
                          ? const Center(child: CircularProgressIndicator())
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

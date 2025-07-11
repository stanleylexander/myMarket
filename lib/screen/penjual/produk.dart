import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputProductPage extends StatefulWidget {
  const InputProductPage({super.key});

  @override
  State<InputProductPage> createState() => _InputProductPageState();
}

class _InputProductPageState extends State<InputProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '',
      _description = '',
      _price = '',
      _stock = '',
      _imageUrl = '',
      _userId = '';

  List<Category> _allCategories = [];
  final List<int> _selectedCategoryIds = [];

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _validImage = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id') ?? '';
    await _fetchCategories();
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
    } catch (e) {}
  }

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

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse(
          'https://ubaya.xyz/flutter/160422029/myMarket_addproduct.php',
        ),
        body: {
          'name': _name,
          'description': _description,
          'price': _price,
          'stock': _stock,
          'image': _imageUrl,
          'user_id': _userId,
          'categories': jsonEncode(_selectedCategoryIds),
        },
      );

      if (mounted) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal: ${json['message'] ?? 'Error tidak diketahui'}',
              ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
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
                        decoration: const InputDecoration(
                          labelText: 'Nama Produk',
                        ),
                        onChanged: (v) => _name = v,
                        validator:
                            (v) => v!.isEmpty ? 'Nama harus diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                        ),
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (v) => _description = v,
                        validator:
                            (v) =>
                                v!.length < 10
                                    ? 'Deskripsi minimal 10 karakter'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Harga'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) => _price = v,
                        validator:
                            (v) => v!.isEmpty ? 'Harga tidak valid' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Stok'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) => _stock = v,
                        validator:
                            (v) => v!.isEmpty ? 'Stok tidak valid' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar',
                        ),
                        onChanged: (value) {
                          validateImage(value).then((isValid) {
                            if (mounted) {
                              setState(() {
                                _imageUrl = value;
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
                          _imageUrl,
                          height: 150,
                          fit: BoxFit.contain,
                        )
                      else
                        const Text(
                          'Gambar tidak valid, error di CORS atau belum dimasukkan',
                        ),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 20),
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _submitProduct,
                            child: const Text('Simpan Produk'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}

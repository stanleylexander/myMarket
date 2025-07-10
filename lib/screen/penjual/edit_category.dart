import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const EditCategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryName);
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse(
          'https://ubaya.xyz/flutter/160422029/myMarket_editcategory.php',
        ),
        body: {
          'id': widget.categoryId.toString(),
          'name': _nameController.text,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal update: ${json['message']}')),
          );
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Kategori')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Nama harus diisi'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCategory,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

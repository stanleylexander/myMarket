import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InputProductPage extends StatefulWidget {
  const InputProductPage({super.key});

  @override
  State<InputProductPage> createState() => _InputProductPageState();
}

class _InputProductPageState extends State<InputProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _price = '';
  String _stock = '';
  String _imageUrl = '';
  int _user_id = 0;

  bool _validImage = false;

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

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _user_id = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
    });
  }


  void submit() async {
    final response = await http.post(
      Uri.parse(
        'https://ubaya.xyz/flutter/160422029/myMarket_addproduct.php',
      ), // 🔧 Ganti sesuai API-mu
      body: {
        'name': _name,
        'description': _description,
        'price': _price,
        'stock': _stock,
        'image': _imageUrl,
        'user_id': _user_id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan produk')),
        );
      }
    } else {
      throw Exception('Gagal koneksi ke server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                onChanged: (value) => _name = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama harus diisi'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                minLines: 3,
                maxLines: 5,
                onChanged: (value) => _description = value,
                validator:
                    (value) =>
                        value == null || value.length < 10
                            ? 'Deskripsi minimal 10 karakter'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _price = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Harga tidak valid'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _stock = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Stok tidak valid'
                            : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                onChanged: (value) {
                  validateImage(value).then((isValid) {
                    setState(() {
                      _imageUrl = value;
                      _validImage = isValid;
                    });
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
                Image.network(_imageUrl, height: 150, fit: BoxFit.contain)
              else
                const Text('Gambar tidak valid atau belum dimasukkan'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submit();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Periksa kembali isian")),
                    );
                  }
                },
                child: const Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

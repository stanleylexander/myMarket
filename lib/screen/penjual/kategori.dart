import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final _formKey = GlobalKey<FormState>();
  List kategoriList = [];
  String _name = '';
  int? _editingId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  Future<void> fetchKategori() async {
    final res = await http.get(
      Uri.parse(
        'https://ubaya.xyz/flutter/160422029/myMarket_listcategory.php',
      ),
    );

    if (res.statusCode == 200) {
      setState(() {
        kategoriList = jsonDecode(res.body);
        isLoading = false;
        _editingId = null;
        _name = '';
      });
    }
  }

  Future<void> submitKategori() async {
    final url =
        _editingId == null
            ? 'https://ubaya.xyz/flutter/160422029/myMarket_addcategory.php'
            : 'https://ubaya.xyz/flutter/160422029/myMarket_editCategory.php';

    final res = await http.post(
      Uri.parse(url),
      body: {'id': _editingId?.toString() ?? '', 'name': _name},
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingId == null
                  ? 'Kategori berhasil ditambahkan'
                  : 'Kategori diperbarui',
            ),
          ),
        );
        fetchKategori();
      }
    }
  }

  Future<void> deleteKategori(int id) async {
    final res = await http.post(
      Uri.parse(
        'https://ubaya.xyz/flutter/160422029/myMarket_deleteCategory.php',
      ),
      body: {'id': id.toString()},
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['result'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
        fetchKategori();
      }
    }
  }

  void startEdit(Map kategori) {
    setState(() {
      _editingId = kategori['id'];
      _name = kategori['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Kategori")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _name,
                              decoration: const InputDecoration(
                                labelText: 'Nama Kategori',
                              ),
                              onChanged: (value) => _name = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submitKategori();
                              }
                            },
                            child: Text(
                              _editingId == null ? 'Tambah' : 'Update',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    ...kategoriList.map((kategori) {
                      return ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(kategori['name']),
                        subtitle: Text("ID: ${kategori['id']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => startEdit(kategori),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => deleteKategori(kategori['id']),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}

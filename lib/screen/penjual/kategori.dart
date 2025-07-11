import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_market/class/category.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final _formKey = GlobalKey<FormState>();
  List<Category> kategoriList = [];
  String _name = '';
  int? _editingId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  Future<void> fetchKategori() async {
    setState(() {
      isLoading = true;
    });
    try {
      final res = await http.get(
        Uri.parse(
          'https://ubaya.xyz/flutter/160422029/myMarket_listcategory.php',
        ),
      );

      if (res.statusCode == 200) {
        final List<dynamic> body = jsonDecode(res.body);
        setState(() {
          kategoriList = body.map((item) => Category.fromJson(item)).toList();
          _editingId = null;
          _name = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitKategori() async {
    final url =
        _editingId == null
            ? 'https://ubaya.xyz/flutter/160422029/myMarket_addCategory.php'
            : 'https://ubaya.xyz/flutter/160422029/myMarket_editCategory.php';

    try {
      final res = await http.post(
        Uri.parse(url),
        body: {'id': _editingId?.toString() ?? '', 'name': _name},
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['result'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingId == null
                    ? 'Kategori berhasil ditambahkan'
                    : 'Kategori berhasil diperbarui',
              ),
            ),
          );
          fetchKategori(); // Muat ulang daftar kategori
        } else {
          throw Exception(json['message'] ?? 'Alasan tidak diketahui');
        }
      } else {
        throw Exception("Gagal terhubung ke server");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  Future<void> deleteKategori(int id) async {
    try {
      final res = await http.post(
        Uri.parse(
          // DIUBAH: Nama file PHP diseragamkan menjadi huruf kecil semua
          'https://ubaya.xyz/flutter/160422029/myMarket_deleteCategory.php',
        ),
        body: {'id': id.toString()},
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['result'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil dihapus')),
          );
          fetchKategori(); // Muat ulang daftar kategori
        } else {
          throw Exception(json['message'] ?? 'Alasan tidak diketahui');
        }
      } else {
        throw Exception("Gagal terhubung ke server");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }

  void startEdit(Category kategori) {
    setState(() {
      _editingId = kategori.id;
      _name = kategori.name;
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _editingId == null
                          ? "Tambah Kategori Baru"
                          : "Edit Kategori",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              // Gunakan controller untuk update UI secara dinamis
                              controller: TextEditingController(text: _name)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: _name.length),
                                ),
                              decoration: const InputDecoration(
                                labelText: 'Nama Kategori',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => _name = value,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _editingId == null ? 'Tambah' : 'Update',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_editingId != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _editingId = null;
                            _name = '';
                          });
                        },
                        child: const Text("Batal Edit"),
                      ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    ...kategoriList.map((kategori) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.category_outlined),
                          title: Text(kategori.name),
                          subtitle: Text("ID: ${kategori.id}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () => startEdit(kategori),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => deleteKategori(kategori.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}

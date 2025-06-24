import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'addcategory.dart'; // ✅ Make sure this path is correct

class ListKategoriPage extends StatefulWidget {
  const ListKategoriPage({super.key});

  @override
  State<ListKategoriPage> createState() => _ListKategoriPageState();
}

class _ListKategoriPageState extends State<ListKategoriPage> {
  List kategoriList = [];
  bool isLoading = true;

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
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: kategoriList.length,
                itemBuilder: (context, index) {
                  final kategori = kategoriList[index];
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(kategori['name']),
                    subtitle: Text("ID: ${kategori['id']}"),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryPage()),
          );
          fetchKategori(); // Refresh after return
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Kategori',
      ),
    );
  }
}

import 'category.dart';

class Product {
  int id;
  String name;
  String description;
  double price;
  int stock;
  String image;
  List<Category>? category;
  String? sellerName;
  int? sellerId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.category,
    this.sellerName,
    this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      stock: int.parse(json['stock'].toString()),
      image: json['image'] ?? '',
      category:
          (json['category'] as List?)
              ?.map((e) => Category.fromJson(e))
              .toList(),

      sellerName: json['seller_name'],
      sellerId:
          json['seller_id'] != null
              ? int.parse(json['seller_id'].toString())
              : null,
    );
  }
}

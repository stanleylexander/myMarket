import 'package:my_market/class/category.dart';

class Product {
  int id;
  String name;
  String description;
  double price;
  int stock;
  String image;
  List<Category>? category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock, 
    required this.image,
    this.category
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
      id: json['id'], 
      name: json['name'], 
      description: json['description'], 
      price: json['price'], 
      stock: json['stock'], 
      image: json['image'],
      category: (json['categories'] as List?)?.map((e) => Category.fromJson(e)).toList(),
    );
  }
}
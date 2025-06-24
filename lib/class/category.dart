class Category {
  int id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: int.parse(json['id'].toString()), name: json['name']);
  }
}

class CartItem {
  int productId;
  String name;
  double price;
  int quantity;
  String image;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "quantity": quantity,
    "price": price,
  };
}

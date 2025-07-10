import 'package:my_market/class/cart_item.dart';

class CartManager {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void increaseQuantity(CartItem item) {
    var index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index].quantity += 1;
    }
  }

  static void decreaseQuantity(CartItem item) {
    var index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index); // jika quantity 1, langsung hapus
      }
    }
  }

  static void removeItem(CartItem item) {
    _items.removeWhere((i) => i.productId == item.productId);
  }


  static void add(CartItem item) {
    var index = _items.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
  }

  static void remove(int productId) {
    _items.removeWhere((item) => item.productId == productId);
  }

  static void clear() {
    _items.clear();
  }

  static double get total =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);
}

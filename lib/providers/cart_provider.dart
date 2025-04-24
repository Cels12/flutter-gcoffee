import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  bool addToCart(Map<String, dynamic> item) {
    debugPrint('Mencoba menambahkan item ke keranjang $item');
    int existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem['id'] == item['id'],
    );
    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += 1;
      debugPrint("Item sudah ada di keranjang.");
      return false;
    } else {
      item['quantity'] = 1;
      _cartItems.add(item);
      notifyListeners();
      debugPrint("Item berhasil ditambahkan: ${item['nama_menu']}");
      return true;
    }
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    _cartItems[index]['quantity'] = newQuantity;
    notifyListeners();
  }

  double getTotalPrice() {
    return _cartItems.fold(
      0,
      (total, item) => total + (item['harga'] * item['quantity']),
    );
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

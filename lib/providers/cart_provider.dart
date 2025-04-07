import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem['id'] == item['id'],
    );
    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += 1;
    } else {
      _cartItems.add({
        'id': item['id'],
        'name': item['nama_menu'],
        'harga': item['harga'],
        'quantity': 1,
      });
    }
    notifyListeners();
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

import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items =>
      _items.map((item) => Map<String, dynamic>.from(item)).toList();

  int get itemCount =>
      _items.fold(0, (total, item) => total + (item['quantity'] as int));

  double get totalAmount {
    return _items.fold(0.0, (total, item) {
      return total +
          (item['price'] as num).toDouble() * (item['quantity'] as int);
    });
  }

  void addToCart(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['id'] == product['id']);

    if (index >= 0) {
      _items[index]['quantity']++;
    } else {
      _items.add({
        'id': product['id'],
        'title': product['title'],
        'price': (product['price'] as num).toDouble(),
        'imageUrl': product['imageUrl'] ?? '',
        'quantity': 1,
      });
    }

    notifyListeners();
  }

  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _items[index]['quantity']++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item['id'] == id);

    if (index >= 0) {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity']--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

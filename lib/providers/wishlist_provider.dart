import 'package:flutter/material.dart';

import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final Map<String, ProductModel> _items = {};

  List<ProductModel> get items => _items.values.toList();

  int get itemCount => _items.length;

  bool isFavorite(String productId) {
    return _items.containsKey(productId);
  }

  void toggleWishlist(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }

    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}

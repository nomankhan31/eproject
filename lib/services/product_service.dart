import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // All products
  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromDocument(doc))
          .toList();
    });
  }

  // Categories
  Stream<List<String>> getCategoriesStream() {
    return _db.collection('categories').snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => doc.data()['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      categories.sort();
      return categories;
    });
  }

  // Brands
  Stream<List<String>> getBrandsStream() {
    return getProductsStream().map((products) {
      final brands = products
          .map((product) => product.brand.trim())
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      brands.sort();
      return brands;
    });
  }

  // All products - compatibility with HomeScreen
  Stream<List<ProductModel>> getProducts() {
    return getProductsStream();
  }

  // Featured products
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _db
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromDocument(doc))
              .toList();
        });
  }

  // Best sellers
  Stream<List<ProductModel>> getBestSellers() {
    return _db
        .collection('products')
        .where('isBestSeller', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromDocument(doc))
              .toList();
        });
  }
}

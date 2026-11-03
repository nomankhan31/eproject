import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String collection = 'categories';

  Stream<List<CategoryModel>> getCategories() {
    return _db.collection(collection).snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromDocument(doc))
          .toList();

      categories.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return categories;
    });
  }

  Future<void> addCategory({
    required String name,
    required String imageUrl,
  }) async {
    await _db.collection(collection).add({
      'name': name.trim(),
      'imageUrl': imageUrl.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String imageUrl,
  }) async {
    await _db.collection(collection).doc(id).update({
      'name': name.trim(),
      'imageUrl': imageUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}

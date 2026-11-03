import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _banners =>
      _db.collection('banners');

  Stream<List<BannerModel>> getBanners() {
    return _banners.where('isActive', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      final banners = snapshot.docs.map((doc) {
        return BannerModel.fromMap(doc.id, doc.data());
      }).toList();

      banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return banners;
    });
  }

  Stream<List<BannerModel>> getAllBanners() {
    return _banners.snapshots().map((snapshot) {
      final banners = snapshot.docs.map((doc) {
        return BannerModel.fromMap(doc.id, doc.data());
      }).toList();

      banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return banners;
    });
  }

  Future<void> addBanner({
    required String title,
    required String subtitle,
    required String imageUrl,
    required int sortOrder,
  }) async {
    await _banners.add({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBanner({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required int sortOrder,
    required bool isActive,
  }) async {
    await _banners.doc(id).update({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBanner(String id) async {
    await _banners.doc(id).delete();
  }
}

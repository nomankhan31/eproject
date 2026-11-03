import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BannerModel>> getBanners() {
    return _db
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final banners = snapshot.docs.map((doc) {
            return BannerModel.fromMap(doc.id, doc.data());
          }).toList();

          banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return banners;
        });
  }

  Future<void> deleteBanner(String id) async {}

  // ignore: strict_top_level_inference
  getAllBanners() {}

  Future<void> updateBanner({
    // ignore: strict_top_level_inference
    required id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required int sortOrder,
    required bool isActive,
  }) async {}

  Future<void> addBanner({
    required String title,
    required String subtitle,
    required String imageUrl,
    required int sortOrder,
  }) async {}
}

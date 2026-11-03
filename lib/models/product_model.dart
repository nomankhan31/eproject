import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final String imageUrl;
  final List<String> images;
  final double price;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isBestSeller;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.brand = '',
    required this.imageUrl,
    this.images = const [],
    required this.price,
    this.rating = 0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.createdAt,
  });

  factory ProductModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      price: (data['price'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isBestSeller: data['isBestSeller'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

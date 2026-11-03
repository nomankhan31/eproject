import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product_model.dart';
import '../screens/user/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 135,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.watch, size: 55, color: Colors.grey),
                  ),
                ),
                if (product.isBestSeller)
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'BEST SELLER',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFFFB800)),
                const SizedBox(width: 3),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  ' (${product.reviewCount})',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              'Rs. ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFFB8860B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

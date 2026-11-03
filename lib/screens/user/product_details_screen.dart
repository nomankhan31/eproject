import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.imageUrl];

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.watch, size: 90),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFB8860B),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Rs. ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFB8860B),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(' ${product.rating} (${product.reviewCount} reviews)'),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              product.description,
              style: const TextStyle(color: Colors.black54, height: 1.6),
            ),

            const SizedBox(height: 15),

            Text(
              product.stock > 0 ? 'In Stock: ${product.stock}' : 'Out of Stock',
              style: TextStyle(
                color: product.stock > 0 ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton.icon(
                onPressed: product.stock > 0
                    ? () {
                        context.read<CartProvider>().addToCart({
                          'id': product.id,
                          'title': product.title,
                          'price': product.price,
                          'imageUrl': product.imageUrl,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart!'),
                            backgroundColor: Colors.green,
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('ADD TO CART'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

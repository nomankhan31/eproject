import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 280,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.watch, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              product.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Rs. ${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(product.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            Text('Category: ${product.category}'),
            const SizedBox(height: 8),
            Text('Brand: ${product.brand}'),
            const SizedBox(height: 8),
            Text('Stock: ${product.stock}'),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: product.stock <= 0
                    ? null
                    : () {
                        context.read<CartProvider>().addToCart({
                          'id': product.id,
                          'title': product.title,
                          'price': product.price,
                          'imageUrl': product.imageUrl,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Watch added to cart!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                icon: const Icon(Icons.shopping_cart),
                label: Text(
                  product.stock <= 0 ? 'Out of Stock' : 'Add to Cart',
                ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wishlist_provider.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, child) {
        final products = wishlist.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Wishlist'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 75, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Your wishlist is empty',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailsScreen(product: product),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.watch),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Rs. ${product.price}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                wishlist.removeFromWishlist(product.id);
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

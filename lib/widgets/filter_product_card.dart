import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product_model.dart';
import '../screens/user/product_details_screen.dart';

class FilterProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isGrid;

  const FilterProductCard({
    super.key,
    required this.product,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: isGrid ? _gridCard() : _listCard(),
      ),
    );
  }

  Widget _image({double? height, double? width}) {
    return CachedNetworkImage(
      imageUrl: product.imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (_, _) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, _, _) => const Icon(Icons.watch),
    );
  }

  Widget _gridCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(width: double.infinity, child: _image()),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(product.brand, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                'Rs. ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 15, color: Colors.amber),
                  Text(' ${product.rating.toStringAsFixed(1)}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listCard() {
    return SizedBox(
      height: 125,
      child: Row(
        children: [
          SizedBox(width: 120, height: 125, child: _image()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product.brand,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${product.rating.toStringAsFixed(1)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

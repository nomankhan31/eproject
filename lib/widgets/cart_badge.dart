import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const CartBadge({
    super.key,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: iconColor,
                size: 27,
              ),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 19,
                    minHeight: 19,
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

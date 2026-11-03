import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onCartTap;

  const HomeHeader({super.key, required this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.watch, color: Color(0xFFD4AF37), size: 28),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WATCHHUB',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 17,
                ),
              ),
              Text(
                'TIMELESS ELEGANCE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onCartTap,
          icon: const Icon(Icons.shopping_bag_outlined, size: 27),
        ),
      ],
    );
  }
}

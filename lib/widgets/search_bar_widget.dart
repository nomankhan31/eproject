import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search watches, brands...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Icon(Icons.tune, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

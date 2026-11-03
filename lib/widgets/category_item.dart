import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFF1C9)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: const Color(0xFFB8860B), width: 2)
                    : null,
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const Icon(Icons.watch),
                      )
                    : const Icon(
                        Icons.watch,
                        color: Color(0xFFB8860B),
                        size: 30,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

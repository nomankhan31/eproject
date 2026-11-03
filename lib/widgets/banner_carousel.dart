import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/banner_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();

  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF171717),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          color: const Color(0xFF171717),
                          child: const Icon(
                            Icons.watch,
                            color: Color(0xFFD4AF37),
                            size: 60,
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),

                      Positioned(
                        left: 20,
                        top: 35,
                        right: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner.subtitle,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: currentIndex == index ? 22 : 7,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? const Color(0xFFB8860B)
                    : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

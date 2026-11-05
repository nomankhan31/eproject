import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}

const List<OnboardingModel> onboardingPages = [
  OnboardingModel(
    title: 'Discover Your Style',
    description:
        'Explore a premium collection of watches '
        'designed to match your personality.',
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=900',
    icon: Icons.watch,
  ),

  OnboardingModel(
    title: 'Premium Collection',
    description:
        'Find elegant, classic and modern watches '
        'crafted for every special moment.',
    image: 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=900',
    icon: Icons.diamond_outlined,
  ),

  OnboardingModel(
    title: 'Shop With Confidence',
    description:
        'Enjoy a simple shopping experience, '
        'secure checkout and reliable delivery.',
    image: 'https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=900',
    icon: Icons.local_shipping_outlined,
  ),
];

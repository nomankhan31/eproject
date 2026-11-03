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
    image: 'assets/images/onboarding1.png',
    icon: Icons.watch,
  ),

  OnboardingModel(
    title: 'Premium Collection',
    description:
        'Find elegant, classic and modern watches '
        'crafted for every special moment.',
    image: 'assets/images/onboarding2.png',
    icon: Icons.diamond_outlined,
  ),

  OnboardingModel(
    title: 'Shop With Confidence',
    description:
        'Enjoy a simple shopping experience, '
        'secure checkout and reliable delivery.',
    image: 'assets/images/onboarding3.png',
    icon: Icons.local_shipping_outlined,
  ),
];

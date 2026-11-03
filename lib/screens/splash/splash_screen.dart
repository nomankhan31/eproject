import 'package:flutter/material.dart';

import '../../services/onboarding_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    navigateUser();
  }

  Future<void> navigateUser() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final completed = await OnboardingService.isCompleted();

      if (!mounted) return;

      final destination = completed
          ? const AuthGate()
          : const OnboardingScreen();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 125,
                  width: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFB8860B),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.watch,
                    size: 75,
                    color: Color(0xFFD4AF37),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'WATCHHUB',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'TIMELESS ELEGANCE',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 60),

                const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/onboarding_service.dart';
import '../../widgets/onboarding_page.dart';
import '../splash/auth_gate.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;
  bool isFinishing = false;

  Future<void> finishOnboarding() async {
    if (isFinishing) return;

    setState(() => isFinishing = true);

    try {
      await OnboardingService.completeOnboarding();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isFinishing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save onboarding progress.')),
      );
    }
  }

  void nextPage() {
    if (currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'WATCHHUB',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  if (!isLastPage)
                    TextButton(
                      onPressed: finishOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    )
                  else
                    const SizedBox(width: 50),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];

                  return OnboardingPage(
                    title: page.title,
                    description: page.description,
                    image: page.image,
                    icon: page.icon,
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingPages.length, (index) {
                final active = currentPage == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: active ? 28 : 8,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFFB8860B) : Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isFinishing ? null : nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isFinishing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isLastPage ? 'GET STARTED' : 'NEXT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

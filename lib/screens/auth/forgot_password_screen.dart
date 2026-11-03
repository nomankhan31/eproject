import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetLink() async {
    if (emailController.text.trim().isEmpty) return;

    try {
      await context.read<AuthProvider>().resetPassword(
        emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Color(0xFFB8860B)),

            const SizedBox(height: 20),

            const Text(
              'Reset Your Password',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Enter your registered email address '
              'to receive a password reset link.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendResetLink,
                child: const Text('SEND RESET LINK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

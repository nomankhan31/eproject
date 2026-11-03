import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import '../user/home_screen.dart';
import '../admin/admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('User profile not found')),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final role = data['role'];

            if (role == 'admin') {
              return const AdminDashboard();
            }

            if (role == 'user') {
              return const HomeScreen();
            }

            return const Scaffold(
              body: Center(child: Text('Invalid user role')),
            );
          },
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

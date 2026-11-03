import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watchhub/screens/customer/order_history_screen.dart';

import '../../services/auth_service.dart';

import 'order_tracking_screen.dart';
import 'wishlist_screen.dart';
import 'support_screen.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService authService = AuthService();

  Future<void> logout(BuildContext context) async {
    await authService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login first.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};

          final name =
              data['name']?.toString() ?? user.displayName ?? 'Customer';

          final email = data['email']?.toString() ?? user.email ?? '';

          final phone = data['phone']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 15),

              // Profile Image
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.black,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Email
              Center(
                child: Text(email, style: const TextStyle(color: Colors.grey)),
              ),

              // Phone
              if (phone.isNotEmpty)
                Center(
                  child: Text(
                    phone,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 25),

              const Divider(),

              // Edit Profile
              profileOption(
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your name and phone number',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),

              const Divider(),

              // Personal Information
              profileOption(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'View your account details',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Personal Information'),
                      content: Text(
                        'Name: $name\n'
                        'Email: $email\n'
                        'Phone: ${phone.isEmpty ? 'Not provided' : phone}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(),

              // My Orders
              profileOption(
                icon: Icons.shopping_bag_outlined,
                title: 'My Orders',
                subtitle: 'View your previous orders',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),

              const Divider(),

              // Track Orders
              profileOption(
                icon: Icons.local_shipping_outlined,
                title: 'Track My Orders',
                subtitle: 'Check your order status',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderTrackingScreen()),
                  );
                },
              ),

              const Divider(),

              // Wishlist
              profileOption(
                icon: Icons.favorite_border,
                title: 'My Wishlist',
                subtitle: 'Your favourite watches',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),

              const Divider(),

              // Customer Support
              profileOption(
                icon: Icons.support_agent,
                title: 'Customer Support',
                subtitle: 'Contact our support team',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),

              const Divider(),

              // Logout
              profileOption(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from your account',
                color: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'WATCHHUB',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

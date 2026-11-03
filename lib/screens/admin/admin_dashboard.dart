import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import 'order_management_screen.dart';
import 'product_management_screen.dart';
import 'category_management_screen.dart';
import 'banner_management_screen.dart';
import 'customer_management_screen.dart';
import 'support_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Watchhub Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, productSnapshot) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, orderSnapshot) {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'user')
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (productSnapshot.hasError ||
                      orderSnapshot.hasError ||
                      userSnapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load dashboard data'),
                    );
                  }

                  if (!productSnapshot.hasData ||
                      !orderSnapshot.hasData ||
                      !userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = productSnapshot.data!.docs.length;
                  final orders = orderSnapshot.data!.docs.length;
                  final customers = userSnapshot.data!.docs.length;

                  double revenue = 0;

                  for (final doc in orderSnapshot.data!.docs) {
                    final data = doc.data();

                    if (data['status'] != 'cancelled') {
                      revenue += (data['totalAmount'] as num?)?.toDouble() ?? 0;
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            _statCard(
                              'Products',
                              products,
                              Icons.watch,
                              Colors.blue,
                            ),
                            _statCard(
                              'Orders',
                              orders,
                              Icons.shopping_bag,
                              Colors.green,
                            ),
                            _statCard(
                              'Customers',
                              customers,
                              Icons.people,
                              Colors.orange,
                            ),
                            _statCard(
                              'Revenue',
                              revenue,
                              Icons.currency_exchange,
                              Colors.purple,
                              isRevenue: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _menuTile(
                          context,
                          'Product Management',
                          Icons.inventory_2,
                          () => openScreen(
                            context,
                            const ProductManagementScreen(),
                          ),
                        ),

                        _menuTile(
                          context,
                          'Category Management',
                          Icons.category,
                          () => openScreen(
                            context,
                            const CategoryManagementScreen(),
                          ),
                        ),

                        _menuTile(
                          context,
                          'Banner Management',
                          Icons.image,
                          () => openScreen(
                            context,
                            const BannerManagementScreen(),
                          ),
                        ),

                        _menuTile(
                          context,
                          'Order Management',
                          Icons.receipt_long,
                          () => openScreen(
                            context,
                            const OrderManagementScreen(),
                          ),
                        ),

                        _menuTile(
                          context,
                          'Customer Management',
                          Icons.people,
                          () => openScreen(
                            context,
                            const CustomerManagementScreen(),
                          ),
                        ),

                        _menuTile(
                          context,
                          'Support Desk',
                          Icons.support_agent,
                          () => openScreen(
                            context,
                            const SupportManagementScreen(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _statCard(
    String title,
    num value,
    IconData icon,
    Color color, {
    bool isRevenue = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              isRevenue ? 'Rs. ${value.toStringAsFixed(0)}' : value.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB8860B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

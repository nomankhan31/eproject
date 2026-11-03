import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 75, color: Colors.grey),
            SizedBox(height: 15),
            Text(
              'Your Cart is Empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Add your favorite watches here.'),
          ],
        ),
      ),
    );
  }
}

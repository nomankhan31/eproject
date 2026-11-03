import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, CartProvider cart) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: cart.items,
          totalAmount: cart.totalAmount,
        ),
      ),
    );

    if (result == true) {
      cart.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cart'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: cart.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 75,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          final id = item['id'].toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: Image.network(
                                item['imageUrl'] ?? '',
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.watch, size: 45),
                              ),
                              title: Text(
                                item['title'] ?? 'Watch',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rs. ${item['price']}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            cart.decreaseQuantity(id),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text('${item['quantity']}'),
                                      IconButton(
                                        onPressed: () =>
                                            cart.increaseQuantity(id),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () => cart.removeItem(id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _checkout(context, cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Proceed to Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

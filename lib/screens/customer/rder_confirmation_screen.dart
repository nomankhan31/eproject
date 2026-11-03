import 'package:flutter/material.dart';

import 'order_tracking_screen.dart';
import 'order_history_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final String paymentMethod;
  final String deliveryAddress;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),

            const SizedBox(height: 20),

            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Thank you for shopping with WATCHHUB.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 25),

                    detailRow('Order ID', orderId),

                    detailRow(
                      'Total Amount',
                      'Rs. ${totalAmount.toStringAsFixed(0)}',
                    ),

                    detailRow('Payment Method', paymentMethod),

                    const SizedBox(height: 10),

                    const Text(
                      'Delivery Address',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 5),

                    Text(deliveryAddress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => OrderTrackingScreen()),
                    (route) => route.isFirst,
                  );
                },
                child: const Text('Track My Order'),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  (route) => route.isFirst,
                );
              },
              child: const Text('View My Orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

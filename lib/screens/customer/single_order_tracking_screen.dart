import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class SingleOrderTrackingScreen extends StatelessWidget {
  final String orderId;

  SingleOrderTrackingScreen({super.key, required this.orderId});

  final OrderService service = OrderService();

  final List<String> steps = ['pending', 'processing', 'shipped', 'delivered'];

  String formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<OrderModel?>(
        stream: service.getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load order'));
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data;

          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final status = order.status.toLowerCase();
          final currentIndex = steps.indexOf(status);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Total: Rs. ${order.totalAmount.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              Text('Payment: ${order.paymentMethod}'),
              Text('Payment Status: ${order.paymentStatus}'),
              const SizedBox(height: 25),

              if (status == 'cancelled')
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Order Cancelled'),
                    subtitle: Text('This order has been cancelled.'),
                  ),
                )
              else
                ...List.generate(steps.length, (index) {
                  final completed = currentIndex >= index && currentIndex >= 0;

                  return ListTile(
                    leading: Icon(
                      completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: completed ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    title: Text(formatStatus(steps[index])),
                    subtitle: Text(
                      [
                        'Your order has been received.',
                        'Your order is being prepared.',
                        'Your order is on the way.',
                        'Your order has been delivered.',
                      ][index],
                    ),
                  );
                }),

              if (currentIndex == -1 && status != 'cancelled')
                Text('Current status: ${formatStatus(status)}'),
            ],
          );
        },
      ),
    );
  }
}

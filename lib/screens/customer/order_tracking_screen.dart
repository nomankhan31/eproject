import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderTrackingScreen extends StatelessWidget {
  OrderTrackingScreen({super.key});

  final OrderService orderService = OrderService();

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int statusStep(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  Widget trackingStep(String title, int index, int currentStep) {
    final completed = index <= currentStep;

    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.circle_outlined,
          color: completed ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: completed ? FontWeight.bold : FontWeight.normal,
            color: completed ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget orderCard(OrderModel order) {
    final status = order.status.toLowerCase();
    final cancelled = status == 'cancelled';
    final currentStep = statusStep(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: statusColor(order.status),
                ),
              ],
            ),

            const Divider(),

            Text(
              'Total: Rs. ${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Text('Customer: ${order.customerName}'),
            Text('Phone: ${order.phone}'),
            Text('Address: ${order.address}'),

            const SizedBox(height: 15),

            if (cancelled)
              const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'This order has been cancelled.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Tracking',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  trackingStep('Pending', 0, currentStep),
                  const SizedBox(height: 12),
                  trackingStep('Processing', 1, currentStep),
                  const SizedBox(height: 12),
                  trackingStep('Shipped', 2, currentStep),
                  const SizedBox(height: 12),
                  trackingStep('Delivered', 3, currentStep),
                ],
              ),

            const SizedBox(height: 10),

            if (order.createdAt != null)
              Text(
                'Order Date: ${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Orders'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getCustomerOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load orders.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('You have no orders yet.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return orderCard(orders[index]);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderService service = OrderService();

  String selectedStatus = 'All';

  final List<String> statuses = [
    'All',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  final List<String> paymentStatuses = [
    'pending',
    'awaiting_payment',
    'paid',
    'failed',
  ];

  String formatStatus(String status) {
    if (status.isEmpty) return 'Pending';

    return status
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
      case 'paid':
        return Colors.green;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'awaiting_payment':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Future<void> changeStatus(OrderModel order, String newStatus) async {
    try {
      await service.updateOrderStatus(order.id, newStatus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${formatStatus(newStatus)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> changePaymentStatus(OrderModel order, String newStatus) async {
    try {
      await service.updatePaymentStatus(order.id, newStatus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment status updated to ${formatStatus(newStatus)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment update failed: $e')));
    }
  }

  Future<void> verifyPayment(OrderModel order) async {
    if (order.paymentStatus == 'paid') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verify Payment'),
          content: Text(
            'Have you confirmed the ${formatStatus(order.paymentMethod)} '
            'payment of Rs. ${order.totalAmount.toStringAsFixed(0)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm Paid'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await changePaymentStatus(order, 'paid');
  }

  void showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Order #${order.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  detailRow('Customer', order.customerName),
                  detailRow('Phone', order.phone),
                  detailRow('Address', order.address),
                  detailRow('Order Status', formatStatus(order.status)),
                  detailRow(
                    'Payment Method',
                    formatStatus(order.paymentMethod),
                  ),
                  detailRow(
                    'Payment Status',
                    formatStatus(order.paymentStatus),
                  ),
                  detailRow(
                    'Total',
                    'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  ),
                  if (order.createdAt != null)
                    detailRow(
                      'Date',
                      order.createdAt!.toLocal().toString().split('.')[0],
                    ),
                  const Divider(height: 25),
                  const Text(
                    'Ordered Products',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (order.items.isEmpty)
                    const Text('No product details available.'),
                  ...order.items.map((item) {
                    if (item is! Map) {
                      return const SizedBox.shrink();
                    }

                    final name = (item['title'] ?? item['name'] ?? 'Product')
                        .toString();

                    final quantity = (item['quantity'] ?? 1).toString();

                    final price = (item['price'] as num?)?.toDouble() ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '$name × $quantity'
                        '   Rs. ${price.toStringAsFixed(0)}',
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Not provided' : value)),
        ],
      ),
    );
  }

  Widget orderCard(OrderModel order) {
    final currentStatus =
        statuses.contains(order.status.toLowerCase()) &&
            order.status.toLowerCase() != 'all'
        ? order.status.toLowerCase()
        : 'pending';

    final currentPaymentStatus = paymentStatuses.contains(order.paymentStatus)
        ? order.paymentStatus
        : 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatStatus(order.status),
                    style: TextStyle(
                      color: statusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.customerName.isEmpty
                  ? 'Customer name unavailable'
                  : order.customerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              order.phone.isEmpty ? 'Phone unavailable' : order.phone,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Rs. ${order.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8860B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.payment, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  formatStatus(order.paymentMethod),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  formatStatus(order.paymentStatus),
                  style: TextStyle(
                    color: statusColor(order.paymentStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 22),

            // Order status
            DropdownButtonFormField<String>(
              initialValue: currentStatus,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Order Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              items: statuses.where((status) => status != 'All').map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(formatStatus(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != order.status.toLowerCase()) {
                  changeStatus(order, value);
                }
              },
            ),

            const SizedBox(height: 12),

            // Payment status
            DropdownButtonFormField<String>(
              initialValue: currentPaymentStatus,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              items: paymentStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(formatStatus(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != order.paymentStatus) {
                  changePaymentStatus(order, value);
                }
              },
            ),

            if (order.paymentStatus != 'paid') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => verifyPayment(order),
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify Payment / Mark Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showOrderDetails(order),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Order Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: Column(
        children: [
          SizedBox(
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: statuses.map((status) {
                final selected = selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(formatStatus(status)),
                    selected: selected,
                    selectedColor: const Color(0xFFB8860B),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: service.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load orders. Check permissions.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data!;

                final filteredOrders = selectedStatus == 'All'
                    ? allOrders
                    : allOrders.where((order) {
                        return order.status.toLowerCase() ==
                            selectedStatus.toLowerCase();
                      }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return orderCard(filteredOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

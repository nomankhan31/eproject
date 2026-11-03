import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';
import 'notification_service.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  // Get all orders
  Stream<List<OrderModel>> getOrders() {
    return _orders.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get current customer's orders
  Stream<List<OrderModel>> getCustomerOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Stream.value([]);

    return _orders.where('userId', isEqualTo: user.uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Get one specific order
  Stream<OrderModel?> getOrderById(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;

      return OrderModel.fromMap(doc.id, doc.data()!);
    });
  }

  // Create new order
  Future<String> createOrder({
    required String userId,
    required String customerName,
    required String phone,
    required String address,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    final doc = await _orders.add({
      'userId': userId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentMethod == 'COD' ? 'pending' : 'awaiting_payment',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // Update order status and notify customer
  Future<void> updateOrderStatus(String orderId, String status) async {
    final orderDoc = await _orders.doc(orderId).get();

    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }

    final orderData = orderDoc.data()!;
    final userId = orderData['userId']?.toString() ?? '';

    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    String title = 'Order Update';
    String message = 'Your order status has been updated.';

    switch (status.toLowerCase()) {
      case 'pending':
        title = 'Order Received';
        message = 'Your order has been received successfully.';
        break;

      case 'processing':
        title = 'Order Processing';
        message = 'Your order is being prepared.';
        break;

      case 'shipped':
        title = 'Order Shipped';
        message = 'Your order is on the way!';
        break;

      case 'delivered':
        title = 'Order Delivered';
        message = 'Your order has been delivered successfully.';
        break;

      case 'cancelled':
        title = 'Order Cancelled';
        message = 'Your order has been cancelled.';
        break;
    }

    if (userId.isNotEmpty) {
      try {
        await NotificationService().sendNotification(
          userId: userId,
          title: title,
          message: message,
          orderId: orderId,
        );
      } catch (e) {
        // Order update succeeds even if notification fails.
        // ignore: avoid_print
        print('Notification error: $e');
      }
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    await _orders.doc(orderId).update({
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

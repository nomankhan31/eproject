import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final String status;
  final double totalAmount;
  final List<dynamic> items;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.status,
    required this.totalAmount,
    required this.items,
    this.paymentMethod = 'COD',
    this.paymentStatus = 'pending',
    this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? date;

    final dateValue = data['createdAt'];

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is DateTime) {
      date = dateValue;
    }

    return OrderModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items: data['items'] is List ? data['items'] : [],
      paymentMethod: data['paymentMethod']?.toString() ?? 'COD',
      paymentStatus: data['paymentStatus']?.toString() ?? 'pending',
      createdAt: date,
    );
  }
}

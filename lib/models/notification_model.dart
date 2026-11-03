import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String orderId;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.orderId,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> data) {
    final date = data['createdAt'];

    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      orderId: data['orderId'] ?? '',
      isRead: data['isRead'] == true,
      createdAt: date is Timestamp ? date.toDate() : null,
    );
  }
}

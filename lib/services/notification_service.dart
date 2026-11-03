import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String orderId,
  }) async {
    await _notifications.add({
      'userId': userId,
      'title': title,
      'message': message,
      'orderId': orderId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notifications.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
          .toList();

      notifications.sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );

      return notifications;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }
}

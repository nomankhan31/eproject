import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 65, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Card(
                color: notification.isRead
                    ? null
                    : Colors.blue.withValues(alpha: 0.08),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    notification.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Colors.blue,
                    size: 30,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(notification.message),
                      const SizedBox(height: 6),
                      Text(
                        notification.createdAt == null
                            ? 'Just now'
                            : DateFormat('dd MMM yyyy, hh:mm a')
                                  .format(notification.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      try {
                        if (value == 'read') {
                          await notificationService.markAsRead(notification.id);
                        } else if (value == 'delete') {
                          await notificationService.deleteNotification(
                            notification.id,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'read',
                          child: Text('Mark as Read'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

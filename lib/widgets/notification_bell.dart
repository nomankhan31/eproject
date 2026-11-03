import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../screens/customer/notification_screen.dart';

class NotificationBell extends StatelessWidget {
  NotificationBell({super.key});

  final NotificationService service = NotificationService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder(
      stream: service.getNotifications(user.uid),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unreadCount = notifications.where((item) => !item.isRead).length;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen()),
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 28),
              if (unreadCount > 0)
                Positioned(
                  right: -7,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

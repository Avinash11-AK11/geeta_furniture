import 'package:flutter/material.dart';
import '../../common/notification_manager.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationManager manager = NotificationManager.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          AnimatedBuilder(
            animation: manager,
            builder: (_, __) {
              if (!manager.hasNotifications) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: manager.clear,
                child: const Text('Clear', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: manager,
        builder: (_, __) {
          if (!manager.hasNotifications) {
            return const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: manager.notifications.length,
            itemBuilder: (_, index) {
              final notification = manager.notifications[index];

              return _NotificationCard(
                title: notification.title,
                body: notification.body,
                time: notification.time,
              );
            },
          );
        },
      ),
    );
  }
}

/* ============================================================
   🔔 NOTIFICATION CARD
   ============================================================ */

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final DateTime time;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            _formatTime(time),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '${time.day}/${time.month}/${time.year} • $h:$m';
  }
}

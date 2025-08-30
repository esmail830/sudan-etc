// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_app_bar.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = NotificationService();
    return Scaffold(
      appBar: const BottomNavAppBar(title: 'الإشعارات'),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: service.notifications,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات بعد'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = items[index];
              final time =
                  '${n.createdAt.year}/${n.createdAt.month.toString().padLeft(2, '0')}/${n.createdAt.day.toString().padLeft(2, '0')}';
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(n.title),
                subtitle: Text(n.body),
                trailing: Text(
                  time,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

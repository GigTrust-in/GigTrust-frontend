import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'New plumbing job near you!',
      'Client rated your work 5⭐',
      'Your withdrawal request is approved.',
      'Job “Electric Fix” marked as completed.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notifications[index]),
            subtitle: const Text('2 hours ago'),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}
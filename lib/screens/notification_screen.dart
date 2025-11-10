// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final jobProvider = Provider.of<JobProvider>(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Login to view notifications')),
      );
    }

    final notification = jobProvider.getNotificationsForUser(user.name);
    final unreadCount = jobProvider.getUnreadCount(user.name);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notification.isNotEmpty) ...[
            if (unreadCount > 0)
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: () {
                  jobProvider.markAllRead(user.name);
                  setState(() {});
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all read',
              onPressed: () {
                // Remove all read notifications
                final readNotifs = notification
                    .where((n) => n['read'] == true)
                    .toList();
                for (final notif in readNotifs) {
                  // keep same call style you used earlier
                  jobProvider.removeNotification(notif);
                }
                setState(() {});
              },
            ),
          ],
        ],
      ),
      body: notification.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll be notified of job updates here',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: notification.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = notification[index];
                  final type = notif['type'];
                  final from = notif['from'];
                  final message = notif['message'] ?? 'No Message';
                  final ts = notif['timestamp'];

                  Widget trailing = const Icon(Icons.chevron_right);

                  if (type == 'assignment_request') {
                    trailing = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (from != null) {
                              jobProvider.assignJob(notif['jobId'], from);
                              jobProvider.addNotification(
                                to: from,
                                from: user.name,
                                message:
                                    'Your request to join "${notif['jobId']}" was accepted',
                                type: 'assignment_accepted',
                                jobId: notif['jobId'],
                              );
                            }
                            jobProvider.removeNotification(notif);
                            setState(() {});
                          },
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            if (from != null) {
                              jobProvider.addNotification(
                                to: from,
                                from: user.name,
                                message:
                                    'Your request to join job was rejected',
                                type: 'assignment_rejected',
                                jobId: notif['jobId'],
                              );
                            }
                            jobProvider.removeNotification(notif);
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Reject'),
                        ),
                      ],
                    );
                  }

                  return ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(message),
                    subtitle: ts != null ? Text(ts.toString()) : null,
                    trailing: trailing,
                    onTap: (){
                      if (!notif['read']) {
                        jobProvider.markNotificationRead(notif['id']);
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}

                        
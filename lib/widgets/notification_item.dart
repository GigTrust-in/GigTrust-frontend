import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../screens/job_details_screen.dart';
import '../screens/job_completion_screen.dart';

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final type = notification['type'] as String;
    final jobId = notification['jobId'] as String;
    final job = jobProvider.allJobs.firstWhere((j) => j.id == jobId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildIcon(type),
        title: Text(
          notification['message'] as String,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatTimestamp(notification['timestamp'] as DateTime),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        trailing: _buildActionButton(context, type, job),
        onTap: () => _handleTap(context, type, job),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'job_assigned':
        icon = Icons.assignment_turned_in;
        color = Colors.green;
        break;
      case 'completion_request':
        icon = Icons.check_circle_outline;
        color = Colors.orange;
        break;
      case 'completion':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'revision':
        icon = Icons.update;
        color = Colors.red;
        break;
      case 'assignment_request':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }

  Widget? _buildActionButton(BuildContext context, String type, Job job) {
    switch (type) {
      case 'completion_request':
        return IconButton(
          icon: const Icon(Icons.check_circle),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobCompletionScreen(job: job),
            ),
          ),
        );
      case 'assignment_request':
        return TextButton(
          onPressed: () {
            final jobProvider = Provider.of<JobProvider>(context, listen: false);
            jobProvider.assignJob(job.id, notification['from'] as String);
          },
          child: const Text('Accept'),
        );
      default:
        return null;
    }
  }

  void _handleTap(BuildContext context, String type, Job job) {
    if (onTap != null) {
      onTap!();
      return;
    }

    // Mark as read
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    jobProvider.markNotificationRead(notification['id'] as String);

    // Navigate based on type
    switch (type) {
      case 'completion_request':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobCompletionScreen(job: job),
          ),
        );
        break;
      case 'revision':
      case 'completion':
      case 'job_assigned':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: job),
          ),
        );
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
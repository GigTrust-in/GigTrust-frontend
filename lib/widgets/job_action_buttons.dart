import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';

class JobActionButtons extends StatelessWidget {
  final Job job;
  final bool showAcceptReject;
  final bool showComplete;
  
  const JobActionButtons({
    super.key,
    required this.job,
    this.showAcceptReject = false,
    this.showComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isWorker = authProvider.user?.name == job.workerName;

    if (showAcceptReject && job.status == 'Open') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              jobProvider.rejectJob(job.id, authProvider.user?.name ?? '');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // Send assignment request to client instead of auto-assigning
              jobProvider.addNotification(
                to: job.clientName,
                from: authProvider.user?.name,
                message: '${authProvider.user?.name ?? 'A worker'} has requested to take your job "${job.title}"',
                type: 'assignment_request',
                jobId: job.id,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment request sent to client')),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      );
    }

    if (showComplete && job.status == 'Assigned' && isWorker) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              jobProvider.markJobComplete(job.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job marked as complete. Awaiting client confirmation.')),
              );
            },
            child: const Text('Mark as Complete'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
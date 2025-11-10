import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../models/job_status.dart';

import 'job_action_buttons.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final bool showActions;
  final bool showComplete;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.showActions = false,
    this.showComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Text(job.title, style: theme.textTheme.titleMedium);

    // Determine whether to show action buttons based on passed flags or current user role
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.user;
    final bool isWorkerUser = currentUser?.role == Role.worker;
    final bool computedShowAcceptReject = showActions || (isWorkerUser && job.status == JobStatus.open);
    final bool computedShowComplete = showComplete || (isWorkerUser && job.status == JobStatus.assigned && job.workerName == currentUser?.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job title
              Text(
                job.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // Job description
              Text(
                job.description,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              const SizedBox(height: 8),

              // Job details (amount, location, tenure)
              if (job.amount != null)
                Text("₹ ${job.amount}", style: const TextStyle(fontSize: 13)),
              if (job.location != null)
                Text("Location: ${job.location}", style: const TextStyle(fontSize: 13)),
              if (job.tenure != null)
                Text("Tenure: ${job.tenure}", style: const TextStyle(fontSize: 13)),

              const SizedBox(height: 6),

              // Bottom row: client name and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "👤 ${job.clientName}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(job.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: _statusColor(job.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Action buttons (Accept/Reject or Complete)
              if (computedShowAcceptReject || computedShowComplete)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: JobActionButtons(
                    job: job,
                    showAcceptReject: computedShowAcceptReject,
                    showComplete: computedShowComplete,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: returns color based on job status
  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Assigned':
        return Colors.blue;
      case 'PendingCompletion':
        return Colors.purple;
      case 'Open':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/confirm_action_dialog.dart';
import 'job_completion_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final jobProvider = Provider.of<JobProvider>(context);
    final isWorker = user?.name == job.workerName;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        actions: [
          if (job.status == 'Completed')
            IconButton(
              icon: const Icon(Icons.star_border),
              tooltip: 'Rate',
              onPressed: () {
                // TODO: Navigate to rating screen
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              color: _getStatusColor(job.status).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(job.status),
                    color: _getStatusColor(job.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    job.status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _getStatusColor(job.status),
                    ),
                  ),
                  if (job.status == 'PendingCompletion' && !isWorker)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showCompletionScreen(context),
                            child: const Text('Review Completion'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Job Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(job.description),
                  const SizedBox(height: 24),

                  // Details Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _detailTile(
                        context,
                        'Amount',
                        '₹${job.amount ?? 'N/A'}',
                        Icons.payment,
                      ),
                      _detailTile(
                        context,
                        'Location',
                        job.location ?? 'N/A',
                        Icons.location_on,
                      ),
                      _detailTile(
                        context,
                        'Type',
                        job.jobType ?? 'N/A',
                        Icons.work,
                      ),
                      _detailTile(
                        context,
                        'Tenure',
                        job.tenure ?? 'N/A',
                        Icons.schedule,
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Timeline
                  Text(
                    'Timeline',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _timelineEntry(
                    context,
                    'Posted',
                    job.postedDate.toString(),
                    Icons.post_add,
                    isFirst: true,
                    isCompleted: true,
                  ),
                  if (job.assignedAt != null)
                    _timelineEntry(
                      context,
                      'Assigned',
                      job.assignedAt.toString(),
                      Icons.assignment_ind,
                      isCompleted: true,
                    ),
                  if (job.pendingCompletionAt != null)
                    _timelineEntry(
                      context,
                      'Completion Requested',
                      job.pendingCompletionAt.toString(),
                      Icons.pending_actions,
                      isCompleted: job.status == 'Completed',
                    ),
                  if (job.completedAt != null)
                    _timelineEntry(
                      context,
                      'Completed',
                      job.completedAt.toString(),
                      Icons.check_circle,
                      isLast: true,
                      isCompleted: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _detailTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineEntry(
    BuildContext context,
    String label,
    String datetime,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
    bool isCompleted = false,
  }) {
    final color = isCompleted
        ? Theme.of(context).primaryColor
        : Theme.of(context).disabledColor;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (!isFirst) Expanded(child: VerticalDivider(color: color)),
                Icon(icon, size: 24, color: color),
                if (!isLast) Expanded(child: VerticalDivider(color: color)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    datetime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return null;

    final isWorker = user.name == job.workerName;
    if (!isWorker) return null;

    // Show actions for worker
    if (job.status == 'Assigned') {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _confirmMarkComplete(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Mark as Complete'),
          ),
        ),
      );
    }

    return null;
  }

  void _confirmMarkComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: 'Mark Job as Complete',
        message: 'Are you sure you want to mark this job as complete?',
        details: 'This will notify the client to review and confirm the completion.',
        confirmText: 'Mark Complete',
        onConfirm: () {
          final jobProvider = Provider.of<JobProvider>(context, listen: false);
          try {
            jobProvider.markJobComplete(job.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job marked as complete. Awaiting client confirmation.'),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showCompletionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobCompletionScreen(job: job),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'Assigned':
        return Colors.orange;
      case 'PendingCompletion':
        return Colors.amber;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Open':
        return Icons.work_outline;
      case 'Assigned':
        return Icons.assignment_ind;
      case 'PendingCompletion':
        return Icons.pending_actions;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}
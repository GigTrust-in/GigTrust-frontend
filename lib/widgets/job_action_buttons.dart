import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../models/job_status.dart';

class _AssignWorkerDialog extends StatelessWidget {
  final Job job;

  // ignore: unused_element_parameter
  const _AssignWorkerDialog({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Worker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job: ${job.title}'),
          const SizedBox(height: 16),
          Text('Worker: ${job.workerName ?? 'Not assigned'}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final jobProvider = Provider.of<JobProvider>(context, listen: false);
            if (job.workerName != null) {
              jobProvider.assignJob(job.id, job.workerName!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Worker assigned successfully')),
              );
            }
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

class JobActionButtons extends StatefulWidget {
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
  State<JobActionButtons> createState() => _JobActionButtonsState();
}

class _JobActionButtonsState extends State<JobActionButtons> {
  bool _isProcessing = false;

  Future<bool?> _confirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? '';
    final isWorker = authProvider.user?.role == Role.worker;
    final isClient = !isWorker;

    // Worker actions
    if (isWorker) {
      // Open jobs in find jobs screen
      if (widget.showAcceptReject && widget.job.status == JobStatus.open) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () => jobProvider.rejectJob(widget.job.id, userName),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await _confirmDialog('Accept Job', 'Do you want to accept this job?');
                      if (ok != true) return;
                      setState(() => _isProcessing = true);
                      try {
                        // assign synchronously; wrap in try to catch provider exceptions
                        jobProvider.assignJob(widget.job.id, userName);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Job accepted — moved to your ongoing jobs')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to accept job: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) setState(() => _isProcessing = false);
                      }
                    },
              child: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Accept'),
            ),
          ],
        );
      }

      // Assigned jobs in ongoing screen
      if (widget.showComplete && widget.job.status == JobStatus.assigned && widget.job.workerName == userName) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () {
                      jobProvider.markJobComplete(widget.job.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job marked as complete. Awaiting client confirmation.')),
                      );
                    },
              child: const Text('Mark as Complete'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await _confirmDialog('Cancel Assignment', 'Are you sure you want to cancel this assignment? This will reopen the job.');
                      if (ok != true) return;
                      setState(() => _isProcessing = true);
                      try {
                        jobProvider.unassignJob(widget.job.id, userName);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('You have cancelled this assignment')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to cancel: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) setState(() => _isProcessing = false);
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cancel'),
            ),
          ],
        );
      }
    }

    // Client actions
    if (isClient && widget.job.clientName == userName) {
      // Handle assignment requests
      if (widget.job.status == JobStatus.open) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // Show worker selection dialog
                showDialog(
                  context: context,
                  builder: (context) => _AssignWorkerDialog(job: widget.job),
                );
              },
              child: const Text('Assign Worker'),
            ),
          ],
        );
      }

      // Handle completion requests
      if (widget.job.status == JobStatus.pendingCompletion) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                jobProvider.confirmJobCompletion(widget.job.id, isCompleted: false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Requested revisions from worker')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Request Revisions'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                jobProvider.confirmJobCompletion(widget.job.id, isCompleted: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job marked as completed')),
                );
              },
              child: const Text('Confirm Completion'),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }
}
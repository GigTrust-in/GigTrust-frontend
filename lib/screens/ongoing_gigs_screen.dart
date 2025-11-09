import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class OngoingGigsScreen extends StatelessWidget {
  const OngoingGigsScreen({super.key});

  // Function to show bottom sheet with options
  void _showJobOptions(BuildContext context, Job job) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                job.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // --- Mark as Complete Button ---
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(context); // close bottom sheet first
                  final confirm = await _showConfirmationDialog(context, job);

                  if (confirm == true) {
                    jobProvider.completeJob(job.id);

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Job marked as complete! Money will be credited into your account.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 10),

              // --- View Details Button ---
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('View More'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailsScreen(job: job),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function for confirmation dialog
  Future<bool?> _showConfirmationDialog(BuildContext context, Job job) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Completion'),
        content: Text(
          'Are you sure you want to mark "${job.title}" as complete?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Yes, Complete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final ongoingJobs = jobProvider.ongoingJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Jobs'),
      ),
      body: ongoingJobs.isEmpty
          ? const Center(
              child: Text('No ongoing jobs right now.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ongoingJobs.length,
              itemBuilder: (context, index) {
                final job = ongoingJobs[index];
                return JobCard(
                  job: job,
                  onTap: () => _showJobOptions(context, job),
                );
              },
            ),
    );
  }
}
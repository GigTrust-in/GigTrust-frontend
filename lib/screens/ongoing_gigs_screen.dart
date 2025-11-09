import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';
import 'job_completion_screen.dart';

class OngoingGigsScreen extends StatelessWidget {
  const OngoingGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
  final isWorker = auth.user?.role == Role.worker;
    final userName = auth.user?.name ?? '';
    final ongoingJobs = jobProvider.getOngoingJobs(isWorker: isWorker, userName: userName);

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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(
                    job: job,
                    showComplete: true,
                    onTap: () {
                      if (job.status == 'PendingCompletion') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobCompletionScreen(job: job),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(job: job),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
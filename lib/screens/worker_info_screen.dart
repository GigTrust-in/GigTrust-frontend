import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../data/sample_jobs.dart';

class WorkerInfoScreen extends StatelessWidget {
  const WorkerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final assignedJobs = sampleJobs
        .where(
          (job) => job.status == 'Assigned' && job.workerName == user?.name,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile & Gigs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Hello, ${user?.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: assignedJobs.isEmpty
                  ? const Center(child: Text('No assigned gigs yet.'))
                  : ListView.builder(
                      itemCount: assignedJobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          title: 'Worker gig #${index + 1}',
                          description:
                              'Brief about this worker gig #${index + 1}',
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
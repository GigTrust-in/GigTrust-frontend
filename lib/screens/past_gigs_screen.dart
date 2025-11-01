import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';

class PastGigsScreen extends StatelessWidget {
  const PastGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final pastJobs = jobProvider.pastJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Gigs'),
        centerTitle: true,
      ),
      body: pastJobs.isEmpty
          ? const Center(
              child: Text(
                'No past gigs yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pastJobs.length,
              itemBuilder: (context, index) {
                final job = pastJobs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: JobCard(
                    title: job.title,
                    description: job.description,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(job.title),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${job.description}'),
                                Text('Amount: ₹${job.amount}'),
                                Text('Location: ${job.location}'),
                                Text('Job Type: ${job.jobType}'),
                                Text('Tenure: ${job.tenure}'),
                                Text('Min Rating: ${job.minRating}⭐'),
                                Text('Experience: ${job.experience}'),
                                Text('Skills: ${job.skills}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
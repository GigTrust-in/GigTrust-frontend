import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
// ignore: unused_import
import '../models/job.dart';

class PastJobsScreen extends StatelessWidget {
  const PastJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final pastJobs = jobProvider.pastJobs;

    return Scaffold(
      appBar: AppBar(title: const Text('Past Jobs')),
      body: pastJobs.isEmpty
          ? const Center(child: Text('No completed jobs yet.'))
          : ListView.builder(
              itemCount: pastJobs.length,
              itemBuilder: (ctx, i) {
                final job = pastJobs[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Client: ${job.clientName.trim().isEmpty ? 'N/A' : job.clientName}'),
                        const SizedBox(height: 4),
                        Text('Amount: ₹${job.amount ?? '0'}'),
                        const SizedBox(height: 4),
                        Text('Status: ${job.status}'),
                        const SizedBox(height: 6),
                        if (job.paid)
                          const Text('💰 Payment Released',
                              style: TextStyle(color: Colors.green)),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Client Rating: '),
                            Text(
                              job.clientRating != null
                                  ? '${job.clientRating} ⭐'
                                  : 'Not rated yet',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Worker Rating: '),
                            Text(
                              job.workerRating != null
                                  ? '${job.workerRating} ⭐'
                                  : 'Not rated yet',
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showRatingDialog(context, job.id, 'client');
                            },
                            icon: const Icon(Icons.star_rate),
                            label: const Text('Rate Worker'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showRatingDialog(BuildContext context, String jobId, String role) {
    double rating = 3.0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate Worker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your rating:'),
            StatefulBuilder(
              builder: (context, setState) {
                return Slider(
                  value: rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rating.toString(),
                  onChanged: (val) => setState(() => rating = val),
                );
              },
            ),
            Text('${rating.toStringAsFixed(1)} ⭐'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final jobProvider =
                  Provider.of<JobProvider>(context, listen: false);
              jobProvider.setWorkerRating(jobId, rating);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Worker rated successfully!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
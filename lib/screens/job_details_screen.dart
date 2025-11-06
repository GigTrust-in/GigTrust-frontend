import 'package:flutter/material.dart';
import '../models/job.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  const JobDetailsScreen({super.key, required this.job});

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: ${value ?? 'N/A'}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            _detailRow('Client', job.clientName),
            _detailRow('Amount', job.amount),
            _detailRow('Location', job.location),
            _detailRow('Tenure', job.tenure),
            _detailRow('Job Type', job.jobType),
            if (job.workerName != null) _detailRow('Assigned Worker', job.workerName),
            if (job.status.isNotEmpty) _detailRow('Status', job.status),
            const SizedBox(height: 20),
            // Example action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Accept job logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Accepted successfully!')),
                    );
                  },
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Reject job logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rejected successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
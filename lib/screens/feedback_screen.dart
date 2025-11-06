import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Job job = ModalRoute.of(context)!.settings.arguments as Job;
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Rate ${job.clientName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your experience with ${job.clientName}?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starIndex.toDouble()),
                    icon: Icon(
                      Icons.star,
                      color: starIndex <= _rating
                          ? Colors.amber
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
                      size: 36,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback (optional)',
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Rating'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a rating before submitting.')),
                    );
                    return;
                  }

                  final updatedJob = job.copyWith(clientRating: _rating);
                  jobProvider.updateJob(updatedJob);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feedback submitted for ${job.clientName}!')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
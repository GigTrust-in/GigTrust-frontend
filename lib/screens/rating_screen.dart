// lib/screens/rating_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';

class RatingScreen extends StatelessWidget {
  final Job job;

  const RatingScreen({super.key, required this.job, required String jobId, required String role, required String targetName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    double rating = 0; // ✅ Renamed from _rating

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Work"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Give feedback and rating for the completed job:"),
            const SizedBox(height: 20),

            // Rating bar
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => rating = index + 1),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 20),

            // Comment box
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final comment = commentController.text.trim();

                  if (rating == 0 || comment.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please give both rating and comment."),
                      ),
                    );
                    return;
                  }

                  // ✅ Fixed the method call — use only named arguments
                  Provider.of<JobProvider>(context, listen: false).addRating(
                    jobId: job.id,
                    role: 'client',
                    rating: rating,
                    comment: comment,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thanks for your feedback!")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
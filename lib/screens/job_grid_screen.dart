import 'package:flutter/material.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class JobsGridScreen extends StatelessWidget {
  final List<Job> jobs;
  const JobsGridScreen({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 768 ? 1 : (width < 1024 ? 2 : 3);
        const gap = 24.0;
        final childAspectRatio = 1.05;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobCard(
              job: job,
              onTap: () {
                // Navigate to full Job Details Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailsScreen(job: job),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
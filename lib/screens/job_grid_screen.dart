import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/job.dart';
import '../widgets/job_card.dart';


class JobsGridScreen extends StatelessWidget {
  final List<Job> jobs;
  const JobsGridScreen({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 768 ? 1 : (width < 1024 ? 2 : 3);
        // gap-6 -> 24 px
        const gap = 24.0;
        // childAspectRatio can be tuned to control card height relative to width
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
              title: job.title,
              amount: job.amount,
              tenure: job.tenure,   
              location: job.location,
              description: job.description,
              onTap: () {
                /* navigate to job details */
              },
              job: job, clientName: '',
            );
          },
        );
      },
    );
  }
}
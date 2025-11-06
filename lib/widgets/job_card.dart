import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                job.description,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              if (job.amount != null)
                Text("💰 ${job.amount}", style: const TextStyle(fontSize: 13)),
              if (job.location != null)
                Text("📍 ${job.location}", style: const TextStyle(fontSize: 13)),
              if (job.tenure != null)
                Text("⏳ ${job.tenure}", style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("👤 ${job.clientName}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    job.status,
                    style: TextStyle(
                      color: job.status == "Completed"
                          ? Colors.green
                          : job.status == "Ongoing"
                              ? Colors.blue
                              : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
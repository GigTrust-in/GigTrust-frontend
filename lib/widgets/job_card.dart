import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/job.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String? extraInfo; 
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.description,
    this.extraInfo, 
    required this.onTap, required Job job, String? amount, String? location, String? tenure, required String clientName,
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
              if (extraInfo != null) ...[
                const SizedBox(height: 8),
                Text(
                  extraInfo!,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
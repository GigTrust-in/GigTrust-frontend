import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/job.dart';

class OngoingGigsScreen extends StatelessWidget {
  const OngoingGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final sample = List.generate(
      5,
      (i) => {
        'title': 'Ongoing Gig ${i + 1}',
        'description': 'Working on task ${i + 1}',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ongoing Gigs')),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: user == null
            ? const Center(child: Text('Please login to see ongoing gigs.'))
            : ListView.builder(
                itemCount: sample.length,
                itemBuilder: (context, index) {
                  final g = sample[index];
                  final jobObj = Job(
                    id: 'ongoing-${index + 1}',
                    title: g['title']!,
                    description: g['description']!,
                    status: 'Ongoing',
                    clientName: '',
                    postedDate: '',
                    amount: '',
                    location: '',
                    tenure: '',
                    jobType: '',
                    minRating: '',
                    experience: '',
                    skills: '',
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ExpandableJobTile(job: jobObj),
                  );
                },
              ),
      ),
    );
  }
}

/// ✅ Custom expandable animated tile
class ExpandableJobTile extends StatefulWidget {
  final Job job;
  const ExpandableJobTile({super.key, required this.job});

  @override
  State<ExpandableJobTile> createState() => _ExpandableJobTileState();
}

class _ExpandableJobTileState extends State<ExpandableJobTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        height: _expanded ? 160 : 70, // 👈 expands smoothly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(widget.job.status, style: const TextStyle(color: Colors.grey)),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.job.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text('Client: ${widget.job.clientName.isEmpty ? "N/A" : widget.job.clientName}'),
            ],
          ],
        ),
      ),
    );
  }
}
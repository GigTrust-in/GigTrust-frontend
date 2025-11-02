import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';

class RatingScreen extends StatefulWidget {
  final String jobId;
  final String role; // 'worker' or 'client' as rater
  final String targetName; // who is being rated

  const RatingScreen({super.key, required this.jobId, required this.role, required this.targetName});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Rate ${widget.targetName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final idx = i + 1;
                return IconButton(
                  icon: Icon(idx <= _stars ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => setState(() => _stars = idx),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Comment (optional)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final rating = _stars.toDouble();
                  final jobProvider = Provider.of<JobProvider>(context, listen: false);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  if (widget.role == 'worker') {
                    // worker is rating the client
                    jobProvider.setClientRating(widget.jobId, rating);
                    auth.addRatingToUserByName(widget.targetName, rating);
                  } else {
                    // client is rating the worker
                    jobProvider.setWorkerRating(widget.jobId, rating);
                    auth.addRatingToUserByName(widget.targetName, rating);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating submitted')));
                  Navigator.pop(context);
                },
                child: const Text('Submit Rating'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';

class RatingScreen extends StatefulWidget {
  final Job job;
  final String jobId;
  final String role; // 'client' or 'worker'
  final String targetName;

  const RatingScreen({
    super.key,
    required this.job,
    required this.jobId,
    required this.role,
    required this.targetName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 3.0;
  final _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final isClient = widget.role == 'client';
    final provider = Provider.of<JobProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isClient
            ? 'Rate Worker — ${widget.targetName}'
            : 'Rate Client — ${widget.targetName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _submitted
            ? const Center(
                child: Icon(Icons.check_circle, color: Colors.green, size: 80),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please rate ${widget.targetName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: colorScheme.primary,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Rating: ${_rating.toStringAsFixed(1)} ★',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Leave feedback (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                      onPressed: () async {
                        provider.addRating(
                          jobId: widget.jobId.isEmpty
                              ? widget.job.id
                              : widget.jobId,
                          role: widget.role,
                          rating: _rating,
                          comment: _feedbackController.text.trim(),
                        );

                        setState(() => _submitted = true);

                        if (!mounted) return; // ✅ safeguard before context use

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thanks for rating ${widget.targetName}! (${_rating.toStringAsFixed(1)}★)',
                            ),
                          ),
                        );

                        await Future.delayed(const Duration(seconds: 1));

                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
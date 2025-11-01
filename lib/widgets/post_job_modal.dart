// lib/widgets/post_job_modal.dart

import 'package:flutter/material.dart';
import '../models/job.dart';

class PostJobModal extends StatefulWidget {
  final Function(Job) onJobPost;
  final VoidCallback onClose;
  final String clientName;

  const PostJobModal({
    super.key,
    required this.onJobPost,
    required this.onClose,
    required this.clientName,
  });

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _tenureController = TextEditingController();
  final _locationController = TextEditingController();

  // ✅ Give default value so it's never null
  String _selectedJobType = 'On-site';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Post a New Gig'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tenureController,
              decoration: const InputDecoration(labelText: 'Tenure (in days)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Job Type'),
              initialValue: _selectedJobType,
              items: const [
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                DropdownMenuItem(value: 'On-site', child: Text('On-site')),
                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedJobType = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty ||
                _descriptionController.text.isEmpty) {
              return;
            }

            final newJob = Job(
              id: 'job-${DateTime.now().millisecondsSinceEpoch}',
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              clientName: widget.clientName,
              postedDate: DateTime.now().toIso8601String().split('T')[0],
              status: 'Open',
              amount: _amountController.text.trim(),
              tenure: _tenureController.text.trim(),
              location: _locationController.text.trim(),
              jobType: _selectedJobType, // ✅ Always a valid string now
            );

            widget.onJobPost(newJob);
            widget.onClose();
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}
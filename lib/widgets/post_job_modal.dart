import 'package:flutter/material.dart';
import '../models/job.dart';

class PostJobModal extends StatefulWidget {
  final Function(Job) onJobPost;
  final VoidCallback onClose;
  final String clientName;

  const PostJobModal({super.key, required this.onJobPost, required this.onClose, required this.clientName});

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Post a New Gig'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onClose, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) return;
            final newJob = Job(
              id: 'job-${DateTime.now().millisecondsSinceEpoch}',
              title: _titleController.text,
              description: _descriptionController.text,
              clientName: widget.clientName,
              postedDate: DateTime.now().toIso8601String().split('T')[0],
              status: 'Open',
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
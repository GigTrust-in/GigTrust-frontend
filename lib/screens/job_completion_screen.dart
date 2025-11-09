import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
// auth provider not currently used here

class JobCompletionScreen extends StatefulWidget {
  final Job job;

  const JobCompletionScreen({super.key, required this.job});

  @override
  State<JobCompletionScreen> createState() => _JobCompletionScreenState();
}

class _JobCompletionScreenState extends State<JobCompletionScreen> {
  final _grievanceController = TextEditingController();
  bool _isCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Completion'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    _detailRow('Worker', widget.job.workerName),
                    _detailRow('Amount', '₹${widget.job.amount}'),
                    _detailRow('Marked Complete', widget.job.pendingCompletionAt?.toString()),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Completion Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Completion',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Mark as Completed',
                        style: TextStyle(
                          color: _isCompleted ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _isCompleted 
                          ? 'The job will be marked as complete and payment will be released'
                          : 'Request revisions from the worker',
                      ),
                      trailing: Switch(
                        value: _isCompleted,
                        onChanged: (value) => setState(() => _isCompleted = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            
            // Feedback Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? 'Feedback for Worker' : 'Revision Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _grievanceController,
                      decoration: InputDecoration(
                        labelText: _isCompleted 
                          ? 'Add any feedback for the worker (optional)'
                          : 'Explain what needs to be revised',
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: _isCompleted
                          ? 'Great job on the detailed documentation...'
                          : 'Please add more details to the implementation...',
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isCompleted && _grievanceController.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Please provide revision details',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: !_isCompleted && _grievanceController.text.isEmpty
                          ? null  // Disable if revisions needed but no details provided
                          : () {
                              final jobProvider = Provider.of<JobProvider>(context, listen: false);

                              try {
                                jobProvider.confirmJobCompletion(
                                  widget.job.id,
                                  isCompleted: _isCompleted,
                                  grievance: _grievanceController.text.isNotEmpty
                                      ? _grievanceController.text
                                      : null,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isCompleted
                                          ? 'Job marked as completed successfully'
                                          : 'Revision request sent to worker',
                                    ),
                                    backgroundColor: _isCompleted
                                        ? Colors.green
                                        : Theme.of(context).primaryColor,
                                  ),
                                );

                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompleted ? Colors.green : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isCompleted 
                            ? 'Confirm Completion'
                            : 'Send Revision Request',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _grievanceController.dispose();
    super.dispose();
  }
}
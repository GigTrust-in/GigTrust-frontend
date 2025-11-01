import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Rate your experience:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback submitted!')),
                );
                _feedbackController.clear();
                setState(() => _rating = 3);
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
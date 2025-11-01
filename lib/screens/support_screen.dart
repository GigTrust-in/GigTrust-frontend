import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need help?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Describe your issue below, and our support team will contact you.'),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Type your issue or feedback...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support request submitted!')),
                );
                _messageController.clear();
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OngoingTransactionsScreen extends StatelessWidget {
  const OngoingTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final sample = List.generate(
      4,
      (i) => {'title': 'Processing ${i + 1}', 'amount': '\$${(i + 2) * 15}'},
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ongoing Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: user == null
            ? const Center(child: Text('Please login to see transactions.'))
            : ListView.builder(
                itemCount: sample.length,
                itemBuilder: (context, index) {
                  final tx = sample[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.hourglass_top),
                      title: Text(tx['title']!),
                      trailing: Text(tx['amount']!),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

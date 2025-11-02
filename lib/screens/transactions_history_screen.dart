import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TransactionsHistoryScreen extends StatelessWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final sample = List.generate(
      8,
      (i) => {
        'title': 'Payment ${i + 1}',
        'amount': '\$${(i + 1) * 10}',
        'status': i % 2 == 0 ? 'Completed' : 'Refunded',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Past Transactions')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: user == null
            ? const Center(child: Text('Please login to see transactions.'))
            : ListView.separated(
                itemCount: sample.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = sample[index];
                  return ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(tx['title']!),
                    subtitle: Text(tx['status']!),
                    trailing: Text(tx['amount']!),
                  );
                },
              ),
      ),
    );
  }
}
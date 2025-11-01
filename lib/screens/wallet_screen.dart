import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final balance = 3200.50;
    final transactions = [
      {'title': 'Job Payment — Electric Fix', 'amount': '+₹1200'},
      {'title': 'Withdrawal', 'amount': '-₹500'},
      {'title': 'Job Payment — Gardening', 'amount': '+₹1500'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Available Balance', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('₹$balance',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isCredit = tx['amount']!.startsWith('+');
                  return ListTile(
                    leading: Icon(
                      isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                    title: Text(tx['title']!),
                    trailing: Text(
                      tx['amount']!,
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
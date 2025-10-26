import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../data/sample_transactions.dart';
import '../models/role.dart'; // added import

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashboardPath = user?.role == Role.worker
        ? '/worker-dashboard'
        : '/client-dashboard';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, dashboardPath),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleTransactions.length,
        itemBuilder: (context, index) {
          final tx = sampleTransactions[index];
          final isPayout = tx.type == 'Payout';
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPayout ? Colors.green[100] : Colors.red[100],
                child: Icon(
                  isPayout ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isPayout ? Colors.green : Colors.red,
                ),
              ),
              title: Text(tx.jobTitle),
              subtitle: Text(tx.date),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${isPayout ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isPayout ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tx.status == 'Completed'
                          ? Colors.blue[100]
                          : Colors.yellow[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tx.status,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

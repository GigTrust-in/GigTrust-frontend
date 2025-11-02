import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    double balance = 0.0;
    double escrowed = 0.0;
    final List<Map<String, String>> transactions = [];

    if (user != null) {
      // Completed jobs credited to worker
      for (final job in jobProvider.allJobs) {
        final amt = double.tryParse(job.amount ?? '0') ?? 0.0;
        if (job.status == 'Completed' && job.workerName == user.name) {
          balance += amt;
          transactions.add({'title': 'Job Payment — ${job.title}', 'amount': '+₹${amt.toStringAsFixed(0)}'});
        }
        if (job.status == 'Assigned' && job.workerName == user.name) {
          escrowed += amt;
          transactions.add({'title': 'Escrow — ${job.title}', 'amount': '₹${amt.toStringAsFixed(0)}'});
        }
        if (job.status == 'Completed' && job.clientName == user.name) {
          // client paid out
          transactions.add({'title': 'Paid — ${job.title}', 'amount': '-₹${amt.toStringAsFixed(0)}'});
          balance -= amt; // clients balance decreased
        }
      }
    }

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
                    Text('₹${balance.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Escrowed: ₹${escrowed.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14)),
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
            const SizedBox(height: 12),
            if (user != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text('Escrowed (on-chain)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...Provider.of<JobProvider>(context).escrowTxForWorker(user.name).map((e) => ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(e['title'] ?? ''),
                    subtitle: Text('Tx: ${e['tx']}'),
                    trailing: Text('₹${e['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
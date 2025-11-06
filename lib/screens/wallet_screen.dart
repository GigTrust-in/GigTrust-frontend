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
      for (final job in jobProvider.allJobs) {
        final amt = double.tryParse(job.amount ?? '0') ?? 0.0;
        if (job.status == 'Completed' && job.workerName == user.name) {
          balance += amt;
          transactions.add({
            'title': 'Job Payment — ${job.title}',
            'amount': '+₹${amt.toStringAsFixed(0)}'
          });
        }
        if (job.status == 'Assigned' && job.workerName == user.name) {
          escrowed += amt;
          transactions.add({
            'title': 'Escrow — ${job.title}',
            'amount': '₹${amt.toStringAsFixed(0)}'
          });
        }
        if (job.status == 'Completed' && job.clientName == user.name) {
          transactions.add({
            'title': 'Paid — ${job.title}',
            'amount': '-₹${amt.toStringAsFixed(0)}'
          });
          balance -= amt;
        }
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.grey[850]
        : Colors.green.shade50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: cardColor,
              elevation: 3,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${balance.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.greenAccent : Colors.green.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escrowed: ₹${escrowed.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isCredit = tx['amount']!.startsWith('+');
                        return ListTile(
                          leading: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit
                                ? (isDark ? Colors.greenAccent : Colors.green)
                                : (isDark ? Colors.redAccent : Colors.red),
                          ),
                          title: Text(tx['title']!),
                          trailing: Text(
                            tx['amount']!,
                            style: TextStyle(
                              color: isCredit
                                  ? (isDark ? Colors.greenAccent : Colors.green)
                                  : (isDark ? Colors.redAccent : Colors.red),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            // Escrowed Transactions
            if (user != null && jobProvider.escrowTxForWorker(user.name).isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Escrowed (on-chain)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...jobProvider.escrowTxForWorker(user.name).map((e) => ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(e['title'] ?? ''),
                    subtitle: Text('Tx: ${e['tx']}'),
                    trailing: Text(
                      '₹${e['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
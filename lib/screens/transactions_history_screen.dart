import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';

class TransactionsHistoryScreen extends StatelessWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view transaction history'),
        ),
      );
    }

    final transactions = _buildTransactions(jobProvider, user.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions found'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                if (index == 0 || _isNewDay(transactions[index - 1]['date'] as DateTime, transactions[index]['date'] as DateTime)) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateHeader(transactions[index]['date'] as DateTime),
                      _buildTransactionTile(context, transactions[index]),
                    ],
                  );
                }
                return _buildTransactionTile(context, transactions[index]);
              },
            ),
    );
  }

  List<Map<String, dynamic>> _buildTransactions(JobProvider provider, String userName) {
    final List<Map<String, dynamic>> transactions = [];

    for (final job in provider.allJobs) {
      final amount = double.tryParse(job.amount ?? '0') ?? 0.0;

      if (job.workerName == userName) {
        // Worker transactions
        if (job.paid && job.status == 'Assigned') {
          transactions.add({
            'title': 'Escrow deposit for "${job.title}"',
            'amount': amount,
            'type': 'escrow',
            'date': job.assignedAt ?? DateTime.now(),
            'status': 'pending',
          });
        }

        if (job.status == 'Completed') {
          transactions.add({
            'title': 'Payment received for "${job.title}"',
            'amount': amount,
            'type': 'credit',
            'date': job.completedAt ?? DateTime.now(),
            'status': 'completed',
          });
        }
      }

      if (job.clientName == userName) {
        // Client transactions
        if (job.paid && job.status == 'Assigned') {
          transactions.add({
            'title': 'Payment escrowed for "${job.title}"',
            'amount': -amount,
            'type': 'escrow',
            'date': job.assignedAt ?? DateTime.now(),
            'status': 'pending',
          });
        }

        if (job.status == 'Completed') {
          transactions.add({
            'title': 'Payment released for "${job.title}"',
            'amount': -amount,
            'type': 'debit',
            'date': job.completedAt ?? DateTime.now(),
            'status': 'completed',
          });
        }
      }
    }

    transactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return transactions;
  }

  bool _isNewDay(DateTime prev, DateTime current) {
    return prev.year != current.year ||
           prev.month != current.month ||
           prev.day != current.day;
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTransactionTile(BuildContext context, Map<String, dynamic> tx) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getAmountColor() {
      if (tx['type'] == 'escrow') return Colors.orange;
      return tx['amount'] > 0
          ? (isDark ? Colors.greenAccent : Colors.green)
          : (isDark ? Colors.redAccent : Colors.red);
    }

    IconData getIcon() {
      switch (tx['type']) {
        case 'credit':
          return Icons.arrow_circle_down;
        case 'debit':
          return Icons.arrow_circle_up;
        case 'escrow':
          return Icons.account_balance_wallet;
        default:
          return Icons.swap_horiz;
      }
    }

    return ListTile(
      leading: Icon(
        getIcon(),
        color: getAmountColor(),
      ),
      title: Text(
        tx['title'],
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        tx['status'] == 'pending' ? 'Pending' : _formatTime(tx['date']),
        style: TextStyle(
          color: tx['status'] == 'pending'
              ? Colors.orange
              : theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Text(
        '₹${tx['amount'].abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: getAmountColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.green.shade50;
    
    Map<String, dynamic> stats = {};
    List<Map<String, dynamic>> history = [];

    if (user != null) {
      final isWorker = user.role == Role.worker;
      
      // Get user's payment statistics
      stats = isWorker 
        ? jobProvider.getWorkerPaymentStats(user.name)
        : jobProvider.getClientPaymentStats(user.name);
      
      // Get transaction history
      history = jobProvider.getTransactionHistory(user.name, isWorker: isWorker);
    }

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
                      user?.role == Role.worker ? 'Total Earnings' : 'Total Spent',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${stats['totalEarned'] ?? stats['totalPaid'] ?? '0.00'}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.greenAccent : Colors.green.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.role == Role.worker 
                        ? 'Pending: ₹${stats['totalPending'] ?? '0.00'}'
                        : 'In Escrow: ₹${stats['totalInEscrow'] ?? '0.00'}',
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
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = history[index];
                        final isCompleted = tx['type'] == 'completed';
                        final amount = double.tryParse(tx['amount'] ?? '0') ?? 0.0;
                        final isWorker = user?.role == Role.worker;
                        
                        // Format amount display
                        final amountText = isWorker
                          ? '+₹${amount.toStringAsFixed(0)}'
                          : '-₹${amount.toStringAsFixed(0)}';

                        // Get transaction title
                        final title = isCompleted
                          ? 'Payment — ${tx['title']}'
                          : 'Escrow — ${tx['title']}';
                        
                        return ListTile(
                          leading: Icon(
                            isCompleted ? Icons.check_circle : Icons.pending,
                            color: isCompleted
                                ? (isDark ? Colors.greenAccent : Colors.green)
                                : (isDark ? Colors.orangeAccent : Colors.orange),
                          ),
                          title: Text(title),
                          subtitle: Text(
                            '${tx['type']?.toString().toUpperCase()} • ${tx['counterparty']}',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            amountText,
                            style: TextStyle(
                              color: isWorker
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

            // Stats Summary
            if (stats.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    context,
                    'Completed Jobs',
                    stats['completedJobs']?.toString() ?? '0',
                    Icons.check_circle_outline,
                  ),
                  _buildStatCard(
                    context,
                    user?.role == Role.worker ? 'Pending Jobs' : 'Ongoing Jobs',
                    stats['pendingJobs']?.toString() ?? stats['ongoingJobs']?.toString() ?? '0',
                    Icons.pending_outlined,
                  ),
                  _buildStatCard(
                    context,
                    'Avg per Job',
                    '₹${stats['averagePerJob'] ?? stats['averageJobCost'] ?? '0'}',
                    Icons.insights_outlined,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
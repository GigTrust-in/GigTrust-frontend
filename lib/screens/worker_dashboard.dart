// lib/screens/worker_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';
import '../models/job.dart';
import 'rating_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            user != null ? 'Worker — ${user.name}' : 'Worker Dashboard',
          ),
          leading: const TopProfileMenu(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ongoing Jobs'),
              Tab(text: 'Past Jobs'),
              Tab(text: 'Find Jobs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(context, jobProvider.ongoingJobs),
            _buildGrid(context, jobProvider.pastJobs),
            Consumer<JobProvider>(
              builder: (context, provider, _) {
                final user = Provider.of<AuthProvider>(context).user;
                if (user == null) {
                  return const Center(child: Text('Login to see jobs.'));
                }

                final recommendedJobs = provider.getRecommendedJobs(user.name);

                if (recommendedJobs.isEmpty) {
                  return const Center(
                    child: Text('No jobs recommended for you.'),
                  );
                }

                return _buildGrid(context, recommendedJobs);
              },
            ),
          ],
        ),
        floatingActionButton: user == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showEscrowList(user.name),
                icon: const Icon(Icons.payment),
                label: const Text('View Payments'),
              ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) return const Center(child: Text('No jobs found.'));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 768 ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(
          job: job,
          onTap: () => _openDetails(context, job),
        );
      },
    );
  }

  void _showEscrowList(String workerName) {
    final provider = Provider.of<JobProvider>(context, listen: false);
    final escrowList = provider.escrowTxForWorker(workerName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payments Received'),
        content: escrowList.isEmpty
            ? const Text('No payments yet.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: escrowList.length,
                  itemBuilder: (context, index) {
                    final tx = escrowList[index];
                    return ListTile(
                      title: Text(tx['title'] ?? ''),
                      subtitle: Text('Amount: ₹${tx['amount']}'),
                      trailing: Text(tx['tx'] ?? 'Pending'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, Job job) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.description),
              const SizedBox(height: 12),
              Text('Amount: ₹${job.amount ?? 'N/A'}'),
              Text('Location: ${job.location ?? 'N/A'}'),
              Text('Type: ${job.jobType ?? 'N/A'}'),
              Text('Tenure: ${job.tenure ?? 'N/A'}'),
              Text('Status: ${job.status}'),
            ],
          ),
        ),
        actions: _actionsForJob(context, job, jobProvider, user?.name),
      ),
    );
  }

  List<Widget> _actionsForJob(
    BuildContext context,
    Job job,
    JobProvider provider,
    String? myName,
  ) {
    // Worker is currently assigned
    if (job.status == 'Assigned' && job.workerName == myName) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            provider.completeJob(job.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Marked as completed')),
            );
            setState(() {});
          },
          child: const Text('Mark as complete'),
        ),
        OutlinedButton(
          onPressed: () {
            provider.addJob(job.copyWith(status: 'Open', workerName: null));
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Job reopened')));
          },
          child: const Text('Cancel'),
        ),
      ];
    }

    // Completed job — allow worker to rate client
    if (job.status == 'Completed' &&
        job.workerName == myName &&
        (job.clientRating == null)) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RatingScreen(
                  job: job,
                  jobId: job.id,
                  role: 'worker',
                  targetName: job.clientName,
                ),
              ),
            );
          },
          child: const Text('Rate Client'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ];
  }
}

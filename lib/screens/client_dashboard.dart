// lib/screens/client_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../models/role.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';
import '../models/job.dart';
import 'rating_screen.dart';
import 'job_completion_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  final _tenureController = TextEditingController();
  final _ratingController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  String? _selectedJobType;

  void _showAddGigDialog(String clientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Post New Gig'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tenureController,
                decoration: const InputDecoration(labelText: 'Tenure'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Minimum Rating'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: 'Skills'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Job Type'),
                initialValue: _selectedJobType,
                items: const [
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(
                    value: 'Electrician',
                    child: Text('Electrician'),
                  ),
                  DropdownMenuItem(
                    value: 'Carpenter',
                    child: Text('Carpenter'),
                  ),
                  DropdownMenuItem(value: 'Painting', child: Text('Painting')),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                  DropdownMenuItem(
                    value: 'Gardening',
                    child: Text('Gardening'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedJobType = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final user = Provider.of<AuthProvider>(
                context,
                listen: false,
              ).user;
              if (user == null) return;

              final newJob = Job(
                id: 'job-${DateTime.now().millisecondsSinceEpoch}',
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                clientName: user.name,
                postedDate: DateTime.now(),
                status: 'Open',
                amount: _amountController.text.trim(),
                location: _locationController.text.trim(),
                tenure: _tenureController.text.trim(),
                jobType: _selectedJobType ?? 'General',
                minRating: _ratingController.text.trim(),
                experience: _experienceController.text.trim(),
                skills: _skillsController.text.trim(),
              );

              Provider.of<JobProvider>(context, listen: false).addJob(newJob);
              // Notify all registered workers about the new job post
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final workers = authProvider.getUsersByRole(Role.worker);
              final jobProv = Provider.of<JobProvider>(context, listen: false);
              for (final w in workers) {
                jobProv.addNotification(
                  to: w.name,
                  from: user.name,
                  message: 'New job posted: "${newJob.title}"',
                  type: 'new_job',
                  jobId: newJob.id,
                );
              }
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gig posted successfully!')),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final jobProvider = Provider.of<JobProvider>(context);

    final userName = user?.name ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            user != null
                ? 'Client Dashboard — ${user.name}'
                : 'Client Dashboard',
          ),
          leading: const TopProfileMenu(),
          actions: [
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              tooltip: 'Payments',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ongoing Gigs'),
              Tab(text: 'Past Gigs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Show only this client's ongoing jobs
            _buildJobList(jobProvider.getOngoingJobs(isWorker: false, userName: userName)),
            // Filter past jobs to this client
            _buildJobList(jobProvider.pastJobs.where((j) => j.clientName == userName).toList()),
          ],
        ),
        floatingActionButton: user == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showAddGigDialog(user.name),
                icon: const Icon(Icons.add),
                label: const Text('Post Gig'),
              ),
      ),
    );
  }

  Widget _buildJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return const Center(child: Text('No gigs available.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 768
            ? 1
            : (constraints.maxWidth < 1024 ? 2 : 3);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2,
          ),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobCard(
              job: job,
              onTap: () => _showJobDetails(context, job),
            );
          },
        );
      },
    );
  }

  Widget _detail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: ${value ?? 'N/A'}'),
    );
  }

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.description),
              const SizedBox(height: 10),
              _detail('Amount', job.amount),
              _detail('Location', job.location),
              _detail('Type', job.jobType),
              _detail('Client Rating', job.clientRating?.toString()),
              if (job.workerName != null)
                _detail('Accepted by', job.workerName),
              if (job.workerName != null)
                _detail('Worker Rating', job.workerRating?.toString()),
              _detail('Tenure', job.tenure),
            ],
          ),
        ),
        actions: _clientDetailActions(context, job),
      ),
    );
  }

  List<Widget> _clientDetailActions(BuildContext context, Job job) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    // If job is pending completion -> allow client to review/confirm
    if (job.status == 'PendingCompletion' &&
        user != null &&
        user.name == job.clientName) {
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
                builder: (_) => JobCompletionScreen(job: job),
              ),
            );
          },
          child: const Text('Review Completion'),
        ),
      ];
    }

    // If assigned and not paid yet -> show Pay button
    if (job.status == 'Assigned' &&
        user != null &&
        user.name == job.clientName &&
        !job.paid) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(
              context,
              '/payment',
              arguments: {'jobId': job.id, 'amount': job.amount},
            );
          },
          child: const Text('Pay Worker'),
        ),
        ElevatedButton(
          onPressed: () {
            final txId =
                Provider.of<JobProvider>(
                  context,
                  listen: false,
                ).escrowTxFor(job.id) ??
                'Pending';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Escrow Tx: $txId')));
          },
          child: const Text('View Payment Status'),
        ),
      ];
    }

    // Completed job — allow client to rate worker
    if (job.status == 'Completed' &&
        user != null &&
        user.name == job.clientName &&
        (job.workerRating == null)) {
      if (job.workerName == null) {
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ];
      }
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
                  role: 'client',
                  targetName: job.workerName ?? 'Worker',
                ),
              ),
            );
          },
          child: const Text('Rate Worker'),
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

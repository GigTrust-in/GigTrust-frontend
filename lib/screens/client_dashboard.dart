import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';
import '../models/job.dart';

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
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount (₹)')),
              const SizedBox(height: 8),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 8),
              TextField(controller: _tenureController, decoration: const InputDecoration(labelText: 'Tenure')),
              const SizedBox(height: 8),
              TextField(controller: _ratingController, decoration: const InputDecoration(labelText: 'Minimum Rating')),
              const SizedBox(height: 8),
              TextField(controller: _experienceController, decoration: const InputDecoration(labelText: 'Experience')),
              const SizedBox(height: 8),
              TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Job Type'),
                initialValue: _selectedJobType,
                items: const [
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(value: 'Electrician', child: Text('Electrician')),
                  DropdownMenuItem(value: 'Carpenter', child: Text('Carpenter')),
                  DropdownMenuItem(value: 'Painting', child: Text('Painting')),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                  DropdownMenuItem(value: 'Gardening', child: Text('Gardening')),
                ],
                onChanged: (value) => setState(() => _selectedJobType = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final user = Provider.of<AuthProvider>(context, listen: false).user;
              if (user == null) return;

              final newJob = Job(
                id: 'job-${DateTime.now().millisecondsSinceEpoch}',
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                clientName: user.name,
                postedDate: DateTime.now().toIso8601String().split('T')[0],
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(user != null ? 'Client Dashboard — ${user.name}' : 'Client Dashboard'),
          leading: const TopProfileMenu(),
          bottom: const TabBar(tabs: [Tab(text: 'Ongoing Gigs'), Tab(text: 'Past Gigs')]),
        ),
        body: TabBarView(
          children: [
            _buildJobList(jobProvider.ongoingJobs),
            _buildJobList(jobProvider.pastJobs),
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
              title: job.title,
              description: job.description,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
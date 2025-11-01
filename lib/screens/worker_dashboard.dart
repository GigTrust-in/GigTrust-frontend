// lib/screens/worker_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';
import '../models/job.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Painting',
    'Cleaning',
    'Delivery',
    'IT Support'
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            user != null ? 'Worker Dashboard — ${user.name}' : 'Worker Dashboard',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          leading: const TopProfileMenu(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
            _buildJobGrid(context, jobProvider.ongoingJobs),
            _buildJobGrid(context, jobProvider.pastJobs),
            _buildFindJobsTab(context, jobProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildFindJobsTab(BuildContext context, JobProvider jobProvider) {
    final jobs = jobProvider.ongoingJobs; // treat these as findable jobs

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _isSearchExpanded = !_isSearchExpanded);
              _isSearchExpanded
                  ? _animationController.forward()
                  : _animationController.reverse();
            },
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isSearchExpanded ? 60 : 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isSearchExpanded
                      ? [BoxShadow(color: Colors.black26, blurRadius: 8)]
                      : [],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search jobs...',
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Job Categories
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((cat) {
              return GestureDetector(
                onTap: () {
                  setState(() => _searchQuery = cat.toLowerCase());
                },
                child: Chip(
                  label: Text(cat),
                  backgroundColor: Colors.blue.shade100,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Filtered Jobs
          ...jobs
              .where((job) => job.title.toLowerCase().contains(_searchQuery))
              .map(
                (job) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(job.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${job.location} • ₹${job.amount}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Applied for ${job.title}!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildJobGrid(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs available right now.'));
    }

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
          title: job.title,
          description: job.description,
          onTap: () => _showJobDetails(context, job),
        );
      },
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
              _detail('Tenure', job.tenure),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Applied successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: ${value ?? "N/A"}'),
    );
  }
}
// lib/screens/find_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // Guard: only worker should use find jobs
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox.shrink();
    }
    if (user.role != Role.worker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/client-dashboard');
      });
      return const SizedBox.shrink();
    }

    final jobProvider = Provider.of<JobProvider>(context);
    final List<Job> allJobs =
        jobProvider.allJobs.where((j) => j.status == 'Open').toList();

    final categories =
        <String>{'All', ...allJobs.map((j) => j.jobType ?? 'Others')}.toList();

    final filteredJobs = allJobs.where((job) {
      final matchesCategory = _selectedCategory == 'All' ||
          (job.jobType ?? '').toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchController.text.toLowerCase();
      final matchesSearch = q.isEmpty ||
          job.title.toLowerCase().contains(q) ||
          job.description.toLowerCase().contains(q) ||
          (job.jobType ?? '').toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 60 : 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isExpanded
                    ? [BoxShadow(color: Colors.black12, blurRadius: 8)]
                    : [],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search jobs...',
                      ),
                      onTap: () {
                        if (!_isExpanded) setState(() => _isExpanded = true);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isExpanded
                ? Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredJobs.isEmpty
                ? const Center(child: Text('No jobs found.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          job: job,
                          onTap: () => _showJobDetails(context, job),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(BuildContext context, Job job) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              final workerName = user?.name ?? 'Worker';
              // ⚡ use dialogCtx for nested dialog
              final paymentInfo = await showDialog<String?>(
                context: dialogCtx,
                builder: (innerCtx) {
                  String info = '';
                  return AlertDialog(
                    title: const Text('Payment info (account / UPI)'),
                    content: TextField(
                      onChanged: (v) => info = v,
                      decoration:
                          const InputDecoration(hintText: 'Enter account or UPI'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(innerCtx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(innerCtx, info),
                        child: const Text('Submit'),
                      ),
                    ],
                  );
                },
              );

              // ✅ correct context check
              if (!mounted) return;

              if (paymentInfo == null || paymentInfo.trim().isEmpty) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment info required')),
                );
                return;
              }

              jobProvider.assignJob(
                job.id,
                workerName,
                workerPaymentInfo: paymentInfo.trim(),
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Accepted "${job.title}"')),
              );

              // ignore: use_build_context_synchronously
              if (mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
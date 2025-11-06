import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../providers/auth_provider.dart';

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
    final jobProvider = Provider.of<JobProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final workerName = auth.user?.name ?? 'Worker';

    final List<Job> allJobs = jobProvider.allJobs;

    // Get unique categories dynamically
    final categories = <String>{
      'All',
      ...allJobs.map((job) => job.jobType ?? 'Others')
    }.toList();

    // Filter jobs in real time
    final filteredJobs = allJobs.where((job) {
      final matchesCategory = _selectedCategory == 'All' ||
          (job.jobType ?? '').toLowerCase() ==
              _selectedCategory.toLowerCase();
      final matchesSearch = job.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          job.description
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      final notRejected = !jobProvider.isRejectedFor(job.id, workerName);
      return matchesCategory && matchesSearch && notRejected;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Modern Curved Search Bar
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: _isExpanded ? 60 : 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _isExpanded
                      ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search for jobs...',
                        ),
                        onTap: () {
                          if (!_isExpanded) {
                            setState(() => _isExpanded = true);
                          }
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Categories Horizontal List
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isExpanded
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategory = category;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 10),

            // Jobs List
            Expanded(
              child: filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs found.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobCard(
                            job: job,
                            onTap: () => _showJobDetails(
                              context,
                              job,
                              jobProvider,
                              workerName,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Job details popup with Accept/Reject
  void _showJobDetails(BuildContext context, Job job,
      JobProvider jobProvider, String workerName) {
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
            onPressed: () {
              jobProvider.rejectJob(job.id, workerName);
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              jobProvider.assignJob(job.id, workerName);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accepted successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: ${value ?? 'N/A'}'),
    );
  }
}
// lib/screens/find_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import '../providers/auth_provider.dart';
import 'job_details_screen.dart';

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final workerName = auth.user?.name ?? 'Worker';

    final List<Job> allJobs = jobProvider.allJobs;

    // Get unique categories (stable order)
    final categories = <String>{'All', ...allJobs.map((job) => job.jobType ?? 'Others')}.toList();

    final query = _searchController.text.trim().toLowerCase();

    final filteredJobs = allJobs.where((job) {
      final matchesCategory = _selectedCategory == 'All' ||
          (job.jobType ?? '').toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = query.isEmpty ||
          job.title.toLowerCase().contains(query) ||
          job.description.toLowerCase().contains(query) ||
          (job.jobType ?? '').toLowerCase().contains(query);
      final notRejected = !jobProvider.isRejectedFor(job.id, workerName);
      return matchesCategory && matchesSearch && notRejected;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Curved search bar (cards style like register)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search for jobs...',
                        border: InputBorder.none,
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
                    ),
                ],
              ),
            ),

            // Categories (shows when expanded)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isExpanded
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Jobs list
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
                            showActions: true,
                            onTap: () {
                              // navigate to details screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
                              );
                            }, 
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
}
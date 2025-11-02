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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSearchExpanded = false;
  String _searchQuery = '';

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
    final user = Provider.of<AuthProvider>(context).user;
    final jobs = jobProvider.allJobs.where((j) => j.status == 'Open' && (user == null || !jobProvider.isRejectedFor(j.id, user.name))).toList();

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

          // Job Categories (dynamic, horizontally scrollable)
          Builder(builder: (context) {
            final cats = <String>{'All', ...jobProvider.allJobs.map((j) => j.jobType ?? 'Others')}.toList();
            return SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = cats[index];
                  final isSelected = cat.toLowerCase() == _searchQuery;
                  return GestureDetector(
                    onTap: () => setState(() => _searchQuery = cat.toLowerCase()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      margin: const EdgeInsets.only(left: 6, right: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Prompt for account number / UPI when accepting
                            final workerName = user?.name ?? 'Unknown';
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final paymentInfo = await showDialog<String?>(
                              context: context,
                              builder: (dialogContext) {
                                String info = '';
                                return AlertDialog(
                                  title: const Text('Enter account number / UPI ID'),
                                  content: TextField(
                                    onChanged: (v) => info = v,
                                    decoration: const InputDecoration(hintText: 'Account number or UPI ID'),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => nav.pop(), child: const Text('Cancel')),
                                    ElevatedButton(onPressed: () => nav.pop(info), child: const Text('Submit')),
                                  ],
                                );
                              },
                            );
                            if (!mounted) return;
                            if (paymentInfo == null || paymentInfo.trim().isEmpty) {
                              messenger.showSnackBar(const SnackBar(content: Text('Payment info required to accept job.')));
                              return;
                            }
                            jobProvider.assignJob(job.id, workerName, workerPaymentInfo: paymentInfo.trim());
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(content: Text('Accepted ${job.title}')));
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            final workerName = user?.name ?? 'Unknown';
                            jobProvider.rejectJob(job.id, workerName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Rejected ${job.title}')),
                            );
                            setState(() {});
                          },
                          child: const Text('Reject'),
                        ),
                      ],
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
    final user = Provider.of<AuthProvider>(context, listen: false).user;
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
              _detail('Tenure', job.tenure),
            ],
          ),
        ),
        actions: _buildDetailActions(context, job, user),
      ),
    );
  }

  List<Widget> _buildDetailActions(BuildContext context, Job job, user) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (job.status == 'Open') {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ElevatedButton(
          onPressed: () async {
            final workerName = user?.name ?? 'Unknown';
            String info = '';
            final messenger = ScaffoldMessenger.of(context);
            final nav = Navigator.of(context);
            final paymentInfo = await showDialog<String?>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Enter account number / UPI ID'),
                  content: TextField(
                    onChanged: (v) => info = v,
                    decoration: const InputDecoration(hintText: 'Account number or UPI ID'),
                  ),
                  actions: [
                    TextButton(onPressed: () => nav.pop(), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => nav.pop(info), child: const Text('Submit')),
                  ],
                );
              },
            );
            if (!mounted) return;
            if (paymentInfo == null || paymentInfo.trim().isEmpty) return;
            jobProvider.assignJob(job.id, workerName, workerPaymentInfo: paymentInfo.trim());
            if (!mounted) return;
            messenger.showSnackBar(SnackBar(content: Text('Accepted ${job.title}')));
            nav.pop();
            setState(() {});
          },
          child: const Text('Accept'),
        ),
      ];
    }

    // For assigned/completed show a close option and possibly mark complete
    if (job.status == 'Assigned' && job.workerName == user?.name) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ElevatedButton(
          onPressed: () {
            jobProvider.completeJob(job.id);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job marked completed.')));
            Navigator.pop(context);
            setState(() {});
          },
          child: const Text('Mark Complete'),
        ),
      ];
    }

    // If job is completed and worker hasn't rated client, show Rate Client
    if (job.status == 'Completed' && job.workerName == user?.name && (job.clientRating == null)) {
      return [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RatingScreen(jobId: job.id, role: 'worker', targetName: job.clientName),
              ),
            );
          },
          child: const Text('Rate Client'),
        ),
      ];
    }

    return [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))];
  }

  Widget _detail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text('$label: ${value ?? "N/A"}'),
    );
  }
}
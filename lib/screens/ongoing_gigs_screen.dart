import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/job.dart';

class OngoingGigsScreen extends StatelessWidget {
  const OngoingGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    final sample = List.generate(
      5,
      (i) => Job(
        id: 'job-${i + 1}',
        title: 'Gig ${i + 1}',
        description: 'Detailed work description for gig ${i + 1}.',
        clientName: 'Client ${i + 1}',
        postedDate: DateTime.parse('2025-11-03'),
        status: i < 3 ? 'Ongoing' : 'Completed',
        amount: '₹${(i + 1) * 500}',
        location: 'Remote',
        tenure: '2 weeks',
        paid: i >= 3,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your Gigs')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: user == null
            ? const Center(child: Text('Please login to see ongoing gigs.'))
            : ListView.builder(
                itemCount: sample.length,
                itemBuilder: (context, index) {
                  final job = sample[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ExpandableJobTile(job: job),
                  );
                },
              ),
      ),
    );
  }
}

class ExpandableJobTile extends StatefulWidget {
  final Job job;
  const ExpandableJobTile({super.key, required this.job});

  @override
  State<ExpandableJobTile> createState() => _ExpandableJobTileState();
}

class _ExpandableJobTileState extends State<ExpandableJobTile> {
  bool _expanded = false;
  late Job _currentJob;

  @override
  void initState() {
    super.initState();
    _currentJob = widget.job; // create a mutable copy for UI updates
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isDark)
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        height: _expanded ? 220 : 70, // slightly increased for button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentJob.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentJob.status,
                  style: TextStyle(
                    color: _currentJob.status == 'Completed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _currentJob.amount ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.black87,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                _currentJob.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Client: ${_currentJob.clientName}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),

              // Mark as Complete button for ongoing jobs
              if (_currentJob.status != 'Completed')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.blue[700] : Colors.blueAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentJob = _currentJob.copyWith(status: 'Completed');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Job marked as complete! Money will be credited into your account.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Mark as Complete'),
                ),

              // Rate Client button if job is completed
              if (_currentJob.status == 'Completed')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.green[700] : Colors.green,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/feedback',
                      arguments: _currentJob,
                    );
                  },
                  child: const Text('Rate Client'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
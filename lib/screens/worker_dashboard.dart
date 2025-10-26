import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';
//import '../widgets/animated_header.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final sampleJobs = List.generate(
      6,
      (i) => {
        'title': 'Worker Job ${i + 1}',
        'description': 'This is a short description for worker job ${i + 1}.',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user != null ? 'Worker Dashboard — ${user.name}' : 'Worker Dashboard',
        ),
        leading: const TopProfileMenu(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sampleJobs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'No available gigs right now.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Check back later for new opportunities!'),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width < 768
                      ? 1
                      : (width < 1024 ? 2 : 3);
                  return GridView.builder(
                    itemCount: sampleJobs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final job = sampleJobs[index];
                      return JobCard(
                        title: job['title']!,
                        description: job['description']!,
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
